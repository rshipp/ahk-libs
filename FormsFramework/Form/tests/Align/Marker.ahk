_("mo w e d")
	Gui, +LastFound
	hGui := WinExist()
	hGui := Panel_Add(hGui, 0, 0, 500, 500)

	Gui, Show, w500 h500 Hide

	;Gui, Add, ListView,	HWNDhMarker x100 y100 w300 h300, 
	hMarker := Panel_Add(hGui, 100, 100, 300, 300, "hidden", "panel")

	loop, 5
	{
		Gui, Add, Button, HWNDhb%A_Index%, B%A_Index%
		Win_SetParent(hb%A_Index%, hGui)
	}

	Align(hb1, "T", 60, hMarker)
	Align(hb2, "B", 20, hMarker)
	Align(hb3, "L", 90, hMarker)	
	Align(hb4, "R", 50, hMarker)	
	Align(hb5, "F", "", hMarker)	

	Gui, SHow,
return

GuiClose:
GuiEscape:
	ExitApp
return


#include ..\..\inc
#include _Forms.ahk