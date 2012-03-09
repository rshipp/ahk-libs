;_("mo!")
SetBatchLines, -1
#SingleInstance, force 

	Gui, +LastFound 
	Gui, Add, Edit, vMyEdit1  w160
	Gui, Add, Edit, x+0 vMyEdit2  w160

	Gui, Font, ,Webdings
	Gui, Add, Button, HWNDhBtn x+5 gCxLV w24 h25 0x8000, 6
	Gui, Font, 
	
	Gui, Add, Edit, xm vMainEdit xm w350 h250


	Gui, Add, ListView, HWNDhcxLV w348 h190 x20 y28 -Hdr, Font|Style 
	FillTheList()
	ComboX_Set( hcxLV, "2RD esc space enter click " hbtn+0, "OnComboX")
	
	Gui, Add, MonthCal, border HWNDhcxCal vMyCal w270 h200 xm y+3
	Gui, Add, Button, HWNDhBtn2 gCxCal x360 y260 ,D
	ComboX_Set( hcxCal, "4RU enter space " hbtn2+0, "OnComboX")
	FillTheTreeView()
	
	Gui, Show, autosize, ComboX Test
return 


OnComboX(Hwnd, Event) {
	global 
	if (Event != "select")
		return

	if (Hwnd = hcxCal)  {
		Gui, Submit, NoHide
		FormatTime, MyCal, %MyCal%, MMMM dddd, dd.MM.yyyy
		ControlSetText, Edit3, %MyCal%, A
	}

	if (Hwnd = hcxLV) {
		r :=  LV_GetNext()
		LV_GetText(font, r, 1)
		LV_GetText(style, r, 2)
		ControlSetText, Edit1, %font%, A
		ControlSetText, Edit2, %style%, A
	}
}

FillTheList() {	

	LV_Add("", "Verdana", "s22 bold")
    LV_Add("", "Courier New", "s10")
    LV_Add("", "Times New Roman", "s10 italic underline")
    LV_Add("", "Arial Narrow", "s32")
    LV_Add("", "Comic Sans MS", "s14")
    LV_Add("", "Arial Bold", "s12")
    LV_Add("", "Terminal", "s12 strikeout italic")
    LV_Add("", "Webdings", "s22")

	ControlGetPos,, ,w, ,Edit1
	LV_ModifyCol(1,w-2),   LV_ModifyCol(2, "Auto")
}

FillTheTreeView() {
	loop, 10
		TV_ADD(A_Index)
}


CxLV:
	ComboX_Show(hcxLV)
return


F1::
	ComboX_Toggle(hcxCal)
return 

CxCal:
	ComboX_Show(hcxCal)
return


#include ..\ComboX.ahk
#include ..\..\Win\Win.ahk