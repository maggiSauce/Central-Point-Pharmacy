import csv

def openFile(filepath:str) -> list:
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

def main():
    test = openFile(r"C:\Users\small\Central-Point-Pharmacy\StudentForms\Patient listing report.csv")
    print(test)

main()