# LLM4Quality

This project is a Python application built using Poetry. 

## Installation

To install the dependencies for this project, make sure you have Poetry installed on your system. Then, navigate to the project directory and run the following command:

```bash
poetry install
```

This will create a virtual environment and install all the required dependencies.

## Usage

To run the project, use the following command:

```bash
poetry run python3 deidentify.py <working_directory> <input_csv_path> <prompt_file_path>
poetry run python3 post_production_deidentify.py <working_directory> <input_csv_path> <regex_file_path> <sample_excel_file_path>
poetry run python3 classify.py <working_directory> <input_csv_path> <prompt_1_file_path> <prompt_2_file_path> <categories_json_file_path>
poetry run python3 post_production_classify.py <working_directory> <input_csv_path> <categories_json_file_path>
```

The working directory must be already created.

## Sample 

```bash
poetry run python3 deidentify.py ./data/ ./sample_llm4quality.csv ./prompt_deidentify.txt
poetry run python3 post_production_deidentify.py ./data/ ./sample_llm4quality.csv ./regex.csv ./sample_excel.xlsx
poetry run python3 classify.py ./data/ ./sample_llm4quality.csv ./prompt_classify_1.txt ./prompt_classify_2.txt ./categories.json
poetry run python3 post_production_classify.py ./data/ ./sample_llm4quality.csv ./categories.json
```

## License

[License Name](link-to-license) (e.g., MIT License)