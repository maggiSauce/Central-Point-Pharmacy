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
Sleep, 500
parseJSON()
return

runPython(programPath, filepath) {
    MsgBox, python "%programPath%" "%filepath%"
    Run, python "%programPath%" "%filepath%"
    return
}

parseJSON() {
    global JSONPath
    MsgBox, % JSONPath
    
     ; Wait until the file exists and is not empty
    Loop {
        if (FileExist(JSONPath)) {
            FileGetSize, fileSize, %JSONPath%
            if (fileSize > 0)
                break
        }
        Sleep, 100  ; wait 100 milliseconds before checking again
    }

    if !FileExist(JSONPath) {
        MsgBox % "Error: JSON file does not exist at " JSONPath
        return
    }

    FileRead, jsonContent, %JSONPath%   ; load the file
    if (jsonContent = "") {
        MsgBox % "Error: JSON file is empty."
        return
    }

    data := JSON.Load(jsonContent)      ; parse json
    if (IsObject(data)) {
        MsgBox % "JSON loaded successfully!"
    } else {
        MsgBox % "Failed to load JSON."
        return
    }

    if (data.HasKey("Check Box6")) {
        MsgBox, % "data: " data["Check Box6"]
    } else {
        MsgBox, No key
    }
    return
}