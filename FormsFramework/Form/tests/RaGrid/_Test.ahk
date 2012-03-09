;_("mm! e")
SetWorkingDir ..\..\inc
#SingleInstance, force

	w := 1000, h := 500, header := 50

	Gui, +LastFound +Resize
	hwnd := WinExist()

	Gui, Add, Button,x0		gOnBtn, Insert
	Gui, Add, Button,x+0 yp	gOnBtn, Delete
	Gui, Add, Button,x+0 yp	gOnBtn, Move Up
	Gui, Add, Button,x+0 yp	gOnBtn, Move Down

	Gui, Add, Button,x+20 yp gOnBtn, Colorize Row
	Gui, Add, Button,x+0 yp	gOnBtn, Set Colors
	Gui, Add, Button,x+20 yp gOnBtn, Read Cell
	Gui, Add, Button,x+5 yp gOnBtn, Convert Cell
	Gui, Add, Button,x+5 yp gOnBtn, Sort Column

	Gui, Add, Button,x+40 yp gOnBtn, Reload
	Gui, Add, StatusBar, ,Loading data
	Gui, Show, h%h% w%w%
	
	hIL := ImageList_Create(16, 16, 0x21, 255, 10)
	Loop 255  
		ImageList_AddIcon(hIL, LoadIcon("shell32.dll", A_Index, 16))
	
	hGrd := RG_Add(hwnd, 0, header, w, h-header-30, "GRIDFRAME VGRIDLINES NOSEL", "OnRa" ), Attach(hGrd, "w h")
	RG_SetFont(hGrd, "s8, Courier New")
	RG_SetHdrHeight(hGrd, 30), RG_SetRowHeight(hGrd, 26)	

	loop, 5
	{
		RG_AddColumn(hGrd, "txt=EditText",  "w=100", "hdral=1",	"txtal=1", "type=EditText")
		RG_AddColumn(hGrd, "txt=EditLong",  "w=100", "hdral=1", "txtal=1", "type=EditLong", "format=# ### ####")
		RG_AddColumn(hGrd, "txt=Combo",		"w=90",  "hdral=1", "txtal=1", "type=ComboBox", "items=combo 1|combo 2|combo 3|combo 4|combo 5|combo 6|combo 7|combo 8|combo 9|combo 10|combo 11|combo 12")
		RG_AddColumn(hGrd, "txt=Check",		"w=70",  "hdral=1", "txtal=1", "type=CheckBox")
		RG_AddColumn(hGrd, "txt=Button",	"w=100", "hdral=1", "txtal=1", "type=Button")
		RG_AddColumn(hGrd, "txt=EButton",	"w=100", "hdral=1", "txtal=1", "type=EditButton")
		RG_AddColumn(hGrd, "txt=Image",		"w=100", "hdral=1", "txtal=1", "type=Image", "il=" hIL)
		RG_AddColumn(hGrd, "txt=Hotkey",	"w=100", "hdral=1", "txtal=1", "type=Hotkey")
		RG_AddColumn(hGrd, "txt=Date",		"w=100", "hdral=1", "txtal=1", "type=Date", "format=yy'-'MM'-'dd")
		RG_AddColumn(hGrd, "txt=Time",		"w=100", "hdral=1", "txtal=1", "type=Time", "format=HH':'mm")
		RG_AddColumn(hGrd, "txt=User",		"w=100", "hdral=1", "txtal=1", "type=User", "data=1234")
	}

	loop, 1000
		RG_AddRow(hGrd, 0, "Text" A_Index ,A_Index, mod(A_Index, 12), mod(A_Index, 2), "btn" A_Index, "",mod(A_Index, 255))
		;, RG_AddRow(hGrd, 0 " " 10, "Text" A_Index ,A_Index, mod(A_Index, 12), mod(A_Index, 2), "btn" A_Index, "", mod(A_Index, 255))

	SB_SetText("Loading finished`n`nRows " RG_GetRowCount(hGrd) " Cols " RG_GetColCount(hGrd))
return 

OnRa(HCtrl, Event, Col, Row, Data="") {
	static s
	SB_SetText( s .= " | " col " " row " " event )
	if StrLen(s)>120
		s := ""
		
	if (Event = "BeforeEdit")
		SetTimer, ResizeTimer, -1		;resize editing control
	
	if (Event = "HeaderClick")
		RG_Sort(HCtrl, Col)
}

ResizeTImer:
		h := RG_GetColumn(hGrd, "", "hctrl")
		;Win_Move(h, "", "", 200, "")
return

OnBtn:
	if A_GuiControl = Insert
		RG_AddRow(hGrd, RG_GetCurrentRow(hGrd))

	if A_GuiControl = Delete
		RG_DeleteRow(hGrd)
	
	if A_GuiControl = Move up 
	{
		r := RG_GetCurrentRow(hGrd)
		RG_MoveRow(hGrd, r, r+1)
		RG_SetCurrentRow(hGrd, r+1) 
	}

	if A_GuiControl = Move down 
	{
		r := RG_GetCurrentRow(hGrd)
		RG_MoveRow(hGrd, r, r-1)
		RG_SetCurrentRow(hGrd, r-1) 
	}

	if A_GuiControl = Reload
		Reload

	if A_GuiControl = Colorize Row
	{
		RG_SetRowColor(hGrd, "", 0xFF, 0xFFFF)
		WinSet, Redraw, ,ahk_id %hGrd%
	}
	
	if A_GuiControl = Read Cell
		msgbox % RG_GetCell(hGrd)

	if A_GuiControl = Set Colors
		RG_SetColors(hGrd, "B1 G0xFF F0xFFFFFF")

	if A_GuiControl = Sort Column
		RG_Sort(hGrd)

	if A_GuiControl = Convert Cell
		msgbox % RG_CellConvert(hGrd)
return

#include inc\IL.ahk
#include ..\..\inc
#include _Forms.ahk