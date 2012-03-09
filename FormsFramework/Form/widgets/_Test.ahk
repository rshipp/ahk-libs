_()
	hForm1	:=	Form_New("w400 e1 h500 +Resize +ToolWindow")

	hWriter := Form_Add(hForm1, "Writer", "", "w100 h100", "Align T,200")
	hPanel  := Form_Add(hForm1, "Panel", "", "", "Align T,40")
	Form_AutoSize(hForm1)
	Attach(hWriter, "w h"), Attach(hPanel, "y w")

	Form_Add(hPanel, "Button", "Save", "gOnBtn xm ym w100 0x8000")
	Form_Add(hPanel, "Button", "Clear","gOnBtn ym w100 0x8000 x" 275, "Attach x")
	Form_Show()
return

OnBtn:
	msgbox % A_GuiControl
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

#include ..\inc
#include ..\widgets\Writer.ahk