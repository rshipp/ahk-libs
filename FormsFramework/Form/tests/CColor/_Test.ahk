_("mo! w d e")

	ctrls = Edit Text Radio CheckBox ListBox ComboBox DropDownList ListView TreeView
	FG	  = White
	BG	  = Red
	;========================

	hForm1	:=	Form_New("w400 e3 h700 +Resize Font='s10 bold,Courier'")

	loop, parse, ctrls, %A_Space%
	{
			 Form_Add(hForm1, "Text", A_LoopField, "xm w150")
		h := Form_Add(hForm1, A_LoopField, "Test1|Test2", "x+10 h80 w200 cRed")	
		CColor(h, BG, FG)
	}
	LV_ADD("", "Test1"), TV_Add("Test1")
	LV_ADD("", "Test2"), TV_Add("Test2")
	Form_Show()
	Win_Redraw(hForm1)	
return


Form1_Close:
	exitapp
return


#include ..\..\inc
#include _Forms.ahk