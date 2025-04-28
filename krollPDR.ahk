; Access the arguments; the only arguement should be a json file that we will have to parse in this program
pdfJson := A_Args[1]
; must convert into a dictionary. after we have done that we can then access all key/value pairs related
; to the pdf fields.
; final step is to write the ahk script that will interact with kroll
; look inside KrollAllHotkeys.ahk to see the syntax

^+q::
InputBox, filepath, Input the pdf file
MsgBox, The filepath is %filepath%
runPython(filepath)
return

runPython(filepath) {
    ;MsgBox, hello
    MsgBox, python3 "C:\Users\kroll\Documents\pythonStuff\PDFScrape.py" "%filepath%"
    Run, %ComSpec% /k python3 "C:\Users\kroll\Documents\pythonStuff\PDFScrape.py" "%filepath%"
    return
}

parseJSON() {
    
}