
Taskbar_Define(Filter="", pQ="", ByRef o1="~`a ", ByRef o2="", ByRef o3="", ByRef o4=""){
	static TB_BUTTONCOUNT = 0x418, TB_GETBUTTON=0x417, sep="|"
	ifEqual, pQ,, SetEnv, pQ, iwt

	if Filter is integer
		 bPos := Filter
	else if Filter contains ahk_pid,ahk_id
		 bPid := InStr(Filter, "ahk_pid"),  bID := !bPid,  Filter := SubStr(Filter, 8)
	else bName := true

	oldDetect := A_DetectHiddenWindows
	DetectHiddenWindows, on

	WinGet,	pidTaskbar, PID, ahk_class Shell_TrayWnd
	hProc := DllCall("OpenProcess", "Uint", 0x38, "int", 0, "Uint", pidTaskbar)
	pProc := DllCall("VirtualAllocEx", "Uint", hProc, "Uint", 0, "Uint", 32, "Uint", 0x1000, "Uint", 0x4)
	hctrl := Taskbar_getTaskBar()
	SendMessage,TB_BUTTONCOUNT,,,, ahk_id %hctrl%
	
	i := bPos ? bPos-1 : 0
	cnt := bPos ?  1 : ErrorLevel
	Loop, %cnt%
	{
		i++
		SendMessage, TB_GETBUTTON, i-1, pProc,, ahk_id %hctrl%

		VarSetCapacity(BTN,32), DllCall("ReadProcessMemory", "Uint", hProc, "Uint", pProc, "Uint", &BTN, "Uint", 32, "Uint", 0)
		if !(dwData := NumGet(BTN,12))
			dwData := NumGet(BTN,16,"int64")

		VarSetCapacity(NFO,32), DllCall("ReadProcessMemory", "Uint", hProc, "Uint", dwData, "Uint", &NFO, "Uint", 32, "Uint", 0)
		if NumGet(BTN,12)
			 w := NumGet(NFO, 0),		   o := NumGet(NFO, 20)
		else w := NumGet(NFO, 0, "int64"), o := NumGet(NFO, 24)
		ifEqual, w, 0, continue

		WinGet, n, ProcessName, ahk_id %w%
		WinGet, p, PID, ahk_id %w%
		WinGetTitle, t, ahk_id %w%
		
		if !Filter || bPos || (bName && Filter=n) || (bPid && Filter=p) || (bId && Filter=w) {
			loop, parse, pQ
				f := A_LoopField, res .= %f% sep
			res := SubStr(res, 1, -1) "`n"		
		}
	}
	DllCall("VirtualFreeEx", "Uint", hProc, "Uint", pProc, "Uint", 0, "Uint", 0x8000), DllCall("CloseHandle", "Uint", hProc)
	
	if (bPos)
		loop, parse, pQ
			o%A_Index% := %A_LoopField%

	DetectHiddenWindows,  %oldDetect%
	return SubStr(res, 1, -1)
}

Taskbar_getTaskBar(){
	ControlGet, hParent, HWND,,MSTaskSwWClass1, ahk_class Shell_TrayWnd
	ControlGet, h , hWnd,, ToolbarWindow321, ahk_id %hParent%
	return h
}