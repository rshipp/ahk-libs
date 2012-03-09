#SingleInstance, force
SetBatchLines, -1
;#MaxThreads, 255

	ctrls = Edit Text Radio CheckBox ListBox ComboBox DropDownList ListView TreeView
	FG	  = White
	BG	  = Blue
	;========================

	Gui, +LastFound +Resize
	hGui := WInExist()

	loop, parse, ctrls, %A_Space%
	{
		Gui, Add, Text, xm w150, %A_LoopField%
		Gui, Add, %A_LoopField%, HWNDh x+10 h80 w200 cWhite, Test1|Test2
		CColor(h, BG, FG), Attach(h, "w")
	}
	
	Attach(h, "w h")
	LV_ADD("", "Test1"), TV_Add("Test1")
	LV_ADD("", "Test2"), TV_Add("Test2")
	Gui, Show, autosize
	WinSet, Redraw
return

F12::
	if hidden
		 WinShow, ahk_id %hGui%
	else WinHide, ahk_id %hGui%
	hidden := !hidden
return

GuiClose:
GuiEscape:
	Exitapp
return

#include ..\CColor.ahk
#include ..\..\Attach\Attach.ahk