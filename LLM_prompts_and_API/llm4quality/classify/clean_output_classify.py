import os
import pandas as pd
import json
import llm4quality.constants as constants
from datetime import datetime

class CleanOutputClassifyService:
    __working_directory=""
    __log_path = ""
    __input_csv_file = ""

    def __init__(self,working_directory,input_csv_file):
        self.__log_path = working_directory+datetime.now().strftime("%Y-%m-%d %H:%M:%S")+"log.txt"
        self.__working_directory = working_directory
        self.__input_csv_file = input_csv_file
        self.__index = self.__get_indexes()
        self.__init_logger()
        self.__init_folder(f"{self.__working_directory}clean_llm_output_1")
        self.__init_folder(f"{self.__working_directory}clean_llm_output_2")

    def run(self):
        """
        Run process to clean output
        return : json file of cleaned output
        """
        for folder in range(1, 3):
            # Iterates for each verbatim
            for i in self.__index:
                current_json = {}
                current_json[constants.current_theme] = {}
                try:
                    with open(f"{self.__working_directory}llm_output_{folder}/prompt_2/{i}_output.txt", 'r') as file:
                        input_lines = file.readlines()
                    input = json.loads("".join([line.strip() for line in input_lines]))
                except Exception as e:
                    self.__log(f'Verbatim {i}: {e}')
                    input = {}
                for _, theme in input.items():
                        for category, category_value in theme.items():
                            category = category.rstrip()
                            if constants.corrections.get(category) is not None:
                                category = constants.corrections.get(category)
                            category = category.replace("'","’")
                            if category in constants.categories:
                                current_json[constants.current_theme][category] = {
                                    "positive": "",
                                    "negative": "",
                                    "neutral": "",
                                    "not mentioned": ""
                                }
                                for tone, tone_value in category_value.items():
                                    if tone_value != '':
                                        tone_value = tone_value if not isinstance(tone_value, list) else ""
                                        tone_value = tone_value.replace("\xa0", "")
                                        current_json[constants.current_theme][category][tone.lower().rstrip()] = tone_value
                # Save the json in the new folder
                with open(f"{self.__working_directory}clean_llm_output_{folder}/{i}_output.json", 'w', encoding='utf-8') as json_file:
                        json.dump(current_json, json_file, ensure_ascii=False, indent=4)
        
    def __get_indexes(self):
        """
        List every complete justification
        return : array of indexes completed
        """
        df = pd.read_csv(self.__input_csv_file, delimiter=';',encoding='utf-8',low_memory=False)
        index = []
        for i in range(1, len(df)+1):
            if (os.path.exists(f"{self.__working_directory}llm_output_1/prompt_2/{i}_output.txt") and os.path.exists(f"{self.__working_directory}llm_output_2/prompt_2/{i}_output.txt")) :
                index.append(i)
        return index

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