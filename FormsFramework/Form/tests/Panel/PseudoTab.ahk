_("mm! d e w")
;#MaxThreads, 255

	hForm1	:=	Form_New("w540 h400 Resize")

	hPanel	 :=	Form_Add(hForm1,  "Panel",	 "",	  "w250",		"Align L, 250", "Attach p")
	hButton1 :=	Form_Add(hPanel,  "Button",  "OK",	  "gOnControl",	"Align T, 50", "Attach p", "Image inc\test.bmp, 40", "Cursor hand", "Tooltip I have hand cursor")
	hButton2 :=	Form_Add(hPanel,  "Button",  "Cancel","gOnControl",	"Align F", "Attach p", "Tooltip jea baby")

	hPanel2	:=	Form_Add(hForm1,  "Panel",	 "",	  "",			"Align F", "Attach p")
	
	hPanel3 :=  Form_Add(hForm1,  "Panel",   "",	  "style=hidden","Align F,," hPanel2, "Attach p -")

	
	hCal1	:=  Form_Add(hPanel3, "MonthCal","",	  "gOnControl",	"Align F", "Attach p")

	hEdit1	:=  Form_Add(hPanel2, "Edit",	 "Press F2 to switch panel",  "",	"Align T, 200", "Attach p")
	hLV		:=  Form_Add(hPanel2, "ListView", "1|2|3", "gOnControl","Align T, 200", "Attach p")
	hCal1	:=  Form_Add(hPanel2, "MonthCal","",	  "",			"Align F", "Attach p")
	hHE		:=  Form_Add(hPanel2, "HiEdit",	"HiEdit1",  "DllPath=inc\hiedit.dll style='HSCROLL HILIGHT TABBED FILECHANGEALERT'", "Align F", "Attach p")

	Form_Show()
return

F1::
	WinMove, ahk_id %hForm1%, , , , 300, 300
return

F2::
	if toggled
	{
		WinHide, ahk_id %hPanel3%
		WinShow, ahk_id %hPanel2%

		;fix HiEdit bug
		 Win_MoveDelta(hPanel2, "", "", 1, "")

		toggled := 0
	}
	else {
		WinHide, ahk_id %hPanel2%
		WinShow, ahk_id %hPanel3%
		toggled := 1
	}
return

OnControl:
	msgbox % A_GuiCOntrol
return

Form1_Close:
	ExitApp
return

#include ..\..\inc
#include _Forms.ahk