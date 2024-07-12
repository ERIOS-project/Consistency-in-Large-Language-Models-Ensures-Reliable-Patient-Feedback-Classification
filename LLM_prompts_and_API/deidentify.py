import sys
from llm4quality.deidentify.deidentify_verbatim import DeidentifyVerbatimService

deidentiy_service = DeidentifyVerbatimService(working_directory=sys.argv[1],input_csv_file=sys.argv[2],prompt_file=sys.argv[3])
deidentiy_service.run()