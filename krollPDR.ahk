#include JSON.ahk

programPath = C:\Users\kroll\Documents\Central-Point-Pharmacy\PDFScrape.py
JSONPath = C:\Users\kroll\Documents\Central-Point-Pharmacy\TempPDFs\tempFields.json
medDataPath = C:\Users\kroll\Documents\Central-Point-Pharmacy\TempPDFs\medications_data.json

;programPath = C:\Users\small\Central-Point-Pharmacy\PDFScrape.py
;JSONPath = C:\Users\small\Central-Point-Pharmacy\TempPDFs\tempFields.json
;medDataPath = C:\Users\small\Central-Point-Pharmacy\TempPDFs\medications_data.json


^+q::
    InputBox, filepath, Input the pdf file
    if (filepath == "") {
        MsgBox, No filepath given
        return
    }

    if (!runPython(programPath, filepath)) {    ; exit hotkey execution if runPython returns False
        return
    }
    if (!tempData := parseJSON(JSONPath)) {     ; load tempFields.Json
        return
    }
    if (!medData := parseJSON(medDataPath)) {    ; load medications_data.json
        return
    }
    MsgBox, Successful JSON reads
    fillIndividualDrug(tempData, medData)
    return

runPython(programPath, filepath) {
    MsgBox, python "%programPath%" "%filepath%"
    RunWait, python "%programPath%" "%filepath%"
    exitCode := ErrorLevel      ; save the python exit code

    if (exitCode == 102) {
        MsgBox, %filepath% does not exist
        return 0
    }
    if (exitCode != 0) {
        MsgBox, Python file exited with non-zero code: %exitCode%
        return false
    }
    return true
}

parseJSON(pathToJson) {
    MsgBox, % pathToJson
    
    if !FileExist(pathToJson) {
        MsgBox % "Error: JSON file does not exist at " pathToJson
        return 0
    }

    FileRead, jsonContent, %pathToJson%   ; load the file
    if (jsonContent = "") {
        MsgBox % "Error: JSON file is empty."
        return 0
    }

    data := JSON.Load(jsonContent)      ; parse json
    if (IsObject(data)) {
        ;MsgBox % "JSON loaded successfully!"
    } else {
        MsgBox % "Failed to load JSON."
        return 0
    }
    return data
}

fillIndividualDrug(data, medData) {
    Send, {F12}     ; create new Rx
    Sleep, 1000

    for key, value in data {
        ; MsgBox, % "Key: " key " Value: " value
        if (value != "/Yes") {
            continue    ; do not do iteration if not checked yes
        }
        MsgBox, Yes
        if (!medData.HasKey(key)) {      ; check if data.key is in medData.key
            continue
        }
        MsgBox, HasKey
        item = medData[key]
        if (!(IsObject(item) && item.HasKey("DIN"))) {   ; check if item has a DIN
            continue
        }

        ; at this point, the item will have a been checked yes and have an associated DIN
        MsgBox, % "Key: " key " Value: " value " DIN: " item["DIN"]
    }
    
    ; active field is "Drug Search"
    ; Send, % *DIN*   ; DIN
    ; Send, {Tab}
    ; Send, 14127     ; doc primary key
    ; Send, {Enter}
    ; Sleep, 1000

    ; Display Quantity
    ; Send, % *DISPQTY*
    ; Sleep, 1000

    ; make Rx unfilled
    ; Send, {Alt}
    ; Send, r
    ; Send, {Enter}
    ; Sleep, 1000

    ; Days
    ; Send, % *DAYS*
    ; Sleep, 500

    ; Send, {F12}     ; send final fill request
    ; Sleep, 500

    ; Send, {Enter}
    ; Sleep, 500
    ; Send, {Enter}
    ; Sleep, 3000
}