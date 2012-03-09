SetBatchLines, -1
#SingleInstance, 
		Sort()
return

Sort(type="R") {
	static WM_SETREDRAW=0xB 
	h := Taskbar_GetHandle()
	SendMessage, WM_SETREDRAW, 0, , , ahk_id %h%
	loop, % Taskbar_Count() // 2
	{
		s := btns := Taskbar_Define("", "ti") "`n"

		Sort, s, %type%
		s := RegExReplace( s, "([^\n]*+\n){" A_Index-1 "}", "", "", 1 )
		s := SubStr(s, 1, InStr(S, "`n")-1)
		StringSplit, w, s, |
		Taskbar_Move( w2, 2 )
	}
	SendMessage, WM_SETREDRAW, 1, , , ahk_id %h%
}

#include ..\Taskbar.ahk
