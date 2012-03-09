/* 
	Scroller has a bug that shows
	when you scroll and resize. This is because p parameter of Attach.
	
	It seems that problem is vertical attaching with vertical scroll and vice-versa.
	When you put w instead of p it doesn't show but its hard to set up this example like that
	(so that all Panels in Form1 use only w and y dimensions in attach.

	I left it that way cuz its still usefull to see all of the controls in the Form1 and how they
	get attached. The problem fixes itself when you scroll to top and resize again.

	This is documented in Scroller.ahk
 */

_("mo! e w")
#MaxThreads, 255

	;=======================================================
	
	siblings  = 25		;desn't make a difference.
	depthlevel = 5		;makes the difference; tests:  vista(32b, quad)=15, xppro(64b, quad)=5

	;=======================================================
	hForm1	:=	Form_New("w500 h600 +Resize")
	loop, %siblings%
	{
		hPanel	 :=	Form_Add(hForm1,  "Panel",	 "",	  "",		"Align T, 300", "Attach w")	; "Attach p" creates problem for scroller.
		loop, %depthlevel%	
			hPanel	 :=	Form_Add(hPanel,  "Panel",	 "",	  "",	"Align F", "Attach p r2")

		hButton1 :=	Form_Add(hPanel,  "Button",  A_Index,	  "",	"Align T, 50",  "Attach p r2", "Cursor hand", "Tooltip I have hand cursor")
		hButton2 :=	Form_Add(hPanel,  "Button",  A_Index,"",	"Align T, 50",  "Attach p r2", "Tooltip jea baby")
		hCal1	:=  Form_Add(hPanel,  "ListView", A_Index,  "",	"Align F",		"Attach p r2")
		LV_Add("",A_TickCount)
	}

	Form_Show()
	Scroller_init()
return


Form1_Size:
	 Scroller_UpdateBars(hForm1)
return

Form1_Close:
	ExitApp
return

#include ..\..\inc
#include _Forms.ahk