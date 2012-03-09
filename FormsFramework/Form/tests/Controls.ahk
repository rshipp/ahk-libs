_("mo! e d c")
	#MaxThreads, 255
	SetWorkingDir ..\inc
	
	custom	= HiEdit RichEdit HLink Toolbar QHTM Rebar SpreadSheet RaGrid Splitter ScrollBar Property
	ahk		= Text Edit Picture Button Checkbox Radio DropDownList ComboBox ListBox ListView TreeView Hotkey DateTime MonthCal Slider Progress StatusBar Tab2 GroupBox		;updown may somehow make problem for other controls. in this setup if you put tab2 after updown it will work ok, otherwise it will initially apear on wrong position. There were other kinds of problems all related to UpDo
	init    = HiEdit
	;===============================================
	
	ctrls := custom " " ahk
	
	htmlCtrls := RegExReplace(custom, "\w+", "<a href=$0 id=$0>$0</a><a href='" A_ScriptDir "\..\_doc\files\inc\$0-ahk.html'>&nbsp;+</a>&nbsp;&nbsp;")
			   . "<br><br>" RegExReplace(ahk, "\w+", "<a href=$0 id=$0>$0</a>&nbsp;&nbsp;")

	infoText=
	(LTrim Join
		<b>Press F1 to cycle controls. Click + to see docs.
		Click control name to switch to its tab page. Press & hold F1 and resize window as experiment.</b><br><br>
		%htmlCtrls%
	)

	hForm  := Form_New("w700 h620 e3 Resize")
	hInfo  := Form_Add(hForm, "QHTM", infoText, "gOnQHTM", "Align T, 200", "Attach w")
	hLog   := Form_Add(hForm, "ListBox", "", "hscroll", "Align R, 300", "Attach x h")
	hSep   := Form_Add(hForm, "Splitter", "", "sunken", "Align R, 6", "Attach x h" )
	hTab   := Form_Add(hForm, "Panel", "", "", "Align F", "Attach w h")
	Splitter_Set( hSep, hTab " | " hLog)

	hFont := Font("", "s9, Courier New") 	; create font only once, then use it for every control.
	loop, parse, ctrls, %A_Space%
	{		
		lf := A_LoopField
		hPanel%A_Index%	:=	Form_Add(hTab,  "Panel", "Panel " lf, "w100 h100 style='hidden'", "Align F,,*" hTab, "Attach p -")		; create hidden attach-disabled panel.
		hCtrl := Form_Add(hPanel%A_Index%, lf,	lf, MakeOptions(lf), "Align F", "Attach p r2", "Cursor HAND", "Tooltip Tooltip for " lf, "Font " hFont), ctrl%hCtrl% := A_LoopField
		InitControl(lf, hCtrl), %lf% := ctrlNo := A_Index, h%lf% := hCtrl
	}	

	QHTM_AddHtml(hInfo, "<br><h6>Total: " ctrlNo)
	Form_Show(), OnQHTM("", "", init )
	SB_SetText("StatusBar")
	Attach("OnAttach")
return

OnAttach(Hwnd) {
	global
	
	if (Hwnd = pProperty)
		Property_SetColSize(Win_GetChildren(pProperty), 150)
}

MakeOptions(Name) {
	global ListBox, MonthCal,TreeView,Hotkey,Slider,UpDown

	if Name in MonthCal,ListBox,TreeView,Hotkey,Slider,UpDown
		return "v" Name " gHandler"

	if Name=Splitter
		return "center handler=Handler"

	if Name=RaGrid
		return "style='GRIDLINES NOSEL' gHandler"

	if Name=SpreadSheet
		return "style='WINSIZE VSCROLL HSCROLL CELLEDIT ROWSIZE COLSIZE MULTISELECT' gHandler"

	if Name not in Splitter,Progress,GroupBox
		return "gHandler"
}

Log(t1="", t2="", t3="", t4="", t5="") {
	global hLog
	txt = %t1% %t2% %t3% %t4% %t5%
	Control,Add,%txt%,, ahk_id %hLog%
	ControlSend, ,{End},ahk_id %hLog%
}

Handler:
	Log(A_GuiControl, ctrl, A_GuiEvent)
return

Handler(HCtrl, p2="", p3="",p4="") {
	global
	Log(ctrl%hCtrl% ":   ",p2,p3,p4)
}

Tooltip:
	Tooltip
return

OnQHTM(Hwnd, Link, Id) {
	local n
	if (id)
		n := %Id%, Win_Show(hPanel%gCur%, false), Win_Show(hPanel%n%), gCur := n
	else return 1
}

InitControl(Name, HCtrl) {
	global

	if Name = Property
	{
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
		;Property_initSheet(hCtrl)	;must be done in panel ... will fix it...
		Property_SetColors(hCtrl, "pbAAEEAA sbaaeeaa sffff")
		Property_SetFont(hCtrl, "Separator", "bold s9, verdana")
		Property_SetRowHeight(hCtrl, 25)
		Property_Insert(HCtrl, p)
		Property_SetColSize(Hctrl, 150)
		pProperty := Win_Get(HCtrl, "P")
	}
	if Name = RichEdit
		RichEdit_SetText(HCtrl, A_ScriptDir "\_res\colors.rtf", "FROMFILE")
		, RichEdit_SetEvents(HCtrl, "Handler", "DRAGDROPDONE DROPFILES KEYEVENTS MOUSEEVENTS SCROLLEVENTS PROTECTED REQUESTRESIZE")

	if Name = Scrollbar
		Scrollbar_Set(HCtrl, 20, 0, 100, 10)

	if Name = Button
		ILButton(HCtrl, A_ScriptDir "\_res\btn1.bmp", 48, 48, "right"), Font(HCtrl, "s18 bold, Arial")

	if Name = TreeView
		TV_Add(":>", TV_Add(":)"))

	if Name = HiEdit
	{
		WinSet, Style, +1, ahk_id %Hctrl%
		HE_SetEvents(HCtrl, "Handler")
	}

	if Name = RaGrid
	{
		RG_SetHdrHeight(HCtrl, 25), RG_SetRowHeight(HCtrl, 22)
		RG_AddColumn(HCtrl, "txt=EditText", "w=150", "hdral=1",	"txtal=1", "type=EditText")
		RG_AddColumn(HCtrl, "txt=Check",	"w=80",  "hdral=1", "txtal=1", "type=CheckBox")
		RG_AddColumn(HCtrl, "txt=Button",	"w=80",  "hdral=1", "txtal=1", "type=Button")
		RG_AddRow(HCtrl, 0, Name, 1), 		RG_AddRow(HCtrl, 0, Name, 0, ":)")
	}

	if Name = HLink
		ControlSetText, ,Click <a href="www.autohotkey.com">here</a> to go to AutoHotKey site, ahk_id %HCtrl%

	if Name = Toolbar
		Toolbar_Insert(HCtrl, "cut`ncopy`npaste")

	if Name = SpreadSheet
	{
		SS_SetRowHeight(hCtrl, 0, 20), SS_SetColWidth(hCtrl, 1, 150), 
		SS_SetCell(HCtrl, 1,1, "Type=Text", "Txt=" Name), 
		SS_SetGlobalFields(HCtrl,  "gcellw gcellht cell_txtal rowhdr_txtal", 50, 30, "CENTER MIDDLE", "CENTER MIDDLE")
	}
	else if Name = Rebar
	{
		Rebar_Insert(HCtrl, Form_Add(hForm, "Edit", Name, "w100 h100"))
		Rebar_Insert(HCtrl, Form_Add(hForm, "ComboBox", Name, "w100 h100"))
	}
	else if Name = Splitter
	{		
		hp1 := Form_Add(hPanel%A_Index%	, "Panel", "Panel 1", "style='border'", "Align T, 130", "Attach w r")
		Form_Add(hp1,  "Text", "Panel 1", "center 0x200", "Align F", "Attach p")
		Align(hCtrl, "T", 30), Attach(hCtrl, "w r")
		hp2 := Form_Add(hPanel%A_Index%	, "Panel", "Panel 2", "style='border'", "Align F", "Attach w h r")
		Form_Add(hp2,  "Text", "Panel 2", "center 0x200", "Align F", "Attach p")
		Splitter_Set(HCtrl, hp1 " - " hp2)
		hSplitter := HCtrl
	}
	else if Name=QHTM
	{
		html := "<BR><b><font size=4>Flux capacitor.</font></b><p>Removing the flux capacitor during flight might lead to <font size=6>overheating</font> <font color=""red"">toxi gas</font> exhaust, and some really unhappy passengers<p></b><img src='" A_ScriptDir "/_res/test.png'></img><p>"
		ControlSetText, ,%html%, ahk_id %HCtrl%
	}
}


Form1_Close:
	ExitApp
return

F2::
	WinMove, ahk_id %hForm%, , , , 300, 300
return

F1::
	Win_Show(hPanel%gCur%, false), gCur++
	if (gCur > ctrlNo)
		gCur := 1
	Win_Show(hPanel%gCur%)
return

#include ..\inc
#include _Forms.ahk