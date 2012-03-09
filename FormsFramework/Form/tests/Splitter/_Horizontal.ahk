#SingleInstance, force

	ssize	:= 30			;splitter size
	spos	:= 100			;initial position

	;=========================================

	pos := Win_Recall("<", 0, "config.ini")
	if (pos != "") {	
			StringSplit, p, pos, %A_Space%
			x:= p1, y:=p2,  w:=p6,  h:=p7
	} else 	x:=y:="Center", w:=600, h:=500

	h1 := spos,	 h2 := h-h1-ssize


	gui, margin, 0, 0
	Gui +Resize +LastFound ;-Caption
	hGui := WinExist()
	Menu, mnu, Add, File
	Gui, Menu, mnu


	gui, add, edit, HWNDhc1 w%w% h%h1%, ESC - exit and save window.`nF1 - Set splitter position to 50`%`nRight click on splitter to move to ending positions.`nDouble click on splitter for the menu.
	hSep := Splitter_Add("h" ssize " w" w " center sunken", "drag me", "OnSplitter")
	w1 := w//2, h2-=30
	gui, add, monthcal, HWNDhc2 w%w1% h%h2%
	gui, add, monthcal, HWNDhc3 x+0 w%w1% h%h2%
	gui, add, statusbar, , 123

	IniRead, spos, config.ini, Config, Splitter, %A_Space%
	Splitter_Set( hSep, hc1 " - " hc2 " " hc3, spos, 30.100)

	Attach( hc1,  "w h r2")
	Attach( hSep, "y w r2")
	Attach( hc2,  "y w.5 r2")
	Attach( hc3,  "y x.5 w.5 r2")

	Gui, Show, x%x% y%y% w%w% h%h%
return

File:
return

OnSplitter(HCtrl, Event, Pos){
	if Event = R
	{
		min := Splitter_GetMin(HCtrl),	max := Splitter_GetMax(HCtrl)
		Pos := Pos=min ? max : min
		Splitter_SetPos(HCtrl, Pos)
	}

	if Event = D
		return ShowMenu("[Splitter_Menu]`n0`n10`n20`n30`n40`n50`n60`n70`n80`n90`n100")
		
	txt = position: %pos%
	ControlSetText, ,%txt%, ahk_id %HCtrl%
}

Splitter_Menu:
	Splitter_SetPos(HSep, A_ThisMenuItem "%")
return

F1::
	Splitter_SetPos(hSep, 50 "%")
return


Esc:: 
GuiClose:
	Win_Recall(">", "", "config.ini")
	p := Splitter_GetPos(hSep)
	IniWrite, %p%, config.ini, Config, Splitter
	ExitApp
return

#include ..\..\inc
#include _Forms.ahk