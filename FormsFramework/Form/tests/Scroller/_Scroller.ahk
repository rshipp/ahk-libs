_("mo!")
	hForm  := Form_New("Resize e3 w500 h400")

	hPanel := Form_Add(hForm, "Panel", "", "x250 y20 w150 h300")
	loop, 2
	{
		bPanel := A_Index = 2
		Loop, 10
			Form_Add(bPanel ? hPanel : hForm, "Edit", "Edit " bPanel "." A_Index, "vscroll R5 H100 W200")
		Form_Add(bPanel ? hPanel : hForm, "Text", "Footer")
	}
	hp := Form_Add(hPanel, "Panel", "", "w200 h100 style='scroll frame'")
	Form_Add(hP, "Edit", "", "x0 y0 w250 h300")
	
	Panel_SetStyle(hPanel, "scroll")
	Scroller_UpdateBars(hP)

	Scroller_init()	
	Form_Show()
return 


Form1_Close:
	ExitApp
return

Form1_Size:
	Scroller_UpdateBars(hForm)
return

#include ..\..\inc
#include _Forms.ahk