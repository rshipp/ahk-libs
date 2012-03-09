SetBatchLines, -1
#SingleInstance, force
	Gui, Font, s10, Courier New
	Gui, Add, ListView, altsubmit gOnList w600 h100, handle|title|path
	Gui, Add, Edit,	w600 h200 -Wrap,
	Gui, Add, Text, y+20 w600 center, Control
	Gui, Add, Text, ,path
	Gui, Add, Edit,	x+5 w200, 
	Gui, Add, Text, x+20,view
	Gui, Add, Edit,	x+5 w20, 
	Gui, Add, Text, x+20,sel
	Gui, Add, Edit,	x+5 w40, 
	Gui, Add, Button, gOnSet x+50, set
	Gui, Show, autosize
	COM_Init()
	Refresh()
	Settimer, Refresh, 2000
return

OnSet:
	ControlGetText, txt1, edit2, A
	ControlGetText, txt2, edit3, A
	ControlGetText, txt3, edit4, A

	if txt1 != 
		Shell_ESetPath(THIS, txt1)
	
	if txt2 !=
		Shell_ESetVIew(THIS, txt2)

	if txt3 !=
		 s := Shell_ESelectItem(THIS, txt3)


	Refresh()
	GetInfo(THIS)
return

GetInfo(hwnd){

	res := "HWND: " hwnd "`r`n"
		.  "PATH: " Shell_EGetPath( Hwnd ) "`r`n"
		.  "ITEM COUNT: " Shell_EGetCount(hwnd) "`r`n"
		.  "VIEW: " View(v:=Shell_EGetView( Hwnd ))	 "(" v ")`r`n"
		.  "SELECTED: `r`n`r`n" 
	s :=  Shell_EGetSelection( Hwnd ) 
	STringReplace, s, s, `n, `r`n, A
	res .= s
	
	ControlSetText, Edit1, %res%

}

View( num ) {
	static VIEW1 ="ICON",VIEW2 ="SMALLICON",VIEW3 ="LIST",VIEW4 ="DETAILS",VIEW5 ="THUMBNAIL",VIEW6 ="TILE",VIEW7 ="THUMBSTRIP "
	s := VIEW%num%

	return s
}

Refresh:
	 Refresh()
return

OnList:
	  if (A_GuiEvent != "Normal")
		return
	 LV_GetText(THIS, A_EventInfo)
	 GetInfo(THIS)
return

Refresh() {
	WinGet, cabinet_c, List, ahk_class CabinetWClass 
	WinGet, explorer_e, List, ahk_class ExploreWClass
	LV_Delete()

	if explorer_e+cabinet_c = 0
		return LV_Add("", "", "No instance of Explorer found", "Auto Refreshing..."), 	LV_ModifyCol()

	loop, %explorer_e%
	{
		id := explorer_e%A_Index%

		WinGetTitle, t, ahk_id %id%
		LV_Add("", id, t, Shell_EGetPath( id ))
	}

	loop, %cabinet_c%
	{
		id := cabinet_c%A_Index%

		WinGetTitle, t, ahk_id %id%
		LV_Add("", id, t, Shell_EGetPath( id ))
	}

	LV_ModifyCol()

}


#include Shell.ahk