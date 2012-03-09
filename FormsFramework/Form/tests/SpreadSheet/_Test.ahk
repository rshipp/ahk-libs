_()

S(_,"DRAWITEMSTRUCT: CtlType CtlID itemID itemAction itemState hwndItem hDC left top right bottom itemData")
S(_,"BLOBRECT: size=.2 left top right bottom")

version = 2.1
#singleinstance, force
SetBatchLines, -1
CoordMode, tooltip, screen

	Gui, +LastFound +Resize
	hwnd := WinExist()
	Gui, Font, s11, Courier
	w := 650, h := 500, hdr:=40

	Gui, Add, Text, y10 x5, Choose Action
	Gui, Add, DDL,  x+10 w200 y5 0x8000 vC gOnChange, Load|Save| |New Sheet|Blank Cell|Delete Cell|Current Cell| |Delete Col|Delete Row|Insert Col|Insert Row| |Get Multisel|Set Multisel|Expand cell| |Set Global| |No Row Header|No Col Header|Scroll Lock|Get Cell Rect| |Split Ver|Split Hor|Split Close|Split Sync|Get Cell||Get Cell Text|Get Cell Data| |Set Cell String|Set Cell Data to 0
	Gui, Add, Button,x+10 h25 0x8000 gOnButton, exec   F1
	Gui, Add, Button,x+10 yp hp 0x8000 gOnReload, reload
	Gui, Add, Button,x+10 yp hp 0x8000 gOnAbout, ?
	

	hCtrl := SS_Add(hwnd, 0, hdr, w, h-hdr, "WINSIZE VSCROLL HSCROLL CELLEDIT ROWSIZE COLSIZE STATUS MULTISELECT", "Handler", "..\..\inc\SprSht.dll")
	

	SS_SetCell(hCtrl, 1, 1, "type=FLOAT", "txt=14.123456", "txtal=4 RIGHT", "state=LOCKED")

	hCombo := SS_CreateCombo(hCtrl, "0|1|2|3|4|5|6|7|8|9|10")
	SS_SetCell(hCtrl, 2, 7, "type=COMBOBOX FIXEDSIZE", "txt=" hCombo, "imgal=right")

	SS_SetCell(hCtrl, 1, 0, "txt=hello", "")
	SS_SetCell(hCtrl, 0, 1, "txtal=BOTTOM RIGHT")


	SS_SetDateFormat(hCtrl, "dd.MM.yyyy")
	SS_SetCell(hCtrl, 3, 1, "type=INTEGER DATE", "txt=" i := SS_ConvertDate(hCtrl, "10.11.1976"), "w=100")

	SS_SetCell(hCtrl, 2, 1, "type=TEXTMULTILINE FORCETYPE", "txt=Some`nMultiline Text", "fnt=1")


	SS_SetCell(hCtrl, 1, 2, "type=TEXT", "txt=Style", "bg=0xFF", "fg=0xFFFFFF", "state=LOCKED")
		
	SS_SetCell(hCtrl, 1, 3, "type=TEXT", "txt=Anchor", "bg=0xFF", "fg=0xFFFFFF", "state=LOCKED")
	SS_SetCell(hCtrl, 2, 3, "type=BUTTON FORCETEXT FIXEDSIZE", "txt=w0.5 h", "imgal=MIDDLE RIGHT", "fnt=1")

	SS_SetCell(hCtrl, 1, 4, "type=TEXT", "txt=Visible", "bg=0xFF", "fg=0xFFFFFF")
	SS_SetCell(hCtrl, 2, 4, "type=CHECKBOX FIXEDSIZE", "txt=yes", "data=1", "fg=0xFFFF", "bg=0x421A", "h=40")


	SS_SetCell(hCtrl, 1, 6, "type=TEXT", "txt=Help", "bg=0xFFFF", "fg=-1")
	SS_SetCell(hCtrl, 2, 6, "type=HYPERLINK", "txt=autohotkey.com", "w=150", "fnt=2")

	SS_SetCell(hCtrl, 1, 8, "type=WIDEBUTTON TEXT", "Txt=My Button","txtal=CENTER MIDDLE", "w=100", "state=LOCKED")

	SS_SetRowHeight(hCtrl, 1, 50)

	SS_SetFont(hCtrl, 0, "s10, Arial")
	SS_SetFont(hCtrl, 1, "s9, Courier")
	SS_SetFont(hCtrl, 2, "s8 italic bold, Verdana")

	;formula
	SS_SetCell(hCTrl, 1, 10, "txt= x  =", "type=TEXT", "txtal=CENTER", "fnt=1")
	SS_SetCell(hCTrl, 1, 11, "txt= y  =", "type=TEXT", "txtal=CENTER", "fnt=1")
	SS_SetCell(hCTrl, 1, 12, "txt=x+y =", "type=TEXT", "txtal=CENTER", "fnt=1")

	SS_SetCell(hCtrl, 2, 10, "type=INTEGER FORCETYPE", "txt=90", "fnt=1", "txtal=LEFT")
	SS_SetCell(hCtrl, 2, 11, "type=INTEGER FORCETYPE", "txt=20", "fnt=1", "txtal=LEFT" )
	SS_SetCell(hCtrl, 2, 12, "type=FORMULA", "txt=AB10+AB11", "txtal=LEFT")
	
	graph = Grp(T(-1,0,0,Rgb(0,0,0),"Graph Demo"),X(0,PI()*4,0,1,Rgb(0,0,255),"x-axis"),Y(-1.1,1.1,0,0.5,Rgb(255,0,0),"y-axis"),gx(AJ1:AJ13,Rgb(0,0,0),"Cell values"),fx(Sin(x()),0.1,Rgb(255,0,255),"Sin(x)"),fx(x()^3-x()^2-x(),0.1,Rgb(0,128,0),"x^3-x^2-x"))

	SS_SetCell(hCtrl, 1, 14, "type=GRAPH", "txt=" graph, "bg=0x0D0FFFF")
	SS_ExpandCell(hCtrl, 1, 14, 4, 20)
	SS_ReCalc(hCtrl)

	;blobs
	hIcon := LoadIcon(), 	S(BUF, "BLOBRECT! size left right", p0:=16, p1:=10, p2:=30)
	SS_SetCell(hCtrl, 1, 5, "type=OWNERDRAWINTEGER", "txt=101", "state=LOCKED", "h=45", "w=90")		
	SS_SetCell(hCtrl, 2, 5, "type=OWNERDRAWBLOB", "txt=test", "state=LOCKED")	;overdrawtext
	SS_SetCell(hCtrl, 3, 5, "type=OWNERDRAWBLOB", "w=200", "state=LOCKED")		;overdrawblob
	SS_SetCellBLOB(hCtrl, BUF, 3, 5)


	SS_SetGlobalFields(hCtrl, "cell_txtal", "RIGHT MIDDLE")
	Gui, Show, w%w% h%h%, SpreadSheet
	SS_Redraw(hCtrl)		;refresh
return

Handler(hwnd, Event, EArg, Col, Row) {
	static s
	GLOBAL hicon

	if Event=D
	{
		S(_:=EArg, "DRAWITEMSTRUCT) hDc left top", hdc, left, top)
		bBlob := col = 3

		if !bBlob
			  d := SS_GetCellText(hwnd, col, row)  ;overdrawinteger
		else  d := SS_GetCellBlob(EArg), S(d, "BLOBRECT) left right", l, r), d := "BLOB Rect width: " r-l   ;overdrawblob

		if !bBlob
			DllCall("DrawIcon","uint", hDC,"uint", left ,"uint", top,"uint", hIcon)
		DllCall("TextOut", "uint", hDC, "uint", left+12, "uint", top+8, "str", d, "uint", StrLen(d))		
		return	
	}

	text := SS_GetCellText(hwnd, Col, Row)
	StringReplace, text, text, `n, \n, A
	s .= "cell: " col "," row "," SS_GetCellType(hwnd,col,row)  "    event: " event " (earg: " earg ")  Text: " text "`n" 
	tooltip %s%, 0, 0
	if StrLen(s) > 500 
		s =
}

SetGlobalSettings(){
	global

	;header and cell defaults	
	h_bg := c_bg := 0xAAAAAA
	h_txtal := c_txtal := "CENTER MIDDLE"
	h_fg := 0xFF0000
	h_fnt := 2
	c_fg := 0xFFFFFF
	
	g_colhdrbtn := 0			;button sytle col hdr
	g_rowhdrbtn := 0			;button style row hdr
	g_winhdrbtn := 0			;button style win hdr
	g_lockcol   := 0xAAAAAA		;Back color of locked cell              
	g_hdrgrdcol := 0xFF00FF		;Header grid color                      
	g_grdcol    := 0xFFFFFF		;Cell grid color                        
	g_bcknfcol  := 0xCCCCCC		;Back color of active cell, lost focus  
	g_txtnfcol  := 1			;Text color of active cell, lost focus  
	g_bckfocol  := 0xFFFF	    ;Back color of active cell, has focus   
	g_txtfocol  := 0			;Text color of active cell, has focus   

	g_ghdrwt    := 75			;header width
	g_ghdrht    := 25			;header height
	g_gcellw    := 50			;cell width
	g_gcellht   := 20			;cell height

	SS_SetGlobal(hCtrl, "g", "c", "h", "h", "h")
}

OnChange:
	Gui, Submit, NoHide
	ifEqual, c,, return
	
	if c=Load 
	{
		FileSelectFile, fn,3,, Open a file, SpreadSheet (*.spr)
		if Errorlevel
			return
		SS_LoadFile(hCtrl, fn)
	}
	
	if c=Save
	{
		FileSelectFile, fn,S, ,Save a file, SpreadSheet (*.spr)
		if Errorlevel
			return
		SS_SaveFile(hCtrl, fn)
	}

	if c=New Sheet
		SS_NewSheet(hCtrl)
	
	if c=Blank Cell
		SS_BlankCell(hCtrl)

	if c=Delete Cell
		SS_DeleteCell(hCtrl)

	if c=Current Cell
	{
		SS_GetCurrentCell(hCtrl, col, row)
		msgbox %col% %row%
	}

	if c=Delete Col
		SS_DeleteCol(hCtrl)
	if c=Delete Row
		SS_DeleteRow(hCtrl)
	if c=Insert Col
		SS_InsertCol(hCtrl, SS_GetCurrentCol(hCtrl))
	if c=Insert Row
		SS_InsertRow(hCtrl, SS_GetCurrentRow(hCtrl))
	if c=Get Multisel
	{
		SS_GetMultiSel(hCtrl, top, left, right,bottom)
		msgbox %left% %top% %right% %bottom%
	}
	if c=Set Multisel
		SS_SetMultiSel(hCtrl, 2, 1, 4, 8)

	if c=Set Global
		SetGlobalSettings()

	if c=Expand Cell
		SS_GetMultiSel(hCtrl,  top,  left,  right,  bottom),  SS_ExpandCell(hCtrl, left, top, right, bottom )

	if c=No Row Header
		SS_SetColWidth(hCtrl,0,0)

	if c=No Col Header
		SS_SetRowHeight(hCtrl,0,0)
	
	if c=Scroll Lock
		SS_SetLockRow(hCtrl, 3)

	if c=Get Cell Rect
	{
		SS_GetCellRect(hCtrl,  top,  left,  right,  bottom)
		msgbox %top% %left% %right% %bottom%
	}

	if c=Split Ver
		SS_SplittVer(hCtrl) 
	if c=Split Hor
		SS_SplittHor(hCtrl)

	if c=Split Close
		SS_SplittClose(hCtrl)

	if c=SPlit Sync
		SS_SplittSync(hCtrl, 1)

	if c=Get Cell
	{
		SS_GetCellArray(hCtrl, "i")
		msg = 
		(LTrim
			Type = %i_type%
			Text = %i_txt%
			Data = %i_data%

			state = %i_state%         
			bg = %i_bg%
			fg = %i_fg%
			txtal = %i_txtal%
		    imgal = %i_imgal%
			fnt = %i_fnt%
		)
	
		msgbox %msg%
	}

	if c=Get Cell Text
		msgbox % SS_GetCellText(hCtrl)
	
	if c=Set Cell String
		SS_SetCellString(hCtrl, "TEST")

	if c=Get Cell Data
		msgbox % SS_GetCellData(hCtrl)

	if c=Set Cell Data to 0
		SS_SetCellData(hCtrl, 0)

	SS_Redraw(hCtrl)
return

Anchor(c, a = "", r = false) { ; v3.6 - Titan
	static d
	GuiControlGet, p, Pos, %c%
	If ex := ErrorLevel {
		Gui, %A_Gui%:+LastFound
		ControlGetPos, px, py, pw, ph, %c%
	}
	If !(A_Gui or px) and a
		Return
	i = x.w.y.h./.7.%A_GuiWidth%.%A_GuiHeight%.`n%A_Gui%:%c%=
	StringSplit, i, i, .
	d := a ? d . ((n := !InStr(d, i9)) ? i9 : "")
		: RegExReplace(d, "\n\d+:" . c . "=[\-\.\d\/]+")
	Loop, 4
		x := A_Index, j := i%x%, i6 += x = 3
		, k := !RegExMatch(a, j . "([\d.]+)", v) + (v1 ? v1 : 0)
		, e := p%j% - i%i6% * k, d .= n ? e . i5 : ""
		, RegExMatch(d, "\Q" . i9 . "\E(?:([\d.\-]+)/){" . x . "}", v)
		, l .= p%j% := InStr(a, j) ? (ex ? "" : j) . v1 + i%i6% * k : ""
	If r
		rx = Draw
	If ex
		ControlMove, %c%, px, py, pw, ph
	Else GuiControl, Move%rx%, %c%, %l%
}

F1:: goto OnChange

OnButton:
	goto OnChange
return

~ESC::
	ControlGetFocus, out, A
	ifEqual,out,Edit1, return
	
	IfWinActive SpreadSheet
		ExitApp
return

GuiEscape:
GuiClose:
	Exitapp
return

OnReload:
	Reload
return

GuiSize:
	Anchor("SPREAD_SHEET1", "wh")
return

OnAbout:
	msg =
	(Ltrim
	SpreadSheet control by KetilO 
	http://www.radasm.com/
	
	SpreedSheet AHK wrapper
	by majkinetor

	Version: %version%
	)
	msgbox %msg%
return


LoadIcon(){
	return DllCall("LoadIcon", "uint", hInstance, "uint", 32512)
}

#include ..\..\inc
#include _Forms.ahk