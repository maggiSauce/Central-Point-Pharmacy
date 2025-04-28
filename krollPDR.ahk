; Access the arguments; the only arguement should be a json file that we will have to parse in this program
pdfJson := A_Args[1]
; must convert into a dictionary. after we have done that we can then access all key/value pairs related
; to the pdf fields.
; final step is to write the ahk script that will interact with kroll
; look inside KrollAllHotkeys.ahk to see the syntax

#include JSON.ahk

;programPath = C:\Users\kroll\Documents\pythonStuff\PDFScrape.py
programPath = C:\Users\small\Central-Point-Pharmacy\PDFScrape.py
JSONPath = C:\Users\small\Central-Point-Pharmacy\TempPDFs\tempFields.json

^+q::
InputBox, filepath, Input the pdf file
MsgBox, The filepath is %filepath%
runPython(programPath, filepath)
return

runPython(programPath, filepath) {
    MsgBox, python "%programPath%" "%filepath%"
    Run, %ComSpec% /k python "%programPath%" "%filepath%"
    return
}

parseJSON() {
    FileRead, jsonContent, %JSONPath%   # load the file
    data := JSON.Load(jsonContent)      # parse json
    MsgBox, "data.Check Box6"
    return
}