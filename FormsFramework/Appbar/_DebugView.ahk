	DetectHiddenWindows, on
	OnExit, OnExit
	hDbg := WinExist("ahk_class dbgviewClass")
	if !hDbg
	{
		Run, DbgView, , ,PID
		WinWait, ahk_class dbgviewClass
		bClose := hDbg := WinExist("ahk_pid " pid)		
	}
	AppBar_New(hDbg,  "Edge=Right", "Pos=p-320", "AutoHide=Blend")
	Win_SetCaption(hDbg, "-"), Win_SetMenu(hDbg)
return

OnExit:
	if bClose
		WinClose, ahk_id %hDbg%
	ExitApp
return

#include %A_ScriptDir%
#include AppBar.ahk
#include Taskbar\Win.ahk
#include Taskbar\_.ahk
