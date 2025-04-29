#include JSON.ahk

programPath = C:\Users\kroll\Documents\Central-Point-Pharmacy\PDFScrape.py
JSONPath = C:\Users\kroll\Documents\Central-Point-Pharmacy\TempPDFs\tempFields.json
; medDataPath = C:\Users\kroll\Documents\Central-Point-Pharmacy\TempPDFs\medications_data.json
medDataPath = C:\Users\kroll\Documents\Central-Point-Pharmacy\TempPDFs\medications_data_with_DSigs.json


;programPath = C:\Users\small\Central-Point-Pharmacy\PDFScrape.py
;JSONPath = C:\Users\small\Central-Point-Pharmacy\TempPDFs\tempFields.json
;medDataPath = C:\Users\small\Central-Point-Pharmacy\TempPDFs\medications_data.json

^Esc::ExitApp	; CTRL + esc
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
    ; MsgBox, Successful JSON reads
    fillIndividualDrug(tempData, medData)
    MsgBox, Done!!! :) 
    return

runPython(programPath, filepath) {
    ; MsgBox, python "%programPath%" "%filepath%"
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
    ; MsgBox, % pathToJson
    
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
    firstTime := true

    for key, value in data {
        ; MsgBox, % "Key: " key " Value: " value
        if (value != "/Yes") {
            continue    ; do not do iteration if not checked yes
        }
        ; MsgBox, Yes
        if (!medData.HasKey(key)) {      ; check if data.key is in medData.key
            continue
        }
        ; MsgBox, HasKey
        item := medData[key]
        if (!(IsObject(item) && item.HasKey("DIN"))) {   ; check if item has a DIN
            continue
        }

        ; at this point, the item will have a been checked yes and have an associated DIN
        ; MsgBox, % "Key: " key " Value: " value " DIN: " item["DIN"]

        if (firstTime) {
            Send, {F12}     ; create new Rx
            Sleep, 1000
            firstTime := false
        }

        ; DIN and Doc
        Send, % item["DIN"]
        Send, {Tab}
        Send, 14127
        Send, {Enter}
        Sleep, 1000

        if (item["DIN"] == "02247208") {
            handleDukoral(key)
        }
        if (item["DIN"] == "02466783") {
            handleMalaroneAdult(key, data)
            continue
        }
        if (item["DIN"] == "02264935") {
            handleMalaronePed(key, data)
            continue
        }
       
        ; sig
        if (item["sig"] == "DEFAULT") {
            ; pass
        } else if (item["sig"] == "VARIABLE") {
            MsgBox, Variable Sig, Stopping for now
            return
        } else {
            MsgBox, Non default sig
            return
            Send, % item["sig"]
            Send, {Tab}
        }
        Sleep, 1000

        ; Disp QTY
        Send, % item["quantity"]
        Send, {Tab}
        Sleep, 500

        ; Send, ^r	; sent ctrl r to specify repeats
		; Send, % item[""]
	;	Sleep, 3000	;Remove
		; Send, {Enter}
	;	Sleep, 3000	; Test

        ; make Rx unfilled
		Send, {Alt}
		Send, r
		Send, {Enter}
		Sleep, 1000

        ; Days
        Send, % item["days_supply"]	; DAYS
		Sleep, 500

        Send, {F12}	; final fill
		Sleep, 500

        Send, {Enter}
		Send, {Enter}
		Send, {Enter}
		Send, {Enter}
		Sleep, 500
		Send, {Enter}
		Sleep, 500
		Send, {Enter}
		Sleep, 3000
    }
    return
}

handleDukoral(key) {
     ; Dukoral exception
    if (key == "Dukoral") {     
        Send, {Down}	; select second version of Dukorol
        Send, {Enter}
        Sleep, 500
        Send, {Enter}
        Sleep, 1000
    }
    if (key == "Dukoral booster") { ; select first version of dukoral
        Send, {Enter}
        Sleep, 500
        Send, {Enter}
        Sleep, 1000
    }
    return
}

handleMalaroneAdult(key, data) {
    ; calculate the DQ and Days
    dspQty := data["Total Malaria tabs Malarone"]   ; get the dspqty for malarone adult
    
     ; Disp QTY
        Send, % dspQty
        Send, {Tab}
        Sleep, 500

        ; Send, ^r	; sent ctrl r to specify repeats
		; Send, % item[""]
	;	Sleep, 3000	;Remove
		; Send, {Enter}
	;	Sleep, 3000	; Test

        ; make Rx unfilled
		Send, {Alt}
		Send, r
		Send, {Enter}
		Sleep, 1000

        ; Days
        Send, % dspQty	; DAYS
		Sleep, 500

        Send, {F12}	; final fill
		Sleep, 500

        Send, {Enter}
		Send, {Enter}
		Send, {Enter}
		Send, {Enter}
		Sleep, 500
		Send, {Enter}
		Sleep, 500
		Send, {Enter}
		Sleep, 3000
        Return
}

handleMalaronePed(key, data) {
    sigTemplate := ""

    dspQty := data["Total Malaria tabs Malarone"]   ; get the dspqty for malarone adult
    MsgBox, % dspQty
    if (data["3T QD - MP"] == "/Yes") {
        days := dspQty / 3
        sigNum := 3
    } else if (data["2T QD - MP"] == "/Yes") {
        days := dspQty / 2
        sigNum := 2
    } else if (data["1T QD - MP"] == "/Yes") {
        days := dspQty / 1
        sigNum := 1
    } else if (data["3/4T QD - MP"] == "/Yes") {
        days := dspQty / (3/4)
        sigNum := "3/4"
    } else if (data["1/2T QD - MP"] == "/Yes") {
        days := dspQty / (1/2)
        sigNum := "1/2"
    } else {
        MsgBox, "No box selected"
        ExitApp, 301
    }

    sigTemplate := % "TAKE " sigNum " TABLET ONCE DAILY (WITH FOOD), START 1 DAY PRIOR TO EXPOSURE, DURING STAY IN REGION AND FOR 1 WEEK AFTER LEAVING ENDEMIC AREA"
    Send, % sigTemplate
    Send, {Tab}

    ; Disp QTY
    Send, % dspQty
    Send, {Tab}
    Sleep, 500

    ; Send, ^r	; sent ctrl r to specify repeats
    ; Send, % item[""]
;	Sleep, 3000	;Remove
    ; Send, {Enter}
;	Sleep, 3000	; Test

    ; make Rx unfilled
    Send, {Alt}
    Send, r
    Send, {Enter}
    Sleep, 1000

    ; Days
    MsgBox, % Ceil(days)
    Send, % Ceil(days)	; DAYS
    Sleep, 500

    Send, {F12}	; final fill
    Sleep, 500

    Send, {Enter}
    Send, {Enter}
    Send, {Enter}
    Send, {Enter}
    Sleep, 500
    Send, {Enter}
    Sleep, 500
    Send, {Enter}
    Sleep, 3000
    Return
}