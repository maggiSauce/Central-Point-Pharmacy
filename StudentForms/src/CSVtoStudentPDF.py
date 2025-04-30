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
    Returns PDFDict which is a dict that holds pdf fields as keys and corresponding values
    '''
    commentsValue = PLRDict.pop("Comments")
    commentsList = commentsValue.split("\n")
    commentsList[0] = commentsList[0][9:]       # removes "General: " from first element
    for commentVal in commentsList:
        pair = commentVal.split(":")
        for element in pair:
            element = element.strip()
        PLRDict[pair[0]] = pair[1]

    PDFDict = {}
    PDFDict["Last Name"] = PLRDict["LastName"]
    PDFDict["First Name"] = PLRDict["FirstName"]
    PDFDict["Date of Birth"] = PLRDict["Birthday"]
    PDFDict["Gender"] = PLRDict["Sex"]
    PDFDict["PHN"] = PLRDict["PHN"]
    PDFDict["Address"] = PLRDict["Address1"]
    PDFDict["City Town"] = PLRDict["City"]
    PDFDict["Province"] = PLRDict["Province"]
    PDFDict["Postal Code"] = PLRDict["Postal"]
    PDFDict["Phone"] = PLRDict["PhoneNumbers"]
    PDFDict["Program"] = PLRDict["Program"]
    PDFDict["Student ID"] = PLRDict["StudentNumber"]

    return PDFDict

def main():
    PDFDict = formatPLR(openFile(r"C:\Users\small\Central-Point-Pharmacy\StudentForms\Patient listing report.csv"))
    print(PDFDict)

    reader = PdfReader(PDFTEMPLATEPATH)
    writer = PdfWriter()

    page = reader.pages[0]
    fields = reader.get_fields()

    writer.append(reader)

    writer.update_page_form_field_values(
        writer.pages[0], 
        PDFDict,
        auto_regenerate = False
    )

    with open(PDFEXPORTPATH, "wb") as outputStream:     # 'wb' is for write binary mode
        writer.write(outputStream)
main()