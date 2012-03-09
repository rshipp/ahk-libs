_("mm!")
    CMenu =
	(LTrim
		[Edit]
		edit item 1
		edit item 2
		edit item 3
		x=[sub]
		
		[sub]
		meh=123
		blah=456

		[Picture]
		pic item1
		pic item2
	)

	hForm1	:=	Form_New("e3 w200 h500")	
	Form_Add(hForm1, "Edit", "ESC to close script. F2 to resize. Drag picture to move. Right click controls for the context menu.", "-vscroll w200 r3 0x8000","Align T", "Attach w", "CMenu Edit, Menu_Controls")
	Form_Add(hForm1, "Picture", "res\test.bmp", "gPictureDrag", "Cursor size", "CMenu Picture, Menu_Controls")

	hFont := Font("", "s12 italic, Courier New")
	sz := Font_DrawText("Click here to go to Google", "", hFont, "calcrect ahksize")
	pos := Form_GetNextPos(hForm1, sz)
	Form_Add(hForm1, "HLink", "Click 'here':www.google.com to go to Google", pos " " sz, "Font " hFont, "CMenu Sub, Menu_Controls")
	pos := Form_GetNextPos(hForm1, "x+50 yp")
	Form_Add(hForm1, "HLink", "Click 'here':www.google.com to go to Google", pos " " sz, "Font " hFont, "CMenu Sub, Menu_Controls")

	Form_AutoSize( hForm1, 10.5)
	Form_Show(hForm1, "xCenter yCenter")
return

Form1_ContextMenu:
	m("Form1 context menu")
return

Menu_Controls:
	m("Menu: " A_ThisMenu, "Item: " A_ThisMenuItem, "Data: " ShowMenu_Data(Menu_Controls))
return

PictureDrag: 
	PostMessage, 0xA1, 2,,, A 
Return

F1:: 
	WinShow, ahk_id %hForm1%
	WinActivate, ahk_id %hForm1%
return

F2::
	WinSet, Style, ^0x40000, ahk_id %hForm1%
	Form_AutoSize(hForm1)
	Win_Redraw()
return

Form1_Close:
	ExitApp
return

#include ..\..\inc
#include _Forms.ahk