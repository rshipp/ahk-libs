_("mo! d e")
SetWorkingDir ..\..\inc

	hForm1	:=	Form_New("w400 e3 h300 +Resize ")

	hForm2 := Form_New("w300 h200 e1 +Resize +ToolWindow -Sysmenu ")
	SetProperties(hProp := Form_Add(hForm2, "Property", "", "", "Align F", "Attach p"))
	Property_SetColSize(hProp, 150)

	hForm3 := Form_New("w150 h140 e1 +ToolWindow  -Sysmenu -Caption")
	Form_Add(hForm3, "SpreadSheet", "", "", "Align F", "Attach h w")

	DockA(hForm1, hForm2, "x(1) y() h(1)")
	DockA(hForm1, hForm3, "x(,,-24) y(,,30) w(1,20)")
	DockA(hForm1)

	ShowForms(true)
	OnMessage(0x47, "a") ;WM_WINDOWPOSCHANGED 
return

Form1_Size:
	DockA( hForm1 )
return

a(w,LParam,m,h){
	global

	if	(h = hForm2)
	{
		WinGetPos hX, hY, hW,, ahk_id %hForm1%
		WinGetPos cX, cY,,, ahk_id %h%
		DockA(hForm1, h, "x(1,," cX-(hX+hW) ") y() h(1)")
	}
}


Form1_Close:
	ShowForms(false)
return

Form2_Size:
	Property_SetColSize(hProp, 150)
return

Form2_ContextMenu:
	ShowMenu("[cm]`nset left|set right|set top|set bottom", "", "", "|")
return

ShowForms(BShow) {
	global

	if BShow
		DockA(hForm1)

	loop,3
		if BShow
			 Form_Show(hForm%A_Index%)
		else Form_Hide(hForm%A_Index%)
}

SetProperties(hCtrl){
	p = 
		 (LTrim
			Name=My Checkbox
			Type=CheckBox
			Value=is that ok ?
			Param=0

			Name=My Separator
			Type=Separator
			Value=25
			
			Name=My Button
			Type=Button
			Value=click me
			
			Name=My Text
			Type=Text
			Value=default text
			
			Name=Some longer fat separator
			Type=Separator
			Value=55
			
			Name=My HyperLink
			Type=HyperLink
			Value=www.autohotkey.com
			
			Name=My WideButton
			Type=WideButton
			Value=click me
			
			Name=Digit
			Type=Integer
			Value=3
				
			Name=My Combo
			Type=ComboBox
			Value=1|2|3
		)
		Property_initSheet(hCtrl)	;must be done in panel ... will fix it...
		Property_SetColors(hCtrl, "pbAAEEAA sbaaeeaa sffff")
		Property_SetFont(hCtrl, "Separator", "bold s9, verdana")
		Property_SetRowHeight(hCtrl, 25)
		Property_Insert(HCtrl, p)
}

F1:: 
	ShowForms(true)
return

F2::
	DockA(hForm1)
return

F3::
	DockA(hForm1, hForm2, "-")
return

F4::
	DockA(hForm1, hForm2, "")
return

#include ..\..\inc
#include _Forms.ahk
