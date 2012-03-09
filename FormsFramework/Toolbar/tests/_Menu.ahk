#SingleInstance, force

	Gui, +LastFound
	hGui := WinExist(), 

	Gui, Show, w300 h200 Hide		;set gui width


	h := Toolbar_Add(hGui, "OnToolbar", "menu")
	btns = 
		(LTrim
			File
			Edit
			View
			Search
			Help
		 )
	Toolbar_Insert(h, btns)
	Toolbar_GetMaxSize(h, w, h), h+=4
	Gui, Margin,2,%h%

	Gui, Add, Button,w100, Button
	Gui, Add, Button,y+5 w100, Button
	Gui, Add, Button,y+5 w100, Button
	Gui, Show
return

OnToolbar(h,e,t,p,i){
	ifequal, e, hot, return
	msgbox %t%
}

GuiClose:
	exitapp
return

#include ..\Toolbar.ahk