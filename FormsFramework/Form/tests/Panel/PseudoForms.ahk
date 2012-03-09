_("mo! d e w")
#MaxThreads, 255

	hMainForm:=	Form_New("w500 h400 Resize")
	hForm1  :=  Form_Add(hMainForm, "Panel", "", "", "Align F", "Attach p")
	hForm2  :=  Form_Add(hMainForm, "Panel", "", "style=hidden", "Align F,," hForm1, "Attach p -")
	loop, 2
	{		
		hPanel	 :=	Form_Add(hForm%A_Index%,  "Panel",	 "",	  "w250",				"Align L, 250", "Attach p")
		hButton1 :=	Form_Add(hPanel,  "Button",  "OK" A_Index,	  "gOnControl 0x8000",	"Align T, 50", "Attach p", "Cursor hand", "Tooltip I have hand cursor")
		hButton2 :=	Form_Add(hPanel,  "Button",  "Cancel" A_Index,"gOnControl 0x8000",	"Align F", "Attach p", "Tooltip jea baby")

		hPanel2	:=	Form_Add(hForm%A_Index%,  "Panel",	 "",	  "",					"Align F", "Attach p")
		hEdit1	:=  Form_Add(hPanel2, "Edit",	 "F2 to switch to other form.",  "",	"Align T, 200", "Attach p")
		hHE		:=  Form_Add(hPanel2, "HiEdit",	"HiEdit" A_Index,  "DllPath=inc\hiedit.dll style='HSCROLL HILIGHT TABBED FILECHANGEALERT'", "Align F", "Attach p")
	}

	Form_Show()
return

F1::
	WinMove, ahk_id %hMainForm%, , , ,300, 300
return

F2::
	if toggled2
	{
		WinShow, ahk_id %hForm1%
		WinHide, ahk_id %hForm2%
		toggled2 := 0
		WinSetTitle, ahk_id %hMainForm%, , Form1
		;fix HiEdit bug
		;Win_MoveDelta(hForm1, "", "", 1, "")
	}
	else {
		WinShow, ahk_id %hForm2%
		WinHide, ahk_id %hForm1%
		toggled2 := 1
		WinSetTitle, ahk_id %hMainForm%, , Form2
		;fix HiEdit bug
		;Win_MoveDelta(hForm2, "", "", 1, "")
	}
return

OnControl:
	msgbox %  A_GuiCOntrol
return

Form1_Close:
	ExitApp
return

#include ..\..\inc
#include _Forms.ahk