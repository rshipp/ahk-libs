#SingleInstance, force
;#MaxThreads 255

	CreateGui(text)
	
	RichEdit_SetText(hRichEdit, "..\_res\colors.rtf", "FROMFILE")
	RichEdit_AutoUrlDetect( hRichEdit, "^" )
	
	Form_Show("", "", "Rich Edit Test Script")

	Log("Press F1 or doubleclick to execute selected API")
	Log("Sort API by clicking ListView header.")
	Log()

	RichEdit_FixKeys(hRichEdit)
return


Handler(hCtrl, Event, p1, p2, p3 ) {
  If (Event = "DROPFILES")  {
    MsgBox, % "Dropped files: " P1 "`n----`n" P2 "`n----`nChar position: " P3
    return
  }
	if event = Link
		Log("Link:", RichEdit_GetText(hCtrl, p2, p3))
  msg = %Event% `tp1 = %p1% `tp2 = %p2% `tp3 = %p3% `t%L%
  Log(msg)
  IfEqual, Event, PROTECTED, return TRUE
}

CreateGui(Text, W=980, H=600) {
	global 

	CMenu=
	(LTrim
		[RichEditMenu]
		Cut
		Copy
		Paste
	)

	btns =
	(LTrim
		Load,,,autosize
		Save,,,autosize
	    -----
		B,,,autosize
		I,,,autosize
		U,,,autosize
		S,,,autosize
		-----
		Font,,,autosize
		FG,,,autosize
		BG,,,autosize
		-
		+2,,,autosize
		-2,,,autosize
		-----
		Wrap,,,check autosize
		BackColor,,,autosize
		-----
		Events,,,check autosize
	)

	btns2 =
	(LTrim
		Num,,,autosize
		Bullet,,,autosize
		-----
		Left,,,autosize
		Center,,,autosize
		Right,,,autosize
		Justify,,,autosize
		-----
		->,,,autosize
		<-,,,autosize
	)

	hForm1    := Form_New("+Resize e1 w" W " h" H)
    hList     := Form_Add(hForm1, "ListView", "API|Description", "gOnLV AltSubmit", "Align T", "Attach p")
    hPanel1   := Form_Add(hForm1, "Panel", "", "", "Align L, 300", "Attach p")
    hExample  := Form_Add(hPanel1,"Edit", "`n", "T8 ReadOnly Multi -vscroll", "Align T,150", "Attach p", "*|)Font s10,Tahoma")
    hLog      := Form_Add(hPanel1,"ListBox", "", "0x100", "Align F", "Attach p")
    hSplitter := Form_Add(hForm1, "Splitter", "", "", "Align L, 6", "Attach p")
    hPanel2   := Form_Add(hForm1, "Panel", "", "", "Align F", "Attach p")


	hPanel3   := Form_Add(hPanel2, "Panel", "", "", "Align T,30", "Attach w")
				 Form_Add(hPanel3, "Slider", "", "Range1-10 gOnSlider AltSubmit vSlider h30", "Align R, 100", "Attach x")
	hToolbar  := Form_Add(hPanel3, "Toolbar", btns, "gOnToolbar style='flat nodivider tooltips' il=0 x0 h30", "Align T", "Attach w")
	Toolbar_SetBitmapSize(hToolbar, 0)	

	hPanel4   := Form_Add(hPanel2, "Panel", "", "", "Align T,30", "Attach w")
		hFind := Form_Add(hPanel4, "Edit",   "", "x0 y2 w100")
 				 Form_Add(hPanel4, "Button", "Find", "gOnFind h24 x+2 AltSubmit 0x8000")
		hUp	  := Form_Add(hPanel4, "CheckBox", "up", "x+2 yp+5")
	hToolbar  := Form_Add(hPanel4, "Toolbar", btns2, "gOnToolbar style='flat nodivider tooltips' il=0 x200 h30")
	Toolbar_SetBitmapSize(hToolbar, 0), Toolbar_AutoSize(hToolbar)

	hRichEdit := Form_Add(hPanel2, "RichEdit", "", "style='MULTILINE SCROLL WANTRETURN'", "Align F", "Attach w h", "CMenu RichEditMenu")

	cSlider := 0
	Splitter_Set(hSplitter, hPanel1 " | " hPanel2)
	PopulateList()		
}

OnFind:
	pos := RichEdit_GetSel(hRichEdit)
	ControlGetText, txt, ,ahk_id %hFind%
	ControlGet, bUp, Checked,  ,,ahk_id %hUp%
	direction := bUp ? "" : " down"

	pos := RichEdit_FindText(hRichEdit, txt, pos + (bUp ? -1 : 1), -1, "unicode" direction)
	Log("Found pos: " pos)
	if pos != -1
	{
		RichEdit_SetSel(hRichEdit, pos, pos+StrLen(txt))
		ControlFocus, , ahk_id %hRichEdit%
	}
return

OnSlider:
	Log(RichEdit_Zoom( hRichEdit ))
	d := slider - cslider
	ifEqual, d, 0, return
		
	RichEdit_Zoom( hRichEdit, d ) 
	critical off

	cSlider := slider
return

Form1_Close:
	ExitApp
return

RichEditMenu:
	if A_ThisMenuItem in Cut,Copy,Paste
		RichEdit_%A_ThisMenuItem%(hRichEdit)
return

Log(t1="", t2="", t3="", t4="", t5="") {
	global hLog, hRichEdit
	txt = %t1% %t2% %t3% %t4% %t5%
	Control,Add,%txt%,, ahk_id %hLog%
	ControlSend, ,{End},ahk_id %hLog%
	ControlFocus,, ahk_id %hRichEdit%
}

OnToolbar(hCtrl, Event, Txt, Pos=""){
	global 
	ifEqual, Event, hot, return

	if Txt = Font
	{
		RichEdit_GetCharFormat( hRichEdit, font, style, color)
		if Dlg_Font(font, style, color, 1, hForm1)
			 return RichEdit_SetCharFormat(hRichEdit, font, style, color)
		else return 
	}

	if Txt in FG,BG
	{
		RichEdit_GetCharFormat( hRichEdit, _, _, fg, bg)
		if Txt = FG
			 bg := ""
		else fg := ""

		if Dlg_Color(%txt%, hForm1)
			return RichEdit_SetCharFormat(hRichEdit, "", "", fg, bg)
		else return 
	}

	if Txt = Wrap 
		return RichEdit_WordWrap(hRichEdit, Toolbar_GetButton(hCtrl, Pos, "S")="checked")

	if Txt in B,I,U,S
	{
		B := "bold", I := "italic", U := "underline", S := "strikeout"
		RichEdit_GetCharFormat( hRichEdit, _, style)
		return RichEdit_SetCharFormat( hRichEdit, "", Instr(style, %Txt%) ? "-" %Txt% : %Txt% )
	}

	if Txt = BackColor
		if Dlg_Color(color, hForm1)
			 return RichEdit_SetBgColor(hRichEdit, color)
		else return
	
	if Txt = Load
		return RichEdit_SetText(hRichEdit, Dlg_Open(hForm1, "", "RTF files (*.rtf)|Text files (*.txt)"), "FROMFILE")

	if Txt = Save
		if fn := Dlg_Save(hForm1, "", "RTF files (*.rtf)|Text files (*.txt)", "", "", "rtf") 
			 return RichEdit_Save(hRichEdit, fn)
		else return

	if Txt = Events
	{
		b := Toolbar_GetButton(hCtrl, Pos, "S")="checked"
		events := !b ? "" : "DRAGDROPDONE LINK DROPFILES KEYEVENTS SELCHANGE SCROLLEVENTS PROTECTED REQUESTRESIZE"
		return RichEdit_SetEvents(hRichEdit, "Handler", events)
	}

	If Txt in +2,-2
		return RichEdit_SetFontSize(hRichEdit, Txt)

	if Txt in left,right,center,justify
		return RichEdit_SetParaFormat(hRichEdit, "Align=" Txt)

	if Txt in <-,->
		return RichEdit_SetParaFormat(hRichEdit, "Ident=" (Txt="<-" ? -1:1)*1000)
	
	if Txt in Num,Bullet
		return RichEdit_SetParaFormat(hRichEdit, "Num=" (Txt="Num" ? "DECIMAL" : "BULLET") ",1,D")
}

PopulateList() {
	global demo

	FileRead, demo, %A_ScriptName%
	StringReplace, demo, demo, `r,,A

    ;take only sublabels that start with _ and have description
	pos := 1
	Loop
		If pos := RegExMatch( demo, "`ami)^_(?P<Api>[\w]+):\s*;\s*(?P<Desc>.+)$", m, pos )
		  LV_Add("", mApi, mDesc ),  pos += StrLen(mApi), n := A_Index
		Else break

	Log(n " demo routines detected.")

	LV_ModifyCol(1,180), LV_ModifyCol(2), LV_Modify(1, "select")
}

OnLV:
  LV_GetText( api, LV_GetNext() ), LV_GetText( desc, LV_GetNext(), 2 )

  If ( A_GuiEvent = "I" ) {
	RegExMatch(demo, "mi)" api ":\s*(;.+?)\nreturn", m)
	StringReplace, m1, m1, `n,`r`n,A
	ControlSetText, ,%m1%, ahk_id %hExample%
  }
  If ( A_GuiEvent = "DoubleClick" )
	IfNotEqual, api, API, goto _%api%
return


^1::reload
^U::
^B::
^I::
	OnToolbar(hToolbar, "click", SubStr(A_ThisHotkey, 2))
return


RTF_Table(Rows, Cols, ColWidths, Fun="") {
	
	sTable	:= ""
	row		:= "\trowd\trgaph108\trleft8\trbrdrl\brdrs\brdrw10 \trbrdrt\brdrs\brdrw10 \trbrdrr\brdrs\brdrw10 \trbrdrb\brdrs\brdrw10 \trpaddl108\trpaddr108\trpaddfl3\trpaddfr3"
	col		:= "\clbrdrl\brdrw10\brdrs\clbrdrt\brdrw10\brdrs\clbrdrr\brdrw10\brdrs\clbrdrb\brdrw10\brdrs\cellx"
	endcell := "\cell"
	endrow	:= "\row"

	bFunc := IsFunc(Fun)
	StringSplit, cw, ColWidths, %A_Space%%A_Tab%
	ifEqual, cw1,,SetEnv, cw1, 100
	loop, %Rows%
	{
		sTable .= row, 	j := 0
		loop, %Cols%
			sTable .= col ( j += (cw%A_Index%="" ? cw1 : cw%A_Index%) *12 ) 

		sTable .= "\pard\intbl", r := A_Index
		loop, %cols%
		{
			if bFunc
				f := %Fun%(r, A_Index)
			sTable .= " " f  endcell
		}
		sTable .= endrow
	}
	sTable .= "\par}"
	return sTable
}

RTF_Fonts() {
	s = 
	(LTrim Join
	{\fonttbl
	 {\f0\fsnil\fcharset0 Arial;}
	 {\f1\fsnil\fcharset0 Courier New;}
     {\f3\fsnil\fcharset0 Symbol;}
	}
	)
	return s
}

RTF(Text) {
	return "{\rtf" Text
}
;================================ DEMO ==============================
table(r,c){
   return r "." c
}

_PageRotate:	;Page Rotate
	
	RichEdit_PageRotate(hRichEdit, 90)
	sleep 1000
	RichEdit_PageRotate(hRichEdit, 180)
	sleep 1000
	RichEdit_PageRotate(hRichEdit, 270)
	sleep 1000
	RichEdit_PageRotate(hRichEdit, 0)
return

_AddRTF:		;-
	rtf := "{\rtf"  RTF_Fonts()  
			. "\f1\qc centered one\par\ql ej \i ej \i0"
			. RTF_Table(5,5,"100 200", "table") 

	RichEdit_SetText(hRichEdit, rtf, "SELECTION")
return

_GetCharFormat:	;Determines the character formatting in a rich edit control.
	RichEdit_GetCharFormat(hRichEdit, font, style, textclr, backclr)
	Log("Char Format: ", font, style, textclr, backclr)
return

_SetCharFormat:	;Set character formatting in a rich edit control.
	r := RichEdit_SetCharFormat(hRichEdit, "Courier New", "BOLD S19 O100", 0xff00, 0xaaaaaa, "word")
	Log("Set Char Format: " r)
return

_GetText: ;Retrieves a specified range of characters from a rich edit control.

 Log("Selection: " RichEdit_GetText( hRichEdit ))
 Log("All: " RichEdit_GetText( hRichEdit, 0, -1 ))
 Log("Range: " RichEdit_GetText( hRichEdit, 4, 10 ))
return

_SetParaFormat:		;Sets the paragraph formatting for the current selection in a rich edit control.
	r := RichEdit_SetParaFormat(hRichEdit, "Align=CENTER", "Num=DECIMAL,10,D,1000", "Line=DOUBLE", "Space=1000,3000" )
	Log("Set Align, Num, Line & Space: " r)
	r := RichEdit_SetParaFormat(hRichEdit, "Tabs=100 1000 2000 5000")
	Log("Set Tabs:", r)
return


_TextMode:	;Sets text mode.
	rtf := RichEdit_Save( hRichEdit )			;get RTF
	txt := RichEdit_GetText(hRichEdit, 0, -1)	;get PLAINTEXT
	Log( "Current mode: " RichEdit_TextMode(hRichEdit) )
	Log( "Set mode to plaintext: " RichEdit_TextMode(hRichEdit, "PLAINTEXT") )
	Log( "Current mode: " RichEdit_TextMode(hRichEdit) )
	RichEdit_SetText(hRichEdit, txt)
	Msgbox Plain Text
	Log( "Restore mode to richtext: " RichEdit_TextMode(hRichEdit, "RICHTEXT") )
	RichEdit_SetText(hRichEdit, rtf)
return

_SetText:			;Set text from string or file in rich edit control using either rich text or plain text.
	RichEdit_SetText(hRichEdit, "insert..", "", 150)
	RichEdit_SetText(hRichEdit, "append to end..", "SELECTION", -1 )
return

_LineScroll:			;Line scroll
	RichEdit_LineScroll(hRichEdit, 100, 1)
return

_PosFromChar:	   ;Gets the client area coordinates of a specified character in an Edit control.
	RichEdit_PosFromChar(hRichEdit, RichEdit_GetSel(hRichEdit), X, Y)
	Log("Pos: " X, " " Y)
return

_GetLine:			;Get Line
	Log("Current Line: '" RichEdit_GetLine(hRichEdit) "'")
return

_GetLineCount:		;Get Line Count
	Log("Line count: " RichEdit_GetLineCount(hRichEdit) )
return

_GetModify:			;Get modification status
	Log("Modification status: " RichEdit_GetModify(hRichEdit))
return

_SelectionType:		;Get selection type
	Log("Selection type: " RichEdit_SelectionType(hRichEdit))
return

_GetOptions: ;Get options
	Log("Current options: " RichEdit_GetOptions(hRichEdit))
return

_SetOptions:	;Set rich edit options
	r := RichEdit_SetOptions(hRichEdit, "XOR", "SELECTIONBAR READONLY")	;switch readonly
	Log("Current options: " r)
return

_FindWordBreak:	;Finds the next word break before or after the specified character position or retrieves information about the character at that position.
	pos := RichEdit_FindWordBreak(hRichEdit, RichEdit_GetSel(hRichEdit), "MOVEWORDRIGHT")
	RichEdit_SetSel(hRichEdit, pos)
	Log("Next word found at: " pos)
return

_Clear:	;Clear selection
	RichEdit_Clear(hRichEdit)
return


_AutoUrlDetect:  ; Enable disable or toggle automatic detection of URLs by a rich edit control.

  Log("Url detect: " RichEdit_AutoUrlDetect( hRichEdit, "^" ))
return

_GetSel: ;Retrieve the starting and ending character positions of the selection.

	RichEdit_GetSel( hRichEdit, min, max  )
	if !(count := max-min)
		 Log("Cursor Position: " min)
	else Log("Selected from: " min " - " max " (" count ")")
return

_LineFromChar: ;Determines which line contains the specified character in a rich edit control.
	Log( "Current Line: " RichEdit_LineFromChar( hRichEdit, RichEdit_GetSel(hRichEdit)))
return

_LimitText:	;Sets an upper limit to the amount of text the user can type or paste into a rich edit control
	RichEdit_LimitText( hRichEdit, 20 )  ; limit to 20 characters
return


F1:: IfNotEqual, api, API, goto _%api%

#include ..\..\inc
#include _Forms.ahk