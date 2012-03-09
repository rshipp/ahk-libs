#NoEnv
#SingleInstance, force
SetBatchLines, -1

	Gui, +LastFound +Resize 
	hGui := WinExist() 
	Gui, Show, w600 h300 hide

  ;create edit
	Gui, Add, Edit, HWNDhLog w400 h100, F1 - Maximize band 1`nF2 - Maximize band 2`nF3 - Toggle titles`n`nClick band title or separator to animate

  ;create combo
	Gui, Add, ComboBox, gOnCombo HWNDhCombo w0, item 1 |item 2|item 3

	hRebar := Rebar_Add(hGui, "fixedorder", "", "")	
	ReBar_Insert(hRebar, hLog, "S gripperalways", "T log")
	ReBar_Insert(hRebar, hCombo, "mW 0", "L 100", "T combo") ; "BG bg.bmp")

	Gui, Show
return

F2::
F1::
	Rebar_SetBandState(hRebar, SubStr(A_ThisHotKey, 2), "+")
return

OnCombo:
  msgbox Combo Event
return

F3::
	titlesOff := !titlesOff
	loop, % Rebar_Count(hRebar)
		Rebar_SetBandStyle(hRebar, A_Index, (titlesOff ? "" : "-") "hidetitle")

GuiSize:
	Rebar_ShowBand(hRebar, 1)	;simiarl to autosize, will resize to width
	Rebar_SetBand(hRebar, 1, "mH " A_GuiHeight)
return

GuiEscape:
GuiClose:
	ExitApp
return

#include ..\..\inc
#include _Forms.ahk