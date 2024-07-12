import openai
import pandas as pd
import os
import json
from openai import AzureOpenAI, OpenAI
from datetime import datetime
from llm4quality.tiktoken import num_tokens_from_string
import threading
import queue
from dotenv import load_dotenv
load_dotenv()

class ClassifyVerbatimService:
    __working_directory=""
    __number_of_verbatims=0
    __prompt_1=""
    __prompt_2=""
    __categories=""
    __queue_prompt_1 = queue.Queue()
    __queue_prompt_2 = queue.Queue()
    __log_path = ""
    __usage_token = 0

    def __init__(self,working_directory,input_csv_file,prompt_file_1,prompt_file_2,categories_file):
        self.__log_path = working_directory+datetime.now().strftime("%Y-%m-%d %H:%M:%S")+"log.txt"
        self.__init_logger()
        self.__working_directory = working_directory
        self.__init_folder(self.__working_directory+"llm_output_1")
        self.__init_folder(self.__working_directory+"llm_output_1/prompt_1")
        self.__init_folder(self.__working_directory+"llm_output_1/prompt_2")
        self.__init_folder(self.__working_directory+"llm_output_2")
        self.__init_folder(self.__working_directory+"llm_output_2/prompt_1")
        self.__init_folder(self.__working_directory+"llm_output_2/prompt_2")
        self.__number_of_verbatims = self.__get_number_of_verbatims(input_csv_file)
        self.__prompt_1 = self.__get_prompt(prompt_file_1)
        self.__prompt_2 = self.__get_prompt(prompt_file_2)
        self.__categories = self.__get_categories(categories_file)

    def run(self,start=1,end=-1,run_fails=False):
        """
        Run process to classify verbatim
        input :
        - start : id of the verbatim to start the process
        - end : id of the verbatim to end the process
        """
        if end == -1:
            end = self.__number_of_verbatims
        print(f"Run classify from {start} to {end}")

        # Create queue
        array_1 = []
        array_2 = []
        if not run_fails:
            for i in range(start,end+1):
                array_1.append({'id': i, 'output_path': "llm_output_1"})
                array_1.append({'id': i, 'output_path': "llm_output_2"})
        else :
            print("Recovery of failed verbatims ...")
            array_1 += self.get_fails_verbatim_ids("llm_output_1","prompt_1",start,end)
            array_1 += self.get_fails_verbatim_ids("llm_output_2","prompt_1",start,end)
            array_2 += self.get_fails_verbatim_ids("llm_output_1","prompt_2",start,end)
            array_2 += self.get_fails_verbatim_ids("llm_output_2","prompt_2",start,end)
            array_2 = [x for x in array_2 if x not in array_1]

        for i in  array_1: 
            self.__queue_prompt_1.put(i)
        for i in  array_2: 
            self.__queue_prompt_2.put(i)

        # Create and run threads
        num_threads_1 = 40  
        num_threads_2 = 40  
        threads = []
        for i in range(num_threads_1):
            thread = threading.Thread(target=self.__prompt_1_worker)
            thread.start()
            threads.append(thread)
        for i in range(num_threads_2):
            thread = threading.Thread(target=self.__prompt_2_worker)
            thread.start()
            threads.append(thread)

        # Wait until all actions have been processed
        self.__queue_prompt_1.join()
        self.__queue_prompt_2.join()

        # Stop threads by adding an end marker to the queue
        for _ in range(num_threads_1):
            self.__queue_prompt_1.put(None)
        for _ in range(num_threads_2):
            self.__queue_prompt_2.put(None)

        # Wait for all threads to terminate
        for thread in threads:
            thread.join()

    def __prompt_1_worker(self):
        """
        Launch prompt 1 when a thread is available
        """
        while True:
            action = self.__queue_prompt_1.get()
            if action is None: 
                break
            try :
                print(f"Run verbatim {action['id']} ==> Number of prompt_1 verbatims remaining : {self.__queue_prompt_1.qsize()}")
                with open(self.__working_directory+f"verbatims_deidentified/verbatim{action['id']}.txt", 'r',encoding="utf-8") as file:
                    verbatim=file.read()
                print(f"------------------------  Verbatim # {action['id']} prompt_1 ------------------------")
                print(verbatim)
                nb_token = num_tokens_from_string(verbatim)
                self.__usage_token += nb_token
                if int(os.environ.get("QUOTAS")) < self.__usage_token :
                    self.__queue_prompt_1.put(action)
                else :
                    response =self.__prompt_1_run(verbatim)
                    self.__save_verbatim_prompt_1(action['id'], action['output_path'], response)
                    self.__queue_prompt_2.put(action)
                    print(f"llm output {action['id']}  #1 done")
                self.__usage_token -= nb_token
            except openai.BadRequestError as e:
                print(f"Error : {e}")
                if e.code=="content_filter":
                    self.__log(f"Verbatim {action['id']} : content filtering "+str(e.body['innererror']['content_filter_result'])+"\n")
                else : 
                    self.__log(f"Verbatim {action['id']} : "+str(e)+"\n")
                    self.__queue_prompt_2.put(action)
            except Exception as e:
                print(f"Error : {e}")
                self.__log(f"Verbatim {action['id']} : "+str(e)+"\n")
                self.__queue_prompt_1.put(action)
            self.__queue_prompt_1.task_done()
    
    def __prompt_1_run(self,verbatim):
        full_prompt1 = """
        [INST] 
        """ + self.__prompt_1 + """
        """ + verbatim + """ "
        [/INST]
        
        """
        client = AzureOpenAI(
            azure_endpoint = os.environ.get("AZURE_ENDPOINT"),
            api_key=os.environ.get("AZURE_API_KEY"),  
            api_version=os.environ.get("AZURE_API_VERSION"),
        )
        response = ""
        for chat_completion in client.chat.completions.create(
            model="GPT4_TURBO",
            messages=[
                {"role": "system", "content": full_prompt1}
            ],
            stream=True,
        ):
            if chat_completion.choices: 
                response += (chat_completion.choices[0].delta.content or "")
        
        return response
    
    def __prompt_2_worker(self):
        """
        Launch prompt 2 when a thread is available
        """
        while True:
            action = self.__queue_prompt_2.get()
            if action is None: 
                break
            try :
                print(f"Run verbatim {action['id']} ==> Number of prompt_2 verbatims remaining : {self.__queue_prompt_2.qsize()}")
                with open(self.__working_directory+f"verbatims_deidentified/verbatim{action['id']}.txt", 'r',encoding="utf-8") as file:
                    verbatim=file.read()
                with open(self.__working_directory+f"{action['output_path']}/prompt_1/{action['id']}_output.txt", 'r',encoding="utf-8") as file:
                    response_1=file.read()
                print(f"------------------------  Verbatim # {action['id']} prompt_2 ------------------------")
                nb_token = num_tokens_from_string(verbatim)
                self.__usage_token += nb_token
                if int(os.environ.get("QUOTAS")) < self.__usage_token :
                    self.__queue_prompt_1.put(action)
                else :
                    response =self.__prompt_2_run(verbatim,response_1)
                    self.__save_verbatim_prompt_2(action['id'], action['output_path'], response)
                    print(f"llm output {action['id']}  #2 done")
                self.__usage_token -= nb_token
            except openai.BadRequestError as e:
                print(f"Error : {e}")
                if e.code=="content_filter":
                    self.__log(f"Verbatim {action['id']} : content filtering "+str(e.body['innererror']['content_filter_result'])+"\n")
                else : 
                    self.__log(f"Verbatim {action['id']} : "+str(e)+"\n")
                    self.__queue_prompt_2.put(action)
            except Exception as e:
                print(f"Error : {e}")
                self.__log(f"Verbatim {action['id']} : "+str(e)+"\n")
                self.__queue_prompt_2.put(action)
            self.__queue_prompt_2.task_done()
              

    def __prompt_2_run(self,verbatim,response_1):
        full_prompt1 = """
        [INST] 
        """ + self.__prompt_1 + """
        """ + verbatim + """ "
        [/INST]
        
        """
        prompt2 = """
            [INST] 
            
            A category can be identified as present only if one of its elements is mentioned. Here is a list of each possible elements for each category in a json format :
            """ + self.__categories +"""
            """ + self.__prompt_2 + """
             """+ verbatim +""" '. Create the json in totality according to all instructions given. 
            In the case where you identify the presence of the tone 'positive', 'negative' ou 'neutral', it is crucial that the justification contains word for word an element of the given list defining this very category.

            [/INST]
        """
        client = AzureOpenAI(
            azure_endpoint = os.environ.get("AZURE_ENDPOINT"),
            api_key=os.environ.get("AZURE_API_KEY"),  
            api_version=os.environ.get("AZURE_API_VERSION"),
        )
        response = ""
        for chat_completion in client.chat.completions.create(
            model="GPT4_TURBO",
            messages=[
                    {"role": "system", "content": "<s>" + full_prompt1 + response_1 + "</s>" + prompt2}
            ],
            stream=True,
        ):
            if chat_completion.choices:  
                response += (chat_completion.choices[0].delta.content or "")
        
        # Remove leading and trailing white spaces, backticks and the 'json' inscription 
        response = response.replace("```", "")
        response = response.replace("json", "")
        response.strip()

        # /!\ Warning. Initially, the output was a json file because GPT4 reliably produced json compatible syntaxes.
        # It is not the case for llama2 nor Mixtral. As is, we save the information into a txt file to ensure the possibiility to
        # produce the classifications without supervision.
        return response
    
    def get_fails_verbatim_ids(self,output_path, prompt_path, start, end):
        """
        Get fails verbatim identifiers
        input :
        - output_path : path of the output folder of verbatims
        return : array of fails verbatim identifiers
        """
        folder_path = self.__working_directory+f"{output_path}/{prompt_path}"
        present_integers = set()

        for filename in os.listdir(folder_path):
            if filename.endswith("_output.txt"):
                try:
                    integer = int(filename.split("_")[0])
                    present_integers.add(integer)
                except ValueError:
                    pass

        all_integers = set(range(start, end))
        missing_integers = sorted(all_integers - present_integers)
        return [{'id': i, 'output_path': output_path} for i in missing_integers]

    def __get_number_of_verbatims(self,input_csv_file):
        """
        Get number of verbatims
        input :
        - input_csv_file : path to input csv file
        return : number of verbatims
        """
        # Read the CSV file into a pandas DataFrame
        df = pd.read_csv(input_csv_file, delimiter=';',encoding='utf-8',low_memory=False)
        # Get the number of rows in the DataFrame
        return df.shape[0]
    
    def __get_prompt(self,promp_file):
        """
        Get prompt from the prompt file
        input :
        - promp_file : path to the prompt file
        return : prompt
        """
        # Open the file in read mode
        with open(promp_file, 'r', encoding="utf-8") as file:
            return file.read()
        
    def __get_categories(self,promp_file):
        """
        Get categories from the categories file
        input :
        - categories_file : path to the categories file
        return : categories stringified
        """
        with open(promp_file, encoding='utf-8') as json_file:
            return str(json.load(json_file))
        
    def __save_verbatim_prompt_1(self,id,output_path,verbatim):
        """
        Save verbatim from the prompt 2 as a txt file
        input :
        - id : identifier of the verbatim
        - output_path : output_path of the verbatim
        - verbatim : verbatim from the prompt 1
        """
        # Save the output as a txt file.
        txt_file_path = self.__working_directory+f"{output_path}/prompt_1/{id}_output.txt"
        with open(txt_file_path, "w", encoding="utf-8") as file:
            file.write(verbatim)

    def __save_verbatim_prompt_2(self,id,output_path,verbatim):
        """
        Save verbatim from the prompt 2 as a txt file
        input :
        - id : identifier of the verbatim
        - output_path : output_path of the verbatim
        - verbatim : verbatim classified
        """
        # Save the output as a txt file.
        txt_file_path = self.__working_directory+f"{output_path}/prompt_2/{id}_output.txt"
        with open(txt_file_path, "w", encoding="utf-8") as file:
            file.write(verbatim)
    
    def __init_logger(self):
        """
        Init log file
        """
        if os.path.exists(self.__log_path):
            # erase previous logs if existing
            os.remove(self._log_path) 
    
    def __log(self,log):
        """
        Add log in log file
        input :
        - log : log for the logger
        """
        # Open the log file in append mode
        with open(self.__log_path, 'a', encoding = "utf-8") as file:
            # Add the verbatim to the log
            file.write(log)

    def __init_folder(self,directory_path):
        """
        Initialize folder for process
        """
        # Check if the directory already exists
        if not os.path.exists(directory_path):
            # Create the directory
            try:
                os.makedirs(directory_path)
                print(f"Directory '{directory_path}' created successfully.")
            except OSError as e:
                print(f"Error: {directory_path} : {e.strerror}")
        else:
            print(f"Directory '{directory_path}' already exists.")