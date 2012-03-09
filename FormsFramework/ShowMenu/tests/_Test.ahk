#SingleInstance, force
	Gui, Add, Button, h22 gOnButton, Show
	Gui, Add, Edit, h22 x+5 w100 veName, Main
	Gui, Add, Button, w22 h22 x+130 gonBtnAbout 0x8000, ?
	Gui, Add, Text, xm yp+45,Menu definition:
	Gui, Font,, Courier New
	Gui, Add, Edit, veMenu xm w300 h200, [Main]`n*first item`n+second item`n-`nthird item=[Sub1]`n`n[Sub1]`nsub menu 1=www.google.com`nsub menu 2=www.autohotkey.com`n
	Gui, Add, Text, xm w300 h100 vtxtResult,Return value:
	Gui, Show
return

onButton:
	Gui, Submit, NoHide
	res := ShowMenu(eMenu, eName, "OnMenu")
	GuiControl,, txtResult, Return value:`n`n%res%
	loop, parse, res, `n
		Menu, %A_LoopField%, delete
return						  

OnMenu:
	data := ShowMenu_Data(eMenu)
	Tooltip %A_ThisMenu%  -  %A_ThisMenuItem%`nUser data: "%data%", 0, 0
return

OnBtnAbout:
   res := ShowMenu("[Info]`nForum`nAbout")
   GuiControl,, txtResult, Return value:`n`n%res%
return

Info:
	goto Info_%A_ThisMenuItemPos%

	Info_1:
		Run, http://www.autohotkey.com/forum/topic23138.html
		return
	Info_2:
		MsgBox v1.1 by majkinetor
	return

return

GuiEscape:
GuiClose:
  ExitApp
return

#include ..\ShowMenu.ahk