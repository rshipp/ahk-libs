_()

GetWindows() {
	if not EnumAddress 
		EnumAddress := RegisterCallback("EnumWindowsProc", "Fast")
	DetectHiddenWindows On  
	DllCall("EnumWindows", UInt, EnumAddress, UInt, 0)
return
	
EnumWindowsProc(hwnd, lParam){
    global Output
;	WS_EX_APPWINDOW = 0x40000

    WinGetTitle, title, ahk_id %hwnd%
    WinGetClass, class, ahk_id %hwnd%
	if Win_Get(hwnd, "O") = 0
	{
		WinGet, s, Style, ahk_id %hwnd%
;		if (s & WS_EX_APPWINDOW)
			if Win_Is(hwnd, "visible")	
				if class not in Shell_TrayWnd,Progman
					Output .= "HWND: " . hwnd . "`tTitle: " . title . "`tClass: " . class . "`n"

	}
    return true  ; Tell EnumWindows() to continue until all windows have been enumerated.
}


System_GetWindowIcon(pHandle, pLarge=true)
{
	local hIcon

	if (pLarge)
		 SendMessage, WM_GETICON, ICON_BIG  , 0,, ahk_id %pHandle%
	else SendMessage, WM_GETICON, ICON_SMALL, 0,, ahk_id %pHandle%
	hIcon := ErrorLevel 
			
	if !hIcon
	{ 
		SendMessage, WM_GETICON, ICON_SMALL, 0,, ahk_id %pHandle%
		hIcon := ErrorLevel
		if !hIcon
		{ 
			hIcon := DllCall( "GetClassLong", "uint", pHandle, "int", GCL_HICONSM )
			if !hIcon
				hIcon := DllCall("LoadIcon", "uint", 0, "uint", IDI_APPLICATION ) ; 
		} 
	} 

	return hIcon
}
