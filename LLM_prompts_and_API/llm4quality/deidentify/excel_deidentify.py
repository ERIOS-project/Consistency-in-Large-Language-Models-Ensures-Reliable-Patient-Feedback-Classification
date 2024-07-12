import os
import pandas as pd
import json
import llm4quality.constants as constants
from datetime import datetime

class ExcelDeidentifyService:
    __working_directory=""
    __log_path = ""
    __input_csv_file = ""
    __input_sample_excel = ""

    def __init__(self,working_directory,input_csv_file,input_sample_excel):
        self.__log_path = working_directory+datetime.now().strftime("%Y-%m-%d %H:%M:%S")+"log.txt"
        self.__working_directory = working_directory
        self.__input_csv_file = input_csv_file
        self.__input_sample_excel = input_sample_excel
        self.__index = self.__get_indexes()
        self.__init_logger()

    def run(self):
        """
        Run process to convert verbatims deidentified to excel
        """
        df = pd.read_excel(self.__input_sample_excel)
        verbatims = self.__get_verbatims()
        print(f"Index excel : {len(self.__index)}")
        for i, value in enumerate(self.__index) :
            df.at[value+1, 'N°Obs'] = value
            split = verbatims[i].split("Points négatifs :")
            if len(split) == 1:
                split = verbatims[i].split("Points negatifs :")
            if len(split) == 1:
                split = verbatims[i].split("Points negatives :")
            df.at[value+1, '1. Positif'] = split[0].replace("Points positifs : ","")
            df.at[value+1, '2. Negatif'] = split[1]
        df.to_excel(f'{self.__working_directory}result_deidentify.xlsx', index=False)

    def __get_verbatims(self):
        """
        Gather all deidentified verbatims in a vector
        return : array of verbatims
        """
        verbatims = []
        for i in self.__index:
            file_name = f"{self.__working_directory}verbatims_deidentified_cleaned/verbatim{i}.txt"
            try:
                with open(file_name, 'r') as file:
                    current_verbatim = " ".join([line.strip() for line in file])
                verbatims.append(current_verbatim)
            except Exception as e:
                self.__log("Get verbatims")
                pass
        return verbatims
        
        
    def __get_indexes(self):
        """
        List every complete justification
        return : array of indexes completed
        """
        df = pd.read_csv(self.__input_csv_file, delimiter=';',encoding='utf-8',low_memory=False)
        index = []
        for i in range(1, len(df)+1):
            if os.path.exists(f"{self.__working_directory}verbatims_deidentified_cleaned/verbatim{i}.txt") :
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
