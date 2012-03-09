#SingleInstance, force
	Gui, +LastFound
	hGui := WinExist(), 
	Gui, Show , w410 h360 Hide		;set gui width & height (mandatory)

	h1 := Toolbar_Add(hGui, "OnToolbar", "flat bottom nodivider", 1)
	h2 := Toolbar_Add(hGui, "OnToolbar", "flat", 2)
	h3 := Toolbar_Add(hGui, "OnToolbar", "vertical wrapable nodivider", 3, "x100 y120 w200 h150")

	btns = 
		(LTrim
			cut
			copy
			paste
			---
			undo
			redo
		 )
	Toolbar_Insert(h1, btns)
	Toolbar_Insert(h2, btns)
	Toolbar_Insert(h3, btns)
	Toolbar_SetButtonSize(h3, 60)

	Gui, Show
return

OnToolbar(h,e,t,p,i){
	if e = hot
		return 
	msgbox HWND %h%`nText: %t%
}

GuiClose:
	exitapp
return

#include ..\..\inc
#include _Forms.ahk