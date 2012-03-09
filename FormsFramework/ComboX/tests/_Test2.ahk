#NoEnv
#SingleInstance Force  
SetBatchLines -1 
DetectHiddenWindows, on
CoordMode, mouse, screen

	Gui, +LastFound  +Resize
	Gui, Font, s6
	Gui, Add, ListView, x10 w400 h300 hwndhLV gOnListView, Column 1|Column 2|Column 3
	Gui, Add, Edit, hwndhED vvED, input1|input2|input3		;this will become ComboX 

	FillTheList() 

	ComboX_Set( hED, "esc enter", "OnComboX") 
	Attach(hLV, "w h r2")

	Gui, Show, autosize, ComboX In Cell Editing Test 
return 

SetComboPosition(HwndLV, HwndCombo) {	
	global gColNumber

	MouseGetPos, mx

	sbx := DllCall("GetScrollPos", "UInt", HwndLv, "Int", 0)  
	Win_GetRect(HwndLv, "xywh", lx, ly, lw, lh)
	LV_ItemRect(HwndLV, LV_GetNext(), i1, i2, i3, i4)
	
	x := lx-sbx
	loop, % LV_GetCount("Column")
	{
		w := LV_ColumnWidth(HwndLV, A_Index)
		if (x+w > mx) 
		{
			gColNumber := A_Index
			break
		} else x+=w
	}
	w := LV_ColumnWidth(HwndLV, gColNumber)

	y := ly+i2+1,  h := i4-i2
	Win_Move(HwndCombo,x,y,w,h)
}

ShowCombo(){
	global
	SetComboPosition(hLV, hEd)
	LV_GetText(txt, LV_GetNext(), gColNumber)
	ComboX_Show(hEd)
	ControlSetText,,%txt%, ahk_id %hEd%
	SendInput {End}^a
}

OnComboX(Hwnd, Event) { 
	if (Event != "hide") 
		return

	LV_SetColumnValue()
} 

OnListView: 
	if A_GuiControlEvent = DoubleClick 
		ShowCombo() 
return 

FillTheList() {    
	loop, 100
	    LV_Add("", "Value 1." A_Index, "Longer Value 2." A_Index, "Some Slightly Longer Value 3." A_Index, A_Index) 
  
	loop, 3
	    LV_ModifyCol(A_Index,"Auto") 
} 

;====================================================================================================

LV_SetColumnValue() {
	global 

	ControlGetText, value, , ahk_id %hED%	
	LV_Modify(LV_GetNext(), "Col" gColNumber , value) 
}

LV_ColumnWidth(HwndLV, Col=1) {
	static LVM_GETCOLUMNWIDTH=4125
	SendMessage, LVM_GETCOLUMNWIDTH, Col-1,,,ahk_id %HwndLV%
	return ErrorLevel
}

LV_ItemRect(HwndLV, Row, ByRef p1, ByRef p2, ByRef p3, ByRef p4) {
	static LVM_GETITEMRECT=4110

	VarSetCapacity(RECT, 16, 0), NumPut(3, RECT)
	SendMessage, LVM_GETITEMRECT, Row-1, &RECT,, ahk_id %HwndLv%
	res := ErrorLevel
	loop, 4
		p%A_Index% := NumGet(RECT, A_Index*4-4)
	return ErrorLevel
}

#include ..\ComboX.ahk
#include ..\..\Attach\Attach.ahk   ;sample include
#include ..\..\Win\Win.ahk