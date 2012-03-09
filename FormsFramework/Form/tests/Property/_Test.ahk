;_("m d")

SetWorkingDir ..\..\inc

DetectHiddenWindows, on
#SingleInstance, force
SetBatchLines, -1
	Gui, +LastFound
	hGui := WinExist()
	w := 340,  h := 400

	Gui, Add, Button, gBtn w60, Save
	Gui, Add, Button, gBtn w60 x+10, Reload
	Gui, Add, Button, gBtn w60 x+10, Reset
	Gui, Add, Button, gBtn w60 x+10, Stress
	hCtrl := Property_Add( hGui, 0, 40, w, h-70, "", "Handler")
	Property_SetColors(hCtrl, "pbAAEEAA sbAAAAA")
	Property_SetFont(hCtrl, "Property", "s9  italic,")
	Property_SetFont(hCtrl, "Value", "s9, Courier new")
	Property_SetFont(hCtrl, "Separator", "s12, Verdana")
	Property_SetFont(hCtrl, "Hyperlink", "s9 underline, Courier new")

	p = 
		(LTrim
		Name=My Checkbox
		Type=CheckBox
		Value=is that ok ?
		Param=0

		Name=My Separator
		Type=Separator
		
		Name=My Button
		Type=Button
		Value=click me

		Name=My Text
		Type=Text
		Value=default text`rhelo

		Name=Some fat separator
		Type=Separator
		Value=60
	
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

	)

	If !FileExist("properties")
		 Property_Insert(hCtrl, p)
	else Property_InsertFile(hCtrl, "properties")

	Property_SetRowHeight(hCtrl, 25)
	SB_SetText(Property_Count(hCtrl))
	Gui, Add, StatusBar
	Gui, Show, w%w% h%h%
return

Stress(p, k=7){
	loop, %k%
		p .= "`n`n" p
	return p
}


~ESC:: 
	ControlGetFocus, out, A
	if !InStr(out, "Edit")
		Exitapp
return

F1::
	msgbox % Property_Count(hctrl)
return

F2:: Property_ForEach(hCtrl)

GuiClose:
	ExitApp
return

Btn:
	if A_GuiControl = Reload
		Reload

	if A_GuiControl = Reset
	{
		FileDelete, Properties
		Reload
	}

	if A_GuiControl = Save
	{
		SB_SetText("Saving properties ....")
		Control, Disable, ,Button1,A
		Property_Save(hCtrl, "Properties", true)
		Control, Enable, ,Button1,A
		SB_SetText("")
	}

	if A_GuiControl = Stress
	{		
		Control, Disable, ,Button3,A
		StartTime := A_TickCount
		SB_SetText("Adding properties....")
		Property_Insert(hCtrl, Stress(p, 10)), 
		time := A_TickCount - StartTime
		SS_Redraw(hCtrl)
		Control, Enable, ,Button1,A
		SB_SetText( "Number of Rows: " Property_Count(hCtrl) "`nTime: " time "ms")
	}
return

Handler(hCtrl, event, name, value, param){
	static mycombo

;	OutputDebug %event% %name% %value% %param%, 0, 0

	if event in EB,S
		return

	if event = F
	{
		msgbox %name% %value% %param%
		return
	}

	if (event = "CB") {
		if param = Insert
			if mycombo = 
				 return mycombo := SS_CreateCombo(hCtrl, "dynamic item 1|dynamic item 2|dynamic item 3", 100)
			else return mycombo
		if param = Define
			 return Name="My Combo" ? "" : "*"
	}

	;do some stupid checks
	if (name="My Combo") 
		if (value = "dynamic item 1")
			return 1

	if (name="My Button") 
		if (Value = "") {
			MsgBox Stupid check: can't be empty
			return 1
		}			

	if (name="My Checkbox") 
		if (Param = 1) {
			MsgBox Stupid check: can't be 1, only 0 atm.
			return 1
		}			

	if (name="My WideButton") 
		if (Value = "click me") && event != "C"
			MsgBox Stupid check: Change the value, please :S

	if (name="Digit") 
		if Value not between 0 and 9
		{
			MsgBox Stupid check:   %value% is not a digit
			return 1
		}

}

#include ..\..\inc
#include _Forms.ahk