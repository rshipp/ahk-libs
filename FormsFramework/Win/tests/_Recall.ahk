;_("mo!"), _ := " "
#SingleInstance, force
MakeGui:
	n++
	Gui, %n%:+Resize +LastFound
	Hwnd := WinExist(), %Hwnd% := n

	Gui, %n%:Add, Button, w205 xm gOnbutton, New Gui (F1)
	Gui, %n%:Add, Text, w205 xm gOnbutton, Esc to exit

	Gui, %n%:Add, Button, w100 y+50 gOnbutton, Save (F2)
	Gui, %n%:Add, Button, w100 yp x+5 gOnbutton, Recall (F3)
	Gui, %n%:Add, Button, w100 xm	 gOnbutton, Save All 
	Gui, %n%:Add, Button, w100 yp x+5 gOnbutton, Recall All (F4)
	
	WinSetTitle, Gui %n%
	if !Win_Recall("<" n, Hwnd, "config.ini")
	{
		Gui, %n%:Show, autosize, Gui %n%
		WinWaitActive
		if (n > 1)
			Win_MoveDelta(Hwnd, n*20)	
	}
return

F1:: goto MakeGui
F2:: Hwnd := WinExist("A"), Win_Recall(">" %Hwnd%  Hwnd, "config.ini")
F3:: Hwnd := WinExist("A"), Win_Recall("<" %Hwnd%, Hwnd, "config.ini")
F4:: Win_Recall("<<")
F5:: Reload

OnButton:
	if A_GuiControl contains F1
		goto MakeGui
	if A_GuiControl contains F2
		 Win_Recall(">" A_Gui, A_Gui, "config.ini")
	else if A_GuiControl contains F3 
		 Win_Recall("<" A_Gui, A_Gui, "config.ini")
	else if A_GuiControl contains F4
		 Win_Recall("<<", "", "config.ini")
	else Win_Recall(">>", "", "config.ini")
return

ESC::
	Win_Recall(">>", "", "config.ini")
	ExitApp
return

#include ..\Win.ahk