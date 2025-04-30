import csv
from pypdf import PdfReader, PdfWriter
from pypdf.generic import NameObject, BooleanObject

PDFTEMPLATEPATH = r"C:\Users\small\Central-Point-Pharmacy\StudentForms\Norquest.pdf"
PDFEXPORTPATH = r"C:\Users\small\Central-Point-Pharmacy\StudentForms\TempExport\Tester.pdf"
CSVPATH = r"C:\Users\small\Central-Point-Pharmacy\StudentForms\Patient listing report.csv"


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

def extractPhoneNumber(numberString):
    """
    Extracts the first available phone number and returns it. 
    If no number is found, returns false
    """

    phoneNumber = ''
    activeNumber = False

    for char in numberString:
        if char.isdigit() or char in '()- ':
            phoneNumber += char
            activeNumber = True
        elif activeNumber:
            break
    if phoneNumber:
        return phoneNumber
    else:
        return None
    
def isMale(genderString):
    if genderString == "M":
        return "/On"
    return '/Off'

def isFemale(genderString):
    if genderString == "F":
        return "/On"
    return '/Off'
    
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
    PDFDict["PHN"] = PLRDict["PHN"]
    PDFDict["Address"] = PLRDict["Address1"]
    PDFDict["City Town"] = PLRDict["City"]
    PDFDict["Province"] = PLRDict["Province"]
    PDFDict["Postal Code"] = PLRDict["Postal"]
    PDFDict["Phone"] = extractPhoneNumber(PLRDict["PhoneNumbers"])
    PDFDict["Program"] = PLRDict["Program"]
    PDFDict["Student ID"] = PLRDict["StudentNumber"]
    PDFDict["Male"] = isMale(PLRDict["Sex"])
    PDFDict["Female"] = isFemale(PLRDict["Sex"])

    return PDFDict


def main():
    PDFDict = formatPLR(openFile(CSVPATH))
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

    # Copy over AcroForm and set NeedAppearances = True
    writer._root_object.update({NameObject("/AcroForm"): reader.trailer["/Root"]["/AcroForm"]}) 
    writer._root_object["/AcroForm"].update({NameObject("/NeedAppearances"): BooleanObject(True)})

    with open(PDFEXPORTPATH, "wb") as outputStream:     # 'wb' is for write binary mode
        writer.write(outputStream)

    print("done")
main()