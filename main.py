import os
import fitz  # PyMuPDF
import re
import json


from dask_mpi import initialize
initialize()

from distributed import Client
client = Client()

def is_valid_match(match):
    return isinstance(match, str) and match.startswith("GAO")

def extract_gao_citation(pdf_path, regex_pattern):
    doc = fitz.open(pdf_path)
    unique_matches = set()

    for page_number in range(doc.page_count):
        page = doc[page_number]
        text = page.get_text()

        page_matches = re.findall(regex_pattern, text)
        unique_matches.update(match for match in page_matches if match.startswith("GAO"))

    doc.close()
    return {'file': pdf_path, 'matches': list(unique_matches)}

def process_pdfs_in_folder(folder_path, regex_pattern):
    output_folder = "parsed"

    for filename in os.listdir(folder_path):
        if filename.endswith(".pdf"):
            pdf_path = os.path.join(folder_path, filename)
            output_json_path = os.path.join(output_folder, f"{os.path.splitext(filename)[0]}_output.json")

            result = extract_gao_citation(pdf_path, regex_pattern)

            with open(output_json_path, 'w') as json_file:
                json.dump(result, json_file, indent=2)

folder_path = "pdfs-test"
regex_pattern =  r'\bGAO-[A-Z0-9]+(?:-[A-Z0-9]+)*\b'

process_pdfs_in_folder(folder_path, regex_pattern)
