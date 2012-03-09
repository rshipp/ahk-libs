#Persistent 
SetBatchLines, -1 
	if !Shell_SetHook("OnShell"){
		 msgbox Can't register hook. Aborting!
		 ExitApp
	}
	else msgbox Hook installed. `nF2 - Save active window location`nESC-Exit.
return

ESC:: ExitApp

F2::
	hwnd := WinExist("A")
	WinGetClass, cls, ahk_id %hwnd%
	Win_Recall(">" cls, hwnd, "config.ini")
	msgbox Saved under %cls%
return

OnShell(Reason, Param) {	
	static WINDOWCREATED=1, WINDOWDESTROYED=2, WINDOWACTIVATED=4, GETMINRECT=5, REDRAW=6, TASKMAN=7, APPCOMMAND=12

	if (Reason = WINDOWCREATED)  
	{ 
		WinGetClass, cls, ahk_id %Param%
		p := Win_Recall("<" cls, Param, "config.ini")
		if p != 
			msgbox recalled:  %cls%
	} 
} 

Shell_SetHook(Handler) {
	oldDetect := A_DetectHiddenWindows
	DetectHiddenWindows, on
	Process, Exist
	h := WinExist("ahk_pid " ErrorLevel)
	DetectHiddenWindows, %oldDetect%

	if !DllCall("RegisterShellHookWindow", "UInt", h) 
		return 0
	return OnMessage(DllCall( "RegisterWindowMessage", "str", "SHELLHOOK") , Handler)
}

#include ..\..\inc
#include _Forms.ahk