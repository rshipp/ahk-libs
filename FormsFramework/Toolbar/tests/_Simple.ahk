   Gui, +LastFound
   hGui := WinExist()
   Gui, Show , w500 h100 Hide                              ;set gui width & height prior to adding toolbar (mandatory)
 
   hCtrl := Toolbar_Add(hGui, "OnToolbar", "nodivider FLAT TOOLTIPS", "1L")    ;add the toolbar
 
   btns =
	(LTrim
	   new,  7,            ,dropdown showtext
	   open, 8
	   save, 9, disabled
	   -
	   undo, 4,            ,dropdown
	   redo, 5,            ,dropdown
	   -----
	   state, 11, checked  ,check
	)
 
	Toolbar_Insert(hCtrl, btns)
	Toolbar_SetButtonWidth(hCtrl, 50)                   ;set button width & height to 50 pixels
 
	Gui, Show
return

GuiClose:
	ExitApp
return

;toolbar event handler
OnToolbar(hCtrl, Event, Pos, Txt){				
	tooltip %Event% %Txt% (%Pos%), 0, 0
}
#include ..\Toolbar.ahk