import os
import pandas as pd
import json
import llm4quality.constants as constants
from datetime import datetime

class ExcelClassifyService:
    __working_directory=""
    __log_path = ""
    __matrix_confidence_df = {}
    def __init__(self,working_directory, matrix_confidence_df):
        self.__log_path = working_directory+datetime.now().strftime("%Y-%m-%d %H:%M:%S")+"log.txt"
        self.__working_directory = working_directory
        self.__init_logger()
        self.__matrix_confidence_df = matrix_confidence_df

    def run(self,start_score=0, end_score=35):
        """
        Run process to convert verbatims classyfied to excel
        input:
        - start_score: score >= used to print classification rules
        - end_score: score <= used to print classification rules
        """
        df = pd.read_excel(f'{self.__working_directory}result_deidentify.xlsx')
        df['13. Positif_Themes'] = df['13. Positif_Themes'].astype(str)
        df['14. Negatif_Themes'] = df['14. Negatif_Themes'].astype(str)
        df['15. CatPositif'] = df['15. CatPositif'].astype(str)
        df['16. CatNegatif'] = df['16. CatNegatif'].astype(str)
        df['13. Positif_Themes'] = ""
        df['14. Negatif_Themes'] = ""
        df['15. CatPositif'] = ""
        df['16. CatNegatif'] = ""
        score = []
        for i, verbatim_value in self.__matrix_confidence_df.items():
            for category, category_value in verbatim_value.items():
                if category_value['positive']['score_total'] >= start_score and category_value['positive']['score_total'] <= end_score:
                    if category_value['positive']['score_total'] not in score:
                        score.append(category_value['positive']['score_total'])
                    df.at[i-1, '13. Positif_Themes'] += category+";"
                if category_value['negative']['score_total'] >= start_score and category_value['negative']['score_total'] <= end_score:
                    if category_value['negative']['score_total'] not in score:
                        score.append(category_value['negative']['score_total'])
                    df.at[i-1, '14. Negatif_Themes'] += category+";"
                if category in df.at[i-1, '14. Negatif_Themes'] :
                    df.at[i-1, '16. CatNegatif'] += constants.themes_and_categories[category]+";"
                if category in df.at[i-1, '13. Positif_Themes'] :
                    df.at[i-1, '15. CatPositif'] += constants.themes_and_categories[category]+";"
            if df.at[i-1, '13. Positif_Themes'].endswith(";"):
                df.at[i-1, '13. Positif_Themes'] = df.at[i-1, '13. Positif_Themes'][:-1]
            if df.at[i-1, '14. Negatif_Themes'].endswith(";"):
                df.at[i-1, '14. Negatif_Themes'] = df.at[i-1, '14. Negatif_Themes'][:-1]
            if df.at[i-1, '15. CatPositif'].endswith(";"):
                df.at[i-1, '15. CatPositif'] = df.at[i-1, '15. CatPositif'][:-1]
            if df.at[i-1, '16. CatNegatif'].endswith(";"):
                df.at[i-1, '16. CatNegatif'] = df.at[i-1, '16. CatNegatif'][:-1]
        with pd.ExcelWriter(f'{self.__working_directory}result_classify.xlsx') as writer:
            df.to_excel(writer, index=False)  
        print(score)      

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
