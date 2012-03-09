#SingleInstance, force

	Gui, +LastFound
	hGui := WinExist(), 

	Gui, Show, w300 h300 Hide		;set gui width


	h1 := Toolbar_Add(hGui, "OnToolbar", "vertical flat nodivider border", 3, "x0")
	h2 := Toolbar_Add(hGui, "OnToolbar", "wrapable flat nodivider border", 1, "x0")
	Toolbar_SetButtonSize(h2, 150)

	btns = 
		(LTrim
			cut, ,wrap
			copy ,,wrap
			paste,,wrap
			undo,,wrap
			redo,,wrap
		 )
	Toolbar_Insert(h1, btns)
	Toolbar_Insert(h2, btns)
	Toolbar_Autosize(h1, "br") ;bottom right
	Toolbar_Autosize(h2, "bl") ;bottom left

	Gui, Show
return

OnToolbar(h,e,t,p,i){
	tooltip %e% %t%
}

GuiEscape:
GuiClose:
	exitapp
return

#include ..\Toolbar.ahk