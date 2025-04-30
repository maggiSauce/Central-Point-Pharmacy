from pypdf import PdfReader

PDFEXPORTPATH = r"C:\Users\small\Central-Point-Pharmacy\StudentForms\TempExport\Tester.pdf"


def main():
    reader = PdfReader(PDFEXPORTPATH)
    fields = reader.get_fields()
    # for fieldName, fieldData in fields.items():
    #     print(f"{fieldName}: {fieldData.get('/V')}")

    female = fields["Female"]
    male = fields["Male"]

    print(female.get('/V'), male.get('/V'))


main()