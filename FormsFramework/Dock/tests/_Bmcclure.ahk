SetBatchLines, -1	  
DetectHiddenWIndows, on
#SingleInstance, force
CoordMode, mouse, screen
	

	Run, Notepad
	WinWait, Untitled
	Send !Fp
	Send !n
	sleep 100
	host := "Print ahk_class #32770"

	Gui +LastFound +ToolWIndow -Caption
	c1 := WinExist()
	Gui, Add, Button, gOnBtn 0x8000, something
	Gui, Add, Button,gOnBtn x+10 0x8000, something 2
	Gui, Add, Button, gOnBtn x+10 0x8000, %c1%
	Gui, Add, DropDownList, xm gOnBtn  0x8000, 1|2|3|5
	Gui, Add, Text, xm yp+100 gOnBtn  0x8000, Press F12 to toggle dock on/off

	Dock_OnHostDeath := "OnHostDeath"
 	Dock(c1), tgl := 1
return								 

F12::
	if tgl 
	{
 		 Dock(c1, "-")
		 WinHide, ahk_id %c1%
	}
	else {
		Dock(c1, def)
	}
	
	tgl := Dock_Toggle()
return


FindTC:
	if Dock_HostID := WinExist(host)
	{
		SetTimer, FindTC, OFF
		WinGetPos, ,, w, h, ahk_id %Dock_HostID%
		x:=10, y:=55, h-=105,  w-=30 
		def = x(,,%x%) y(,,%y%) w(,%w%) h(,%h%) t
 		Dock( c1, def)
		Dock_Toggle(true)
	}						
return

OnBtn:
;	WinActivate, ahk_id %Dock_HostId%
;	sleep 5
	s := A_GuiControl " "
	Control, EditPaste, %s%, Edit1, ahk_id %Dock_HOstID%

;	Send, %A_GuiControl%
return


OnHostDeath:
	SetTimer, FindTC, 50
return

#include ..\Dock.ahk