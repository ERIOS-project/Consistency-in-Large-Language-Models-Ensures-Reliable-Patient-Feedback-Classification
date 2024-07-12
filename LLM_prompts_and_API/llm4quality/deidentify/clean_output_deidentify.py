import os
import re
import csv
import pandas as pd
from datetime import datetime
import unicodedata

class CleanOutputDeidentifyService:
    __working_directory=""
    __log_path = ""
    __input_csv_file = ""
    __input_regex_csv_file = ""
    def __init__(self,working_directory,input_csv_file,input_regex_csv_file):
        self.__log_path = working_directory+datetime.now().strftime("%Y-%m-%d %H:%M:%S")+"log.txt"
        self.__working_directory = working_directory
        self.__input_csv_file = input_csv_file
        self.__input_regex_csv_file = input_regex_csv_file
        self.__index = self.__get_indexes()
        self.__init_logger()
        self.__init_folder(f"{self.__working_directory}verbatims_deidentified_cleaned")

    def run(self):
        """
        Run process to clean output
        """
        raw_verbatims = self.__get_raw_verbatims()
        verbatims = self.__get_verbatims()
        regex_data = self.__get_regex_data()
        self.__drop_bad_verbatims(raw_verbatims, verbatims, regex_data)
        
        
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
            else:
                print(f"erreur i: {i}")
        return index
    
    def __get_raw_verbatims(self):
        """
        Get verbatims from csv file
        return : array of verbatims from csv file
        """
        raw_data = pd.read_csv(self.__input_csv_file, delimiter=';',encoding='utf-8',low_memory=False)
        raw_data['Positif'] = raw_data['Positif'].fillna("Aucun commentaire.")
        raw_data['Negatif'] = raw_data['Negatif'].fillna("Aucun commentaire.")
        return " Points positifs : " + raw_data['Positif'] + ". Points négatifs : " + raw_data['Negatif']
    
    def __get_verbatims(self):
        """
        Gather all deidentified verbatims in a vector
        return : array of verbatims
        """
        verbatims = []
        for i in self.__index:
            file_name = f"{self.__working_directory}verbatims_deidentified/verbatim{i}.txt"
            try:
                with open(file_name, 'r') as file:
                    current_verbatim = " ".join([line.strip() for line in file])
                verbatims.append(current_verbatim)
            except Exception as e:
                self.__log("Get verbatims")
                pass
            old_i = i
        return verbatims
    
    def __get_regex_data(self):
        """
        Get first names and last names for regex
        return : array of first names and last names as ['Jean','DURAND']
        """
        df = pd.read_csv(self.__input_regex_csv_file, header=None) 
        array = []
        for _, row in df.iterrows():
            names = row[0].split(' ')
            array.extend([value + ' ' for value in names])
        return array
    
    def __drop_bad_verbatims(self,raw_verbatims,verbatims,regex_data):
        """
        If no [NAME] is present inside the deidentified verbatim or if the original verbatim can be found inside the verbatim, get the original back
        And if a regex_data is present we remplace by [NAME]
        input:
        - raw_verbatims : verbatims from csv file
        - verbatims : verbatims from txt file
        - regex_data : verbatims from txt file
        return: bad verbatims are dropped
        """
        n_dropped = 0
        n_regex_data = 0
        print(f"Count verbatims: {len(self.__index)}")
        for i in range(len(self.__index)):
            verbatim = ""
            if ("[NAME]" not in verbatims[i] or self.__remove_accents_and_spaces(raw_verbatims.iloc[i]) in self.__remove_accents_and_spaces(verbatims[i])):
                n_dropped += 1
                verbatim = raw_verbatims.iloc[i]
            else:
                verbatim = verbatims[i]
            for data in regex_data:
                if data != ' ':
                    verbatim_cleaned = verbatim
                    if data.upper() in verbatim_cleaned :
                        verbatim_cleaned = verbatim_cleaned.replace(" "+data.upper(), "[NAME]")
                        verbatim_cleaned = verbatim_cleaned.replace("."+data.upper(), "[NAME]")
                    elif data.lower() in verbatim_cleaned :
                        verbatim_cleaned = verbatim_cleaned.replace(" "+data.lower(), "[NAME]")
                        verbatim_cleaned = verbatim_cleaned.replace("."+data.lower(), "[NAME]")
                    elif data.capitalize() in verbatim_cleaned :
                        verbatim_cleaned = verbatim_cleaned.replace(" "+data.capitalize(), "[NAME]")
                        verbatim_cleaned = verbatim_cleaned.replace("."+data.capitalize(), "[NAME]")
                    if not verbatim == verbatim_cleaned:
                        n_regex_data += 1
                        verbatim = verbatim_cleaned

            file_name = f"{self.__working_directory}verbatims_deidentified_cleaned/verbatim{i + 1}.txt"
            with open(file_name, 'w') as file:
                file.write(verbatim)
        print(f"number of deindentified verbatims dropped: {n_dropped}")
        print(f"number of regex_data names dropped: {n_regex_data}")

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
    
    def __remove_accents_and_spaces(self,input_str):
        """
        Remove accent and space on string
        """
        nfkd_form = unicodedata.normalize('NFKD', input_str)
        only_ascii = nfkd_form.encode('ASCII', 'ignore')
        return only_ascii.decode().replace(' ','')