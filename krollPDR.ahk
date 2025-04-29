#include JSON.ahk

;programPath = C:\Users\kroll\Documents\pythonStuff\PDFScrape.py
programPath = C:\Users\small\Central-Point-Pharmacy\PDFScrape.py
JSONPath = C:\Users\small\Central-Point-Pharmacy\TempPDFs\tempFields.json

^+q::
InputBox, filepath, Input the pdf file
MsgBox, The filepath is %filepath%
if (!runPython(programPath, filepath)) {    ; exit hotkey execution if runPython returns False
    return
}
Sleep, 500
parseJSON()
return

runPython(programPath, filepath) {
    MsgBox, python "%programPath%" "%filepath%"
    RunWait, python "%programPath%" "%filepath%"
    exitCode := ErrorLevel      ; save the python exit code

    if (exitCode != 0) {
        MsgBox, Python file exited with non-zero code: %exitCode%
        return false
    }
    return true
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

fillIndividualDrug() {
    Send, {F12}     ; create new Rx
    Sleep, 1000
    
    ; active field is "Drug Search"
    Send, % *DIN*   ; DIN
    Send, {Tab}
    Send, 14127     ; doc primary key
    Send, {Enter}
    Sleep, 1000

    ; Display Quantity
    Send, % *DISPQTY*
    Sleep, 1000

    ; make Rx unfilled
    Send, {Alt}
    Send, r
    Send, {Enter}
    Sleep, 1000

    ; Days
    Send, % *DAYS*
    Sleep, 500

    Send, {F12}     ; send final fill request
    Sleep, 500

    Send, {Enter}
    Sleep, 500
    Send, {Enter}
    Sleep, 3000
}