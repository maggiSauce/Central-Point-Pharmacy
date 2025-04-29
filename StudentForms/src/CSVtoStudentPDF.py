import csv
from pypdf import PdfReader, PdfWriter

PDFTEMPLATEPATH = r"C:\Users\small\Central-Point-Pharmacy\StudentForms\Norquest.pdf"
PDFEXPORTPATH = r"C:\Users\small\Central-Point-Pharmacy\StudentForms\TempExport\Tester.pdf"

def openFile(filepath:str) -> dict:
    '''
    opens and formats a file
    returns a list of each line in the file
    '''
    
    with open(filepath, newline='', encoding='utf-8') as csvfile:
        reader = csv.DictReader(csvfile)
    
        # Get the first row
        first_row = next(reader)

        # Filter out empty values (None, empty strings, or whitespace-only strings)
        filledFieldsDict = {
            key: value for key, value in first_row.items() if value and value.strip()
        }
    return filledFieldsDict

def formatPLR(PLRDict: dict) -> dict:
    '''
    Formats the Patient Listing Report dictionary
    '''
    commentsValue = PLRDict.pop("Comments")
    commentsList = commentsValue.split("\n")
    commentsList[0] = commentsList[0][9:]       # removes "General: " from first element
    for commentVal in commentsList:
        pair = commentVal.split(":")
        for element in pair:
            element = element.strip()
        PLRDict[pair[0]] = pair[1]
    return PLRDict

def formatPDFDict(PLRDict):
    

def fillPDF():
    pass


def main():
    PLRDict = formatPLR(openFile(r"C:\Users\small\Central-Point-Pharmacy\StudentForms\Patient listing report.csv"))
    print(PLRDict)

    reader = PdfReader(PDFTEMPLATEPATH)  # Replace with your actual file
    writer = PdfWriter(PDFEXPORTPATH)
main()