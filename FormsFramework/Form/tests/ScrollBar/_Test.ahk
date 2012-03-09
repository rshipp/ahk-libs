_("mo!")
#SingleInstance force
	Gui,  +LastFound
	hGui := WinExist()
	
	Gui, Add, Edit, +vscroll y50 h100 w230 HWNDhEdit, 0
	hHBar := ScrollBar_Add(hGui, 0,   10, 280, 15,  "OnScroll", "min=0", "max=50", "page=5")
	hVBar := ScrollBar_Add(hGui, 280, 10, "",  290, "OnScroll", "style=ver", "pos=10")

    ;glue to the myEdit
	hhE := ScrollBar_Add(hGui, hEdit, "", "", "", "OnScroll", "pos=50")
	hvE := ScrollBar_Add(hGui, hEdit, "", "", "", "OnScroll", "style=ver", "pos=50")
																			  
	Gui, Add, Button, x10 y200 0x8000 gOnBtn, Show
	Gui, Add, Button, x+0 0x8000 gOnBtn, Hide
	Gui, Add, Button, x+10 0x8000 gOnBtn, Enable
	Gui, Add, Button, x+0 0x8000 gOnBtn, Disable

	Gui, show, h300 w300, ScrollBar Test
return

OnScroll(Hwnd, Pos) {
	global

	if (Hwnd = hHBar) 
		 s := "horizontal"
	else if (Hwnd = hVBar) 
		 s := "vertical"
	else s := "glued"

	ControlSetText, Edit1, %Pos% - %s% bar
}

OnBtn:
	if A_GuiControl in Enable,Disable
		ScrollBar_Enable(hVBar, A_GuiControl="Enable" ), ScrollBar_Enable(hvE, A_GuiControl="Enable" )
	
	if A_GuiControl in Show,Hide
		ScrollBar_Show(hhE, A_GuiControl="Show"), ScrollBar_Show(hvE, A_GuiControl="Show")
return

#include ..\..\inc
#include _Forms.ahk