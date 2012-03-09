;_("mo! e d")
SetBatchLines, -1
CoordMode, mouse, screen
#singleinstance, force
;	old := AppBar_SetTaskbar("disable")
	OnExit, OnExit
	Gui,  +LastFound +AlwaysOnTop Toolwindow
	hGui := WinExist() + 0

	loop, 3
		Tray_Add(hGui, "OnTrayIcon", "shell32.dll:" A_Index, "AHK tray icon " A_Index)
	OnMessage(0x200, "OnMouseMove")

	loop, 20
		Gui, Add, Picture, yp x+20 w20 h20 0x3 HWNDh%A_Index% gOnPicture

	RefreshTray()
	SetTimer, RefreshTray, 1000

	gui, show, y0 w600 h50
return

ESC:: GoSub OnExit


RefreshTray(){
	s := Tray_Define("", "o")
	loop, parse, s, `n
		SetIcon(A_Index, A_LoopField), c := A_Index

	c++
	loop, % 20-c
		SetIcon(c+A_Index-1, 0)
}

RefreshTray:
	RefreshTray()
return

GuiContextMenu:
OnPicture:
	MouseGetPos,,,,c
	StringReplace, c, c, static
	Tray_Define(c, "inhwm", pos, name, handle, parent, msg)
;	tip := Tray_GetTooltip(c)
;	msgbox Pos: %pos%  Handle: %handle%  Parent: %parent%  Name: %name%`nMsg:%msg%`nTooltip:%tip% 

	dbl := GetKeyState("Shift")
	button := dbl ? "Ld" : A_ThisLabel="OnPicture" ? "L" : "R"
	Tray_Click(pos,  button) 
return	


OnMouseMove(wparam, lparam){
	global
	MouseGetPos,,,,c
	if c contains Static
	{
		StringReplace, c, c, static
		ShowTooltip( Tray_GetTooltip(c) )
	}
}


SetIcon(Pos, hIcon){
	global
	GuiControlGet hPic, HWND, Static%pos%
	SendMessage, 0x172, 0x1, hIcon, , ahk_id %hPic%
}
																				   
OnTrayIcon(Hwnd, Event) {
	global

	if event not in R,M,L	;return if event is not right click
		return                                                                       
					
	MsgBox, ,Icon %Hwnd%, %EVENT% Button clicked.`n`nPress ESC to exit script. Press F2 to remove all script tray icons.
	Tray_Focus(hGui, Hwnd)
}                 

OnExit:
;	if old != 
;		Appbar_SetTaskBar( old )
	Tray_Remove(hGui)
	ExitApp
return

F1:: MoveAhkIcons()
F2:: Tray_Remove(hGui)
F3:: ShowAllTooltips()



ShowAllTooltips(){
	s := Tray_Define()
	loop, parse, s, `n
		r .= A_Index " " Tray_GetTooltip(A_Index) "`n"
	msgbox %r%
}

MoveAhkIcons(){
	;put ahk icons at the end
	s := Tray_Define("autohotkey.exe", "i")
	loop, parse, s, `n
		Tray_Move(A_LoopField+1 - A_Index)
}

ShowTooltip( Msg, X="" ,Y="", TimeIn=500, TimeOut=1500){
	static 
	_Msg := Msg, _X:=X, _Y:=Y
	MouseGetPos, , , , _ctrl

	t1 := -TimeIn, t2 := -TimeOut
	SetTimer, ShowTooltipOn, %t1%
	return

 ShowTooltipOff:
	Tooltip, , , , 19
 return

 ShowTooltipOn:
	SetTimer, ShowTooltipOff, %t2%
	MouseGetPos, , , , ctrl
	ifNotEqual, ctrl, %_ctrl%, return
	Tooltip,%_Msg% , _X, _Y, 19
 return
}

#include ..\Tray.ahk