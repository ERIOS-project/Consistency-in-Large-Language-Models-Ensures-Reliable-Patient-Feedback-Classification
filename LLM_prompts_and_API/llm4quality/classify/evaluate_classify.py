import os
import pandas as pd
import json
import llm4quality.constants as constants
from datetime import datetime

class EvaluateClassifyService:
    __working_directory=""
    __log_path = ""
    __matrix_class_df = {}
    __matrix_justif_df = {}
    __input_categories_file = ""

    def __init__(self,working_directory,input_csv_file,input_categories_file):
        self.__log_path = working_directory+datetime.now().strftime("%Y-%m-%d %H:%M:%S")+"log.txt"
        self.__working_directory = working_directory
        self.__input_csv_file = input_csv_file
        self.__index = self.__get_indexes()
        self.__init_logger()
        self.__init_matrix_class_and_justification()
        self.__input_categories_file = input_categories_file

    def run(self):
        """
        Create confidence score matrix using a similar MultiIndex DataFrame as previous matrices
        return : confidence score matrix
        """
        matrix_confidence_df = {}
        classification_rules = self.__get_classification_rules()
        for i in self.__index:
            matrix_confidence_df[i] = {}
            for current_category in constants.categories:
                matrix_confidence_df[i][current_category] = {}
                for current_tone in constants.tone:
                    matrix_confidence_df[i][current_category][current_tone] = {}
                    current_justification1 = self.__matrix_justif_df[i]["LLM1"][current_category][current_tone]
                    current_justification2 = self.__matrix_justif_df[i]["LLM2"][current_category][current_tone]
                    # sep_char_position "|"
                    sep_char_position1 = current_justification1.find("|")
                    sep_char_position2 = current_justification2.find("|")
                    # Element and citation extraction from justification
                    if sep_char_position1 != -1:
                        element1 = current_justification1[:sep_char_position1].strip()
                        citation1 = current_justification1[sep_char_position1+1:].strip()
                    else:
                        element1, citation1 = "", ""
                    if sep_char_position2 != -1:
                        element2 = current_justification2[:sep_char_position2].strip()
                        citation2 = current_justification2[sep_char_position2+1:].strip()
                    else:
                        element2, citation2 = "", ""
                    # Score: class1
                    matrix_confidence_df[i][current_category][current_tone]["class1"] = 0
                    matrix_confidence_df[i][current_category][current_tone]["class2"] = 0
                    matrix_confidence_df[i][current_category][current_tone]["syntax1"] = 0
                    matrix_confidence_df[i][current_category][current_tone]["syntax2"] = 0
                    matrix_confidence_df[i][current_category][current_tone]["element_accordance"] = 0
                    matrix_confidence_df[i][current_category][current_tone]["citation_accordance"] = 0
                    if self.__matrix_class_df[i]["LLM1"][current_category][current_tone] == 1:
                        matrix_confidence_df[i][current_category][current_tone]["class1"] = 1
                    # Score: class2
                    if self.__matrix_class_df[i]["LLM2"][current_category][current_tone] == 1:
                        matrix_confidence_df[i][current_category][current_tone]["class2"] = 1
                    # Score: syntax1
                    if element1 in classification_rules[current_category] and len(citation1) > 0:
                        matrix_confidence_df[i][current_category][current_tone]["syntax1"] = 1
                    # Score: syntax2
                    if element2 in classification_rules[current_category] and len(citation2) > 0:
                        matrix_confidence_df[i][current_category][current_tone]["syntax2"] = 1
                    # Score: element_accordance
                    if len(element1) > 0 and len(element2) > 0 and element1 == element2:
                        matrix_confidence_df[i][current_category][current_tone]["element_accordance"] = 1
                    # Score: citation_accordance
                    if len(citation1) > 0 and len(citation2) > 0 and (citation1 in citation2 or citation2 in citation1):
                        matrix_confidence_df[i][current_category][current_tone]["citation_accordance"] = 1
                    # Calculate total score
                    matrix_confidence_df[i][current_category][current_tone]["score_total"] = (
                        12 * matrix_confidence_df[i][current_category][current_tone]["class1"] +
                        12 * matrix_confidence_df[i][current_category][current_tone]["class2"] +
                        4 * matrix_confidence_df[i][current_category][current_tone]["syntax1"] +
                        4 * matrix_confidence_df[i][current_category][current_tone]["syntax2"] +
                        2 * matrix_confidence_df[i][current_category][current_tone]["element_accordance"] +
                        1 * matrix_confidence_df[i][current_category][current_tone]["citation_accordance"]
                    )
        return matrix_confidence_df

    def __init_matrix_class_and_justification(self):
        """
        Initialize matrix class and justification
        return : matrix class and justification initialized in the class
        """
        file_correspondance = pd.DataFrame({
        'index': self.__index,
        'LLM1': [f"./data/clean_llm_output_1/{i}_output.json" for i in self.__index],
        'LLM2': [f"./data/clean_llm_output_2/{i}_output.json" for i in self.__index]
        })
        for i in self.__index:
            self.__matrix_class_df[i] = {}
            self.__matrix_justif_df[i] = {}
            # Gather the LLM classification:
            for current_agent in constants.agent:
                try:
                    with open(file_correspondance.loc[file_correspondance['index'] == i, current_agent].iloc[0], 'r') as file:
                        input_text = file.read()
                    input_json = json.loads(input_text)
                    # Erase the themes, keep the categories
                    input_2 = input_json[constants.current_theme]
                except Exception as e:
                    self.__log(f"An error occurred on load verbatim {i} {current_agent}: {e.with_traceback}")
                self.__matrix_class_df[i][current_agent] = {}
                self.__matrix_justif_df[i][current_agent] = {}
                for current_category in constants.categories:
                    self.__matrix_class_df[i][current_agent][current_category] = {}
                    self.__matrix_justif_df[i][current_agent][current_category] = {}
                    for current_tone in constants.tone:
                        self.__matrix_class_df[i][current_agent][current_category][current_tone] = 0
                        self.__matrix_justif_df[i][current_agent][current_category][current_tone] = ""
                        if current_tone == "positive" and input_2[current_category]["positive"] != "":
                            # Assign the classification as '1' for positive sentiment
                            self.__matrix_class_df[i][current_agent][current_category][current_tone] = 1
                            # Store the justifications
                            self.__matrix_justif_df[i][current_agent][current_category][current_tone] = input_2[current_category]["positive"]
                        if current_tone == "negative" and input_2[current_category]["negative"] != "":
                            # Assign the classification as '1' for negative sentiment
                            self.__matrix_class_df[i][current_agent][current_category][current_tone] = 1
                            # Store the justifications
                            self.__matrix_justif_df[i][current_agent][current_category][current_tone] = input_2[current_category]["negative"]
    
    def __get_classification_rules(self):
        """
        We need to read the classification rules in order to clean unjustified classifications
        return : object of classification rules
        """
        try:
            with open(self.__input_categories_file, 'r') as file:
                input_text = file.read()
            classification_rules_json = json.loads(input_text)
            # Erase the themes, keep the categories
            classification_rules = {}
            for current_theme, current_theme_value  in classification_rules_json.items():
                classification_rules[current_theme] = {}
                for current_category_key, current_category_value in current_theme_value.items():
                    elements = []
                    for _, element in current_category_value.items():
                        elements.append(element)
                    classification_rules[current_category_key] = [element.strip() for element in elements]
            return classification_rules
        except Exception as e:
            self.__log(f"An error occurred on rules: {e}")
            raise e
        
        
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
