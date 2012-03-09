;_("mo!")
#Singleinstance, force
#NoEnv
	Gui, +LastFound
	hGui := WinExist()
	Gui, Add, Button, w100 y+10 gOnBtn ,Icon
	Gui, Add, Button, w100 y+10 gOnBtn ,Color
	Gui, Add, Button, w100 y+10 gOnBtn ,Font	
	Gui, Add, Button, w100 y+10 gOnBtn ,Open
	Gui, Add, Button, w100 y+10 gOnBtn ,Save
	Gui, Add, Button, w100 y+10 gOnBtn ,Find
	Gui, Add, Button, w100 y+10 gOnBtn ,Replace
	Gui, Add, Edit, ym+5 w300 h220,Input / Output
	Gui, Show, autosize
return
	
Set(txt){
	ControlSetText, Edit1, %txt%
}

OnBtn:
	if A_GuiControl = Icon
		if Dlg_Icon(icon, idx, hGui)
			Set("Path:  " icon "`r`nIndex:  " idx)

	if A_GuiControl = Color
	 	if Dlg_Color( color, hGui )
			Set("Color: " color)

	if A_GuiControl = Font
		if Dlg_Font( font, style, color, true, hGui)
			Set("Font:  " font "`r`nStyle:  " style "`r`nColor:  " color)

	if A_GuiControl = Open
	{
		res := Dlg_Open(hGui, "Select several files", "All Files (*.*)|Audio (*.wav; *.mp2; *.mp3)|Documents (*.txt)", 1, "h:\", "", "ALLOWMULTISELECT FILEMUSTEXIST HIDEREADONLY")
		StringReplace, res, res, `n, `r`n, A
		Set(res)
	}

	if A_GuiControl = Save
		Set(Dlg_Save(hGui, "Select several files", "All Files (*.*)|Audio (*.wav; *.mp2; *.mp3)|Documents (*.txt)", "", "c:\", ""))

	if A_GuiControl = Find
		Dlg_Find(hGui, "OnFindReplace", "-w") 

	if A_GuiControl = Replace
		Dlg_Replace(hGui, "OnFindReplace", "d", "Find me", "Replace me")
return

OnFindReplace(Event, Flags, FindText, ReplaceText){
	s  = Event: %event%`r`nFlags: %Flags%`r`nFindText: %FindText%
	s .= ReplaceText != "" ? "`r`nReplaceText: " ReplaceText : ""
	Set(s)
}

#include ..\Dlg.ahk