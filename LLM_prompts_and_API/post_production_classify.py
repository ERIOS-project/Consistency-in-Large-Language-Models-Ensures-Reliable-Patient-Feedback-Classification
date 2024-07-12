import sys
from llm4quality.classify.clean_output_classify import CleanOutputClassifyService
from llm4quality.classify.evaluate_classify import EvaluateClassifyService
from llm4quality.classify.excel_classify import ExcelClassifyService

print("Start cleaning ...")
clean = CleanOutputClassifyService(working_directory=sys.argv[1],input_csv_file=sys.argv[2])
clean.run()
print("Start evaluation ...")
evaluate = EvaluateClassifyService(working_directory=sys.argv[1],input_csv_file=sys.argv[2],input_categories_file=sys.argv[3])
evaluation = evaluate.run()
print("Start excel ...")
excel = ExcelClassifyService(working_directory=sys.argv[1], matrix_confidence_df=evaluation)
excel.run(start_score=35)
