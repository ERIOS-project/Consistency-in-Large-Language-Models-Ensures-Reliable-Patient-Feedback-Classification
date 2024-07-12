import sys

from llm4quality.deidentify.clean_output_deidentify import CleanOutputDeidentifyService
from llm4quality.deidentify.excel_deidentify import ExcelDeidentifyService

clean = CleanOutputDeidentifyService(working_directory=sys.argv[1],input_csv_file=sys.argv[2],input_regex_csv_file=sys.argv[3])
clean.run()

excel = ExcelDeidentifyService(working_directory=sys.argv[1],input_csv_file=sys.argv[2], input_sample_excel=sys.argv[4])
excel.run()

                                                                                                                                                                                                                                               