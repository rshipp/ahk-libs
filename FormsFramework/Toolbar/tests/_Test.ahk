#SingleInstance, force
SetBatchLines, -1

	Gui, +LastFound
	hGui := WinExist() 
	w := 800, h := 660
	Gui, Show , w%w% h%h% Hide, Toolbar Test		;set gui width & height (mandatory)
	Gui, Add, StatusBar, , 

	hIL := IL_Create(200, 0, 1) 
	loop, 150
	   IL_ADD(hIL, A_WinDir "\system32\shell32.dll", A_Index) 

	hToolbar := Toolbar_Add(hGui, "OnToolbar", "BORDER WRAPABLE ADJUSTABLE", hIL)
	Toolbar_Clear(hToolbar)
	btns = 
	(LTrim
		btn &1  ,	,checked,check
		btn &2	,	,		,dropdown check showtext, 101
		btn &3	,	,		,,
		btn &4	,7	,		,dropdown check showtext, 102
		btn &5	,	,		,showtext a

		*a1		,128,		,showtext
		*a2		,129
		*a3		,130
	)
	Toolbar_Insert(hToolbar, btns)
;	Toolbar_GetButtonSize(hToolbar, ww, hh)
	Toolbar_SetButtonSize(hToolbar, 53, 67)
	Toolbar_SetButtonSize(hToolbar, 53, 67)

	MakeTestGui(w/2, h-430)
	Gui, Show
return


OnToolbar(hwnd, event, txt, pos, id) {
	if event = hot
	{
		id := Toolbar_GetButton(hwnd, pos, "id"),   s := Toolbar_GetButton(hwnd, pos, "s")
		return SB_SetText(txt  "   Data: " id "  " s)
	}

	tooltip Event:  %event%`nPosition:  %pos%`nCaption:  %txt%`n`nID:%id%`nTickCount:%A_TickCount%, -200, 0
}

MakeTestGui(w, h){

	Gui, Font, s8, Courier New

	Gui, Add, Text,  x5 y400, Input / Output :
	Gui, Add, Edit,  xp w%w% yp+20 h200,

	d=25
	Gui, Add, BUTTON, w100 X+%d% yp gOnBtn section, Add
	Gui, Add, BUTTON, w100 X+%d% yp gOnBtn, Insert
	Gui, Add, BUTTON, w100 x+%d% yp gOnBtn, Define

	Gui, Add, BUTTON, w100 Xs gOnBtn, Delete
	Gui, Add, BUTTON, w100 X+%d% yp gOnBtn, Clear
	Gui, Add, BUTTON, w100 X+%d%	gOnBtn, Count

	Gui, Add, BUTTON, w100 Xs  gOnBtn, Customize
	Gui, Add, BUTTON, w100 X+%d% yp gOnBtn, ToggleStyle
	Gui, Add, BUTTON, w100 X+%d% yp gOnBtn, GetButton

	Gui, Add, BUTTON, w100 Xs  gOnBtn, SetButtonWidth
	Gui, Add, BUTTON, w100 x+5 yp gOnBtn, SetButtonSize
	Gui, Add, BUTTON, w100 x+5 gOnBtn, SetButton

	Gui, Add, BUTTON, w100 xs gOnBtn, AutoSize
	Gui, Add, BUTTON, w100 x+%d% yp gOnBtn, GetButtonSize

	Gui, Add, BUTTON, w350 h45 Xs y+10  gOnBtn, Open Help`n(right click on any buttton)

}

OnBtn:
		
	_ := Get()
	p1 := p2 := p3 := ""
	stringsplit, p, _, `,,%A_Space%%A_Tab%

	if A_GuiControl = Define
	{
		_ := Toolbar_Define(hToolbar, p1)
		StringReplace, _, _, `n, `r`n, A
		Set(_)
	}

	if A_GuiControl = Count
		Set( Toolbar_Count(hToolbar, p1) )

	if A_GuiControl = Customize
		Toolbar_Customize(hToolbar)

	if A_GuiControl = Add
		Toolbar_Insert(hToolbar, _)

	if A_GuiControl = Insert
		Toolbar_Insert(hToolbar, _, 3)

	if A_GuiControl = ToggleStyle
		Set(Toolbar_ToggleStyle(hToolbar, p1 != "" ? p1 : "LIST"))

	if A_GuiControl = Delete
		Toolbar_DeleteButton(hToolbar, p1 != "" ? p1 : 1)

	if A_GuiControl = AutoSize
		Toolbar_AutoSize(hToolbar, p1)

	if A_GuiControl = GetButton
		Set( Toolbar_GetButton(hToolbar, p1 != "" ? p1 : 1) )

	if A_GuiControl = GetButtonSize
		Toolbar_GetButtonSize(hToolbar, ww, hh), Set(ww "," hh)

	
	if A_GuiControl = Clear
		Toolbar_Clear(hToolbar)

	if A_GuiControl = SetButton
		Toolbar_SetButton(hToolbar, p1, p2, p3)

	if A_GuiControl = SetButtonWidth
		Toolbar_SetButtonWidth(hToolbar, p1, p2)

	if A_GuiControl = SetButtonSize
		Toolbar_SetButtonSize(hToolbar, p1, p2)		

	if A_GuiControl = Open Help`n(right click on any buttton for its help)
		Run, Toolbar.html
return

Set(txt){
	ControlSetText, Edit1, %txt%, A
}

Get() {
	ControlGetText, txt, Edit1, A
	StringReplace, txt, txt, `r`n, `n, A
	return txt
}

GuiEscape:
GuiClose:
	ExitApp
return

#IfWinActive Toolbar Test
RButton::
	MouseGetPos, , , , h
	if !InStr(h, "Button")
		return
	ControlGetText,txt,%h%, A
	Run, %A_ProgramFIles%\Internet Explorer\iexplore "%A_ScriptDir%\Toolbar.html#%txt%"
return

F5:: Reload

#Include ..\Toolbar.ahk