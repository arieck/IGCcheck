#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=IGCcheck.ico
#AutoIt3Wrapper_Outfile=..\IGCCheck.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         Andreas Rieck (c) 2017

 Script Function:
	PC based IGC file validation for Competition Scorers

License:
	CDDL 1.0; https://opensource.org/licenses/CDDL-1.0

Release: 0.3

#ce ----------------------------------------------------------------------------


#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <WinAPIFiles.au3>
#include <Array.au3>
#include <File.au3>


main()

Func main()

	Global $valiPassedString = ""

	; read config file
	if FileExists("IGCcheck.ini") Then
		; do nothing
	Else
		MsgBox($MB_ICONINFORMATION, "", "Error. The config file IGCcheck.ini is missing at " & @WorkingDir)
		Exit
	EndIf

	$valiBinDirectory = IniRead ( "IGCcheck.ini", "valiexe", "directory", @WorkingDir & "\bin" )
	if ($valiBinDirectory == "") Then
		$valiBinDirectory =  @WorkingDir & "\bin"
	EndIf

	; Create a constant variable in Local scope of the message to display in IgcFileSelectFolder.
	Local Const $sIgcMessage = "Select the folder of your IGC files to check them."

    ; Display an open dialog to select the directory.
    Local $sIgcFileSelectFolder = FileSelectFolder($sIgcMessage, @WorkingDir)
    If @error Then
        ; Display the error message.
        MsgBox($MB_ICONINFORMATION, "", "No IGC folder was selected.")
		Exit
    EndIf

    ; List all the files and folders in the desktop directory using the default parameters.
    Local $IGCfiles = _FileListToArray($sIgcFileSelectFolder, "*.igc")
    If @error = 1 Then
        MsgBox($MB_ICONINFORMATION, "", "Path was invalid.")
        Exit
    EndIf
    If @error = 4 Then
        MsgBox($MB_ICONINFORMATION, "", "No IGC files were found within current directory.")
        Exit
    EndIf

	; display a message box before executing the validation
	$numberOfFiles = $IGCfiles[0]
	if($numberOfFiles > 2) Then
		MsgBox($MB_ICONINFORMATION, "", "Found '" & $numberOfFiles & "' IGC files to check within " & $sIgcFileSelectFolder & " This may take a while.")
	Else
		MsgBox($MB_ICONINFORMATION, "", "Found '" & $numberOfFiles & "' IGC files to checkwithin " & $sIgcFileSelectFolder & " Click OK to start the validation check.")
	EndIf

	; create a array to store the results
	Global $resultArray[$numberOfFiles+1][3]
	$resultArray[0][0] = "IGC file"
	$resultArray[0][1] = "Result"
	$resultArray[0][2] = "A-Record"

	; loop within the array of all found igc files
	$i = 1;
	For $currentIgcFile IN $IGCfiles
		; skip the first entry from _FileListToArray function
		$fileExtention = stringRight($currentIgcFile, 3)
		if($fileExtention <> "igc") Then
			ContinueLoop
		EndIf

		; try to read the igc file, there should be no error, otherwise filesystem or permission issue
		$igcFileCompletePath = $sIgcFileSelectFolder & "\" & $currentIgcFile
		Local $hIgcFileOpen = FileOpen($igcFileCompletePath, $FO_READ)
		If $hIgcFileOpen = -1 Then
			$resultArray[$i][0] = $igcFileCompletePath;
			$resultArray[$i][1] = "ERROR OPEN FILE";
			$resultArray[$i][2] = "";
		Else

			; create path to vali exe binary from IGC file ARecord (read first 4 chars from IGC)
			$igcCode = StringLower(stringRight(FileRead($hIgcFileOpen, 4), 3))
			; read the binary from ini file based on the found 3-letter code
			Local $sValiExe = $valiBinDirectory & "\" & IniRead ( "IGCcheck.ini", StringUpper($igcCode), "binary", "" )
			Local $sValiExeUnsupported = IniRead ( "IGCcheck.ini", StringUpper($igcCode), "status", "" )

			; if the corresponding vali-exe exist on file system, then we continue, otherwise stop and error
			if FileExists($sValiExe) Then
				; lookup return value from ini file for validation "passed"
				$valiPassedString = IniRead ( "IGCcheck.ini", StringUpper($igcCode), "string", "" )

				; if the corresponding section can not be found on INI file, then this vali exe is not configured
				if($valiPassedString == "") Then
					; vali exe not configured from ini file
					$resultArray[$i][0] = $currentIgcFile
					$resultArray[$i][1] = "Configuration error. vali-" & $igcCode & ".exe not configured at ini file."
					$resultArray[$i][2] = StringUpper($igcCode)
				Else

					; execute validation
					$VALICMD = '"' & $sValiExe & '" "' & $igcFileCompletePath & '" '
					Local $vPID = Run(@ComSpec & ' /c "' & $VALICMD & '"', "", @SW_HIDE, $STDOUT_CHILD)

					; Wait until the process has closed using the PID returned by Run.
					ProcessWaitClose($vPID)

					; Read the Stdout stream of the vPID returned by RunWait.
					Local $valiOutput = StdoutRead($vPID)

					; check if the "passed" string can be found from Stdout, write the result into a array
					$foundPassedString = StringInStr($valiOutput, $valiPassedString)

					if( $foundPassedString > 0) Then
						$resultArray[$i][0] = $currentIgcFile
						if($sValiExeUnsupported == "unsupported") Then
							$resultArray[$i][1] = "IGC file unsupported"
						Else
							$resultArray[$i][1] = "OK"
						EndIf
						$resultArray[$i][2] = StringUpper($igcCode)
					Else
						$resultArray[$i][0] = $currentIgcFile
						if($sValiExeUnsupported == "unsupported") Then
							$resultArray[$i][1] = "IGC file unsupported"
						Else
							$resultArray[$i][1] = "FAILED"
						EndIf
						$resultArray[$i][2] = StringUpper($igcCode)
					EndIf

				EndIf

			Else
				; error, no such vali-*.exe for IGC file within bin directory
				$resultArray[$i][0] = $currentIgcFile
				$resultArray[$i][1] = "Configuration error. vali-" & $igcCode & ".exe can not be found at " & $valiBinDirectory
				$resultArray[$i][2] = StringUpper($igcCode)
			EndIf

			; Close the handle returned by FileOpen.
			FileClose($hIgcFileOpen)
		EndIf
		$i = $i + 1
	Next

    ; Display the results returned by _FileListToArray.
	_ArrayDisplay($resultArray, $sIgcFileSelectFolder & "\*.igc")
EndFunc   ;==>main




