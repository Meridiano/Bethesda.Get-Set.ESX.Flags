#pragma compile(Console, True)
#NoTrayIcon

If (Not @Compiled) Then
	MsgBox(0, "Error", "This script must be compiled to run correctly.")
	Exit
EndIf

; === CONSOLE FUNCTIONS ===

Func ConsoleInfo($sDescription)
	ConsoleWrite($sDescription & @CRLF)
EndFunc

Func ConsoleInput($sDescription)
	ConsoleWrite($sDescription)
	While True
		Sleep(250)
		Local $sText = ConsoleRead(False, False)
		If (@Extended > 0) Then Return StringTrimRight($sText, 2)
	WEnd
EndFunc

Func ConsoleWarning($sDescription, $sLocal)
	ConsoleWrite($sDescription & " (" & $sLocal & "), press ENTER to restart")
	While True
		Sleep(250)
		Local $sText = ConsoleRead(False, False)
		If (@Extended > 0) Then ExitLoop
	WEnd
EndFunc

Func ConsoleError($sDescription, $sLocal)
	ConsoleWrite($sDescription & " (" & $sLocal & "), press ENTER to exit")
	While True
		Sleep(250)
		Local $sText = ConsoleRead(False, False)
		If (@Extended > 0) Then Exit
	WEnd
EndFunc

; === UTILITY FUNCTIONS ===

Func ConfigPath()
	Local $sTrimmed = StringTrimRight(@ScriptFullPath, 3)
	Return ($sTrimmed & "ini")
EndFunc

Func BackupFile($sPath)
	Local $sTimeStamp = StringFormat("%s-%s-%s-%s-%s-%s", @YEAR, @MON, @MDAY, @HOUR, @MIN, @SEC)
	Local $sNewPath = $sPath & "." & $sTimeStamp
	Return FileMove($sPath, $sNewPath, 1 + 8)
EndFunc

Func IntToHex($iValue)
	Local $sHex = "0x" & Hex($iValue, 8)
	Return StringRegExpReplace($sHex, "(0x)(0*)(.+)", "$1$3")
EndFunc

Func BinaryFlip($iData)
	Local $sNewData = ""
	For $iIndex = 1 To BinaryLen($iData) Step 1
		Local $sChunk = StringTrimLeft(String(BinaryMid($iData, $iIndex, 1)), 2)
		$sNewData = $sChunk & $sNewData
	Next
	Return Binary("0x" & $sNewData)
EndFunc

; === READ-ONLY FUNCTIONS ===

Func ValidPlugin($sPath)
	Local $hPlugin = FileOpen($sPath, 16)
	If ($hPlugin < 0) Then
		ConsoleError("Plugin stream error", "ValidPlugin:A")
	Else
		Local $sHeader = BinaryToString(FileRead($hPlugin, 4), 4)
		FileClose($hPlugin)
		If ($sHeader == "TES4") Then
			Return True
		Else
			ConsoleError("Plugin header error", "ValidPlugin:B")
		EndIf
	EndIf
EndFunc

Func GetFlags($sPath)
	Local $hPlugin = FileOpen($sPath, 16)
	If ($hPlugin < 0) Then
		ConsoleError("Plugin stream error", "GetFlags:A")
	Else
		Local $iDataLeft = BinaryMid(FileRead($hPlugin, 12), 9, 4)
		Local $iDataRight = BinaryFlip($iDataLeft)
		FileClose($hPlugin)
		If (BinaryLen($iDataRight) = 4) Then
			Return Number(String($iDataRight), 2)
		Else
			ConsoleError("Plugin data error", "GetFlags:B")
		EndIf
	EndIf
EndFunc

Func ShowOne($iAll, $iOne, $sKey)
	Local $sConfig = ConfigPath()
	Local $sDetails = IniRead($sConfig, "Flags", $sKey, $sKey)
	If (StringLen($sDetails) = 2) Then $sDetails = "Unknown " & $sDetails
	Local $bFlag = (BitAND($iAll, $iOne) <> 0)
	Local $sInfo = StringFormat("%10s %s : %s", IntToHex($iOne), $bFlag ? "+" : " ", $sDetails)
	ConsoleInfo($sInfo)
EndFunc

Func ShowAll($iFlags)
	ShowOne($iFlags, 0x1, "01")
	ShowOne($iFlags, 0x2, "02")
	ShowOne($iFlags, 0x4, "03")
	ShowOne($iFlags, 0x8, "04")
	ShowOne($iFlags, 0x10, "05")
	ShowOne($iFlags, 0x20, "06")
	ShowOne($iFlags, 0x40, "07")
	ShowOne($iFlags, 0x80, "08")
	ShowOne($iFlags, 0x100, "09")
	ShowOne($iFlags, 0x200, "10")
	ShowOne($iFlags, 0x400, "11")
	ShowOne($iFlags, 0x800, "12")
	ShowOne($iFlags, 0x1000, "13")
	ShowOne($iFlags, 0x2000, "14")
	ShowOne($iFlags, 0x4000, "15")
	ShowOne($iFlags, 0x8000, "16")
	ShowOne($iFlags, 0x10000, "17")
	ShowOne($iFlags, 0x20000, "18")
	ShowOne($iFlags, 0x40000, "19")
	ShowOne($iFlags, 0x80000, "20")
	ShowOne($iFlags, 0x100000, "21")
	ShowOne($iFlags, 0x200000, "22")
	ShowOne($iFlags, 0x400000, "23")
	ShowOne($iFlags, 0x800000, "24")
	ShowOne($iFlags, 0x1000000, "25")
	ShowOne($iFlags, 0x2000000, "26")
	ShowOne($iFlags, 0x4000000, "27")
	ShowOne($iFlags, 0x8000000, "28")
	ShowOne($iFlags, 0x10000000, "29")
	ShowOne($iFlags, 0x20000000, "30")
	ShowOne($iFlags, 0x40000000, "31")
	ShowOne($iFlags, 0x80000000, "32")
EndFunc

; === WRITING FUNCTIONS ===

Func SetFlag($sPath, $sCommand, $iAll)
	Local $sPattern = "(s)\s(0x[1248]0*)\s(\d)"
	If (StringRegExp($sCommand, $sPattern) = 1) Then
		Local $iOne = Number(StringRegExpReplace($sCommand, $sPattern, "$2"), 2)
		Local $bNew = (Number(StringRegExpReplace($sCommand, $sPattern, "$3"), 2) <> 0)
		Local $bOld = (BitAND($iAll, $iOne) <> 0)
		If ($bNew = $bOld) Then
			ConsoleWarning("This flag is already set to " & ($bNew ? 1 : 0), "SetFlag:A")
		Else
			Local $iNewFlags = $bNew ? ($iAll + $iOne) : ($iAll - $iOne)
			Local $sNewFlags = "0x" & Hex($iNewFlags, 8)
			Local $iDataRight = Binary($sNewFlags)
			Local $iDataLeft = BinaryFlip($iDataRight)
			Local $hPlugin = FileOpen($sPath, 16)
			If ($hPlugin < 0) Then
				ConsoleWarning("Plugin stream error", "SetFlag:B")
			Else
				Local $iFullData = FileRead($hPlugin)
				Local $iPrefixData = BinaryMid($iFullData, 1, 8)
				Local $iSuffixData = BinaryMid($iFullData, 13)
				FileClose($hPlugin)
				If BackupFile($sPath) Then
					Local $hNewPlugin = FileOpen($sPath, 1 + 16)
					If ($hNewPlugin < 0) Then
						ConsoleWarning("Plugin stream error", "SetFlag:C")
					Else
						FileWrite($hNewPlugin, $iPrefixData)
						FileWrite($hNewPlugin, $iDataLeft)
						FileWrite($hNewPlugin, $iSuffixData)
						FileClose($hNewPlugin)
					EndIf
				Else
					ConsoleWarning("Plugin backup error", "SetFlag:D")
				EndIf
			EndIf
		EndIf
	Else
		ConsoleWarning("Wrong command syntax", "SetFlag:E")
	EndIf
EndFunc

; === CORE FUNCTIONS ===

Func UpdateConfig()
	Local $sFilePath = ConfigPath()
	Local $sWebPath = IniRead($sFilePath, "Config", "URL", "")
	If ($sWebPath = "") Then Return
	ConsoleInfo("Updating config from web, URL = " & $sWebPath)
	Local $iBytes = InetGet($sWebPath, $sFilePath, 1 + 2, 0)
	If ($iBytes > 0) Then
		ConsoleInfo("Done, " & $iBytes & " bytes downloaded")
	Else
		ConsoleError("Updating config failed", "UpdateConfig:A")
	EndIf
EndFunc

Func OpenPlugin()
	Local $sPath = FileOpenDialog("Open ESX", @ScriptDir, "ESX Plugin (*.esp;*.esm;*.esl)", 1)
	If (@Error = 0) Then
		Local $bValid = ValidPlugin($sPath)
		If $bValid Then
			ConsoleInfo("Selected plugin = " & $sPath)
			Return $sPath
		EndIf
	Else
		ConsoleError("Plugin selection failed", "OpenPlugin:A")
	EndIf
EndFunc

Func MainLoop()
	UpdateConfig()
	Local $sPath = OpenPlugin()
	While True
		Local $sCommand = ConsoleInput("Select your action, G=Get, S=Set > ")
		If ($sCommand = "G") Then
			Local $iFlags = GetFlags($sPath)
			ShowAll($iFlags)
		ElseIf (StringMid($sCommand, 1, 1) = "S") Then
			Local $iFlags = GetFlags($sPath)
			SetFlag($sPath, $sCommand, $iFlags)
		Else
			ConsoleWarning("Wrong command syntax", "MainLoop:A")
		EndIf
	WEnd
EndFunc

; === MAIN EXECUTION ===

MainLoop()

Exit
