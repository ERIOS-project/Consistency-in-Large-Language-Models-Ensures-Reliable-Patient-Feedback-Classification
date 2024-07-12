import pandas as pd
import os
from openai import OpenAI
from datetime import datetime

class DeidentifyVerbatimService:
    __working_directory=""
    __log_path=""
    __number_of_verbatims=0
    __prompt=""

    def __init__(self,working_directory,input_csv_file,prompt_file):
        self.__log_path = working_directory+datetime.now().strftime("%Y-%m-%d %H:%M:%S")+"log.txt"
        self.__prompt = self.__get_prompt(prompt_file)
        self.__working_directory = working_directory
        self.__init_folder(self.__working_directory+"verbatims_deidentified")
        self.__init_folder(self.__working_directory+"verbatims")
        self.__init_logger()
        df = self.__get_raw_verbatims(input_csv_file)
        verbatims = self.__get_verbatims(df)
        self.__number_of_verbatims = len(verbatims)
        self.__save_verbatims(verbatims)

    def run(self,start=1):
        """
        Run process to deidentify verbatim
        input :
        - start : id of the verbatim to start the process
        """
        print(f"Start process from {start} to {self.__number_of_verbatims}")        
        for i in range(start,self.__number_of_verbatims+1):
            verbatim = self.__get_verbatim(i)
            print(f"------------------------  Verbatim # {i} ------------------------")
            print(verbatim)  
            print("---------------------")  
            # We have to do it two times in a row with the same result to validate the absence of hallucination.
            modified_verbatim_1 = self.__deidentify_verbatim(verbatim)
            modified_verbatim_2 = self.__deidentify_verbatim(verbatim)
            # Wich is the next try to redo. Oscillate between 1 and 2
            to_modify = 1 
            # How many tries have already been processed
            modification_counter = 0 
            # max try number before accepting having failed.
            max_modifications = 3 

            while modified_verbatim_1 != modified_verbatim_2 and modification_counter<max_modifications:
                modification_counter = modification_counter+1
                print(f"anonymisation not consistent. retry {modification_counter}/{max_modifications} beginning")
                if to_modify == 1 : 
                    modified_verbatim_1 = self.__deidentify_verbatim(verbatim)
                    to_modify = 2
                    continue
                if to_modify == 2 :
                    modified_verbatim_2 = self.__deidentify_verbatim(verbatim)
                    to_modify = 1

            if modification_counter == max_modifications and modified_verbatim_1 != modified_verbatim_2 : # We didn't manage to get the same result, so we try the last method, indicating the llm to correct their answer.
                print("Last try to de-indentify : use of method 2")
                modified_verbatim_1 = self.__deidentify_verbatim(verbatim, modified_verbatim_1, method=2)
                modified_verbatim_2 = self.__deidentify_verbatim(verbatim, modified_verbatim_2, method=2)
                if modified_verbatim_1 != modified_verbatim_2 :
                    self.__log("\n----------------Verbatim "+i+" deanonymisation not consistent----------------\n"+
                                "Original verbatim :\n"+verbatim+"\n"+
                                "modified verbatim :\n"+modified_verbatim_2+"\n")
                    print("Failed to get consistent. Consitency log updated.")

            verbatim = modified_verbatim_2
            print(verbatim)

            self.__save_deidentify_verbatim(i, verbatim)

    def __deidentify_verbatim(self,verbatim, modified_verbatim="", method=1):
        """
        Deidentify verbatim
        input :
        - verbatim : content of the verbatim
        - modified_verbatim : verbatim modified by the llm
        - method : method = 2 and indicate a modified verbatim if the de-indentification is not consistent.
        return : verbatim deidentified
        """
        
        prompt1 = """
        [INST] 
        """+self.__prompt+""" 
        """+verbatim+""" 
        "

        [/INST]
        """

        prompt2 = """
        [INST]
        Write again the text without human proper noun. Remove from your response any extra commentary and any extra characters.
        [/INST]
        """

        # Classic de-indentification
        if method == 1 :    
            full_prompt = prompt1
        # De-indentification already failed
        if method == 2 :    
            full_prompt = "<s>"+prompt1 +"\n"+ modified_verbatim +" </s> \n"+ prompt2

        # Point to the local server
        client = OpenAI(base_url="http://localhost:1234/v1", api_key="not-needed")
        deployment_name="local-model", # this field is currently unused
        
        response = client.chat.completions.create(
            model=deployment_name, # model = "deployment_name".
            max_tokens=32000,
            temperature=0,
            messages=[
                    {"role": "system", "content": full_prompt}
                ]
        )
        response = response.choices[0].message.content
        return(response)
    
    def __get_verbatim(self,id):
        """
        Get verbatims from id
        input :
        - id : id of the verbatim
        return : verbatims from id
        """
        # Open the file in read mode
        with open(self.__working_directory+f"verbatims/verbatim{id}.txt", 'r', encoding="utf-8") as file:
            return file.read()
    
    def __save_deidentify_verbatim(self,id, verbatim):
        """
        Save deidentify verbatim
        input :
        - id : id of the verbatim
        - verbatim : content of the deidentify verbatim 
        """
        with open(self.__working_directory+f"verbatims_deidentified/verbatim{id}.txt", 'w',encoding="utf-8") as file:
            file.write(verbatim)
    
    def __get_raw_verbatims(self,input_csv_file):
        """
        Get verbatims in raw format
        input :
        - input_csv_file : path to input csv file
        return : verbatims in raw format
        """
        # Import data file
        return pd.read_csv(input_csv_file, delimiter=';',encoding='utf-8',low_memory=False)
    
    def __get_verbatims(self,df):
        """
        Get verbatims parsed is an array
        input :
        - df : dataframe of raw verbatims
        return : verbatims parsed is an array
        """
        data=[]
        # Iterate through each row of the DataFrame
        for i in range(0,len(df)):
            positive=""
            negative=""
            if not df['Positif'].empty: 
                positive = str(df['Positif'].iloc[i])
                if positive == "nan" : positive = "Aucun commentaire"
            if not df['Negatif'].empty:
                negative = str(df['Negatif'].iloc[i])
                if negative == "nan" : negative = "Aucun commentaire"
            verbatim = "Points positifs : " + positive + ". Points négatifs : " + negative + "."
            data.append(verbatim)
        return data

    def __save_verbatims(self,data):
        """
        Save verbatim as a txt file
        input :
        - data : verbatims parsed is an array
        """
        # Open the file in write mode
        i=1
        for string in data:
            with open(self.__working_directory+f"verbatims/verbatim{i}.txt", 'w', encoding="utf-8") as file:
            # Write each string in the list to the file
                file.write(f"{string}")
            i=i+1

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
