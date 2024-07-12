import sys
from llm4quality.classify.classify_verbatim import ClassifyVerbatimService

classify_service = ClassifyVerbatimService(working_directory=sys.argv[1],input_csv_file=sys.argv[2],prompt_file_1=sys.argv[3],prompt_file_2=sys.argv[4],categories_file=sys.argv[5])
classify_service.run()