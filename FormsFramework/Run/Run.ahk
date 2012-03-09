/*
	Function: Run
			  Retrieve and be notified about output from the console programs.

	Parameters:
			Cmd		 - Command to execute.
			Dir		 - Working Directory, optional.
			Skip	 - Decimal, number of lines to be omitted from the start and the end of the command output.
					   For instance 3.5, means that first 3 and last 5 lines will be omitted.
			Input	 - Program input (stdin).
			Stream	 - If set to TRUE it will create a console window and display output line-by-line, in addition to returning the result as a whole.
  					   If string, name of the function to be called as output updates (stream handler). The function accepts one argument.

	Remarks:
			After the function finishes, ErrorLevel will be set to programs exit code.
			You can't use function names for stream handler which consist only of numbers.
			To see Unicode characters (AHKL required), use cmd.exe /u option. 
			Not all command line programs support Unicode output (for instance sort.exe)

	Examples:
		(start code)
			sOutput := Run("ping.exe localhost")							;just grab the output
			sOutput := Run("ping.exe localhost", "", 0, "", "OnOutput")		;with stream handler
			sOutput := Run("cmd.exe /c dir /a /o", A_WinDir)				;with working dir
			sOutput := Run("sort.exe", "", 0, "abc`r`nefg`r`nhijk`r`n0123" )	;with stdin input
			if !ErrorLevel
				msgbox Program failed with exit code %ErrorLevel%
			
			OnOutput(s){
					OutputDebug %s%
			}
		 (end code)

	About:	
			o v1.25
			o Developed by Sean. Modified and documented by majkinetor.
			o Unlicensed <http://unlicense.org/> 
 */
Run(Cmd, Dir = "", Skip=0, Input = "", Stream = "") {
	static StrGet := "StrGet"

	DllCall("CreatePipe", "UintP", hStdInRd , "UintP", hStdInWr , "Uint", 0, "Uint", 0)
	DllCall("CreatePipe", "UintP", hStdOutRd, "UintP", hStdOutWr, "Uint", 0, "Uint", 0)
	DllCall("SetHandleInformation", "Uint", hStdInRd , "Uint", 1, "Uint", 1)
	DllCall("SetHandleInformation", "Uint", hStdOutWr, "Uint", 1, "Uint", 1)

	VarSetCapacity(pi, 16, 0) 
	NumPut(VarSetCapacity(si, 68, 0), si)	; size of si
	 ,NumPut(0x100,		si, 44)		; STARTF_USESTDHANDLES
	 ,NumPut(hStdInRd,	si, 56)		; hStdInput
	 ,NumPut(hStdOutWr, si, 60)		; hStdOutput
	 ,NumPut(hStdOutWr, si, 64)		; hStdError
	If !DllCall("CreateProcess", "Uint", 0, "Uint", &Cmd, "Uint", 0, "Uint", 0, "int", True, "Uint", 0x08000000, "Uint", 0, "Uint", Dir ? &Dir : 0, "Uint", &si, "Uint", &pi)	; bInheritHandles and CREATE_NO_WINDOW
		return A_ThisFunc "> Can't create process:`n" Cmd 
	
	hProcess := NumGet(pi,0)
    DllCall("CloseHandle", "Uint", NumGet(pi,4)),  DllCall("CloseHandle", "Uint", hStdOutWr),  DllCall("CloseHandle", "Uint", hStdInRd)

	If Input !=
		DllCall("WriteFile", "Uint", hStdInWr, "Uint", &Input, "Uint", StrLen(Input)*(A_IsUnicode ? 2:1), "UintP", nSize, "Uint", 0)
	DllCall("CloseHandle", "Uint", hStdInWr)

	if (Stream+0)
		bAlloc := DllCall("AllocConsole") ,hCon:=DllCall("CreateFile","str","CON","Uint",0x40000000,"Uint", bAlloc ? 0 : 3, "Uint",0, "Uint",3, "Uint",0, "Uint",0)

	VarSetCapacity(sTemp, nTemp:=Stream ? 64-nTrim:=1 : 4095)
	loop 
		if DllCall("ReadFile", "Uint", hStdOutRd, "Uint", &sTemp, "Uint", nTemp, "UintP", nSize:=0, "Uint", 0) && nSize
		{
			NumPut(0,sTemp,nSize,"Uchar"), VarSetCapacity(sTemp,-1)
			sTemp := A_IsUnicode ? %StrGet%(&sTemp, nTemp, "UTF-8") : sTemp,  sOutput .= sTemp
			if Stream
				loop
					if RegExMatch(sOutput, "S)[^\n]*\n", sTrim, nTrim)
						 Stream+0 ? DllCall("WriteFile", "Uint", hCon, "Uint", &sTrim, "Uint", StrLen(sTrim)*(A_IsUnicode ? 2:1), "UintP", 0, "Uint", 0) : %Stream%(sTrim), nTrim += StrLen(sTrim)
					else break
		} else break

	DllCall("CloseHandle", "Uint", hStdOutRd)
	Stream+0 ? (DllCall("Sleep", "Uint", 1000), hCon+1 ? DllCall("CloseHandle","Uint", hCon) : "", bAlloc ? DllCall("FreeConsole") : "" ) : ""
	DllCall("GetExitCodeProcess", "uint", hProcess, "intP", ExitCode), DllCall("CloseHandle", "Uint", hProcess)

	if (Skip != "") {
		StringSplit, s, Skip, ., 
		StringReplace, sOutput, sOutput, `n, `n, A UseErrorLevel
		s2 := ErrorLevel - (s2 ? s2 : 0) + 1, 	s1++
		loop, parse, sOutput,`n,`r
			if A_Index between %s1% and %s2%
				s .= A_LoopField "`r`n"
		StringTrimRight, sOutput, s, 2
	}

	ErrorLevel := ExitCode
	return	sOutput
}