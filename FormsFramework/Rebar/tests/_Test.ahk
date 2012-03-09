#Singleinstance, force 
#NoEnv
SetBatchLines, -1
DetectHiddenWindows, On

	Gui, +LastFound +Resize 
	hGui := WinExist() 
	Gui, Show, w600 h300 hide

	Gui, Font,, Courier New

  ;create image list
	hIL := IL_Create(10, 0, 1) 
	loop, 20
	   IL_ADD(hIL, A_WinDir "\system32\shell32.dll", A_Index) 

  ;create edit
	Gui, Add, Edit, HWNDhLog w100 h100

  ;create combo
	Gui, Add, ComboBox, HWNDhCombo gOnCombo w80, item 1|item 2|item 3
  
  ;create toolbar
	hToolbar := Toolbar_Add(hGui, "OnToolbar", "FLAT WRAPABLE", 1, "x0")
	Toolbar_Insert(hToolbar, "123`nabc`n123`nabc`n`n123`nabc`n123`nabc`n")
	Toolbar_AutoSize(hToolbar, "fit")

  ;create toolbar menu
	hMenu := Toolbar_Add(hGui, "OnToolbar", "menu transparent" , 0,"x0")
	Toolbar_Insert(hMenu, "Reload,`nExit`nHelp")
	Toolbar_AutoSize(hMenu, "fit")

  ;create rebar	
	hRebar := Rebar_Add(hGui, "", hIL, "", "OnRebar")	
	ReBar_Insert(hRebar, hLog, "mw 500", "L 400", "T Log")
	ReBar_Insert(hRebar, hCombo, "L 300", "I 4", "T dir")
	ReBar_Insert(hRebar, hToolbar, "mW 45", "S usechevron", "BG bg.bmp" )
	ReBar_Insert(hRebar, hMenu, "mW 45", "P 1", "S usechevron")

	layout := "10002 356 0|10003 214 0|10001 400 1|10004 290 1"
	Rebar_SetLayout(hRebar, layout)

  ;create notepad
;	Run, Notepad,,Hide
;	winwait, Untitled
;	hNotepad := WinExist("Untitled")
;	WinSet, Style, -0xC00000, ahk_id %hNotepad%
;	WinSet, Style, -0x40000, ahk_id %hNotepad%
;	reNotepad := Rebar_Insert(hRebar, hNotepad, "L 300", "mh 140", "T Note", "I 17")

  ;Add other GUI controls
	h := Rebar_Height(hRebar)+90

	Gui, Font, s8
	Gui, Add, Text, y%h% x2 , F1 to recall initial layout   F2 to toggle lock   F3 to show layout
	Gui, Add, Text, y+10 x2 , F4 to load layout from Log
	Gui, Show

	;Rebar_ShowBand(hRebar, reNotepad, false)	;for redrawing notepad
 	;Rebar_ShowBand(hRebar, reNotepad, true)
return 

OnRebar(hCtrl, e){
	static L="Layout change (L)", H="Height change (H)", C="Chevron pushed (C)"
	e := %e%
	Log("Rebar event: " e)
}

#IfWinActive, _Test
F1::
;	layout := "10001 120 1|10003 243 0|10002 370 1|10004 230 1"
	layout := "10002 356 0|10003 214 0|10001 400 1|10004 290 1"
	Rebar_SetLayout(hRebar, layout)
return

F2::
;	Rebar_Lock(hRebar, "~")
		ReBar_SetBand(hRebar, id, "S hidden")
return

F3::
	Log(Rebar_GetLayout(hRebar))
return

F4::
	ControlGetText, layout, ,ahk_id %hLog%
	Rebar_SetLayout(hRebar, layout)
return


OnToolbar(hToolbar, Event, Text, Position, Id){
	global hMenu
	ifEqual, event, hot, return
	
	if (hToolbar != hMenu)
		return Log(Event " " Text)
	
	if Text = Reload
		Reload
	
	if Text = Exit
		ExitApp
	
	if Text = Help
		Run, Rebar.html
} 

GuiClose:
	WinClose, ahk_id %hNotepad%
	ExitApp
return

GuiSize:
	Rebar_ShowBand(hRebar, 1)
return

OnCombo:
	Log( "Combo event: " A_GuiControl )
return

Log(txt){
	global hLog
	ControlSetText, , %txt%, ahk_id %hLog% 
}

F6::

return

#include ..\Rebar.ahk
#include ..\..\Toolbar\Toolbar.ahk