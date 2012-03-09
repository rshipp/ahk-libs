;_("m! w e d")
#SingleInstance, force
SetWinDelay, -1

	;===============================

	Gui, +LastFound +Resize
	hGui := WinExist()

	Gui, Show, w500 h600 Hide

	Gui, Add, Edit,		HWNDhEdit, F1 - hide`nF2 - show
	hSplit := Splitter_Add()
	Gui, Add, ListView,	HWNDhList, Top control
	Gui, Add, Text,		h100 0x200 HWNDhText,  Bottom
	Gui, Add, MonthCal, HWNDhCal	

	sdef = %hEdit% | %hList% %hText% %hCal%			;vertical splitter.
	IniRead, spos, config.ini, Config, Splitter, %A_Space%
	ifEqual, spos, ,SetEnv, spos, 100
	Splitter_Set( hSplit, sdef, spos )
	
	Align(hEdit,  "L", spos),			Attach(hEdit,	"h")
	Align(hSplit, "L", 6)	,			Attach(hSplit,	"h")
	Align(hList,  "T", 200) ,			Attach(hList,	"w")
	Align(hText,  "B")		,			Attach(hText,	"y w")
	Align(hCal,   "F")		,			Attach(hCal,	"w h")

	IniRead, bVisible, config.ini, Config, Visible, %A_Space%
	IfEqual, bVisible, , SetEnv, bVisible, 1
	if !bVisible
		HideControls(true)

	if !Win_Recall("<", "", "config.ini")
		Gui, Show
return

F1:: HideControls(true)
F2:: HideControls(false)
F3:: Attach()

HideControls(bHide) {
	global 
	if (!bHide)
	{
		WinShow, ahk_id %hText%
		WinShow, ahk_id %hEdit%	
	} else {
		WinHide, ahk_id %hText%
		WinHide, ahk_id %hEdit%	
	}
	Align(hGui)		;re-align (it will reset attach automatically if present among includes)
}

SaveGui() {
	global 
	b := Win_Is(hText, "visible")
	if !b
		HideControls(false)

	p := Splitter_GetPos(hSplit)
	
	Win_Recall(">", "", "config.ini")
	IniWrite, %p%, config.ini, Config, Splitter
	IniWrite, %b%, config.ini, Config, Visible
}

Esc:: 
GuiClose:
	SaveGui()
	ExitApp
return

#include ..\Align.ahk
#include ..\..\Win\Win.ahk

;sample includes
#include ..\..\Attach\Attach.ahk
#include ..\..\Splitter\Splitter.ahk