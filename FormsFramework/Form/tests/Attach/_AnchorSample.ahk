#SingleInstance, force
	Gui, +Resize +MinSize +LastFound
	hGui := WinExist()

	Gui, Add, Edit, HWNDMyEdit vMyEdit1 w400 h150, Resize this window
	Gui, Add, Button, HWNDMyButton x300 y160 Default gWin2, Open Window 2
	Gui, Add, GroupBox, HWNDMyGroup Section xm h10 w250, Relative positions are also supported ...
	Gui, Add, ComboBox, HWNDMyCombo Section xs+50 ys+25, Item 1|Item 2||Item 3
	Gui, Add, Text, HWNDMyText ys, Select

	Gui, 2:Default
	Gui, +Resize +MinSize +ToolWindow
	Gui, Add, Text, , More sizing...
	Gui, Add, ListBox, HWNDLB Section xm r8, Item 1|Item 2||Item 3
	Gui, Add, Edit, HWNDEdit ys r8
	Gui, Add, Button, HWNDCloseButton w50, Close
	Gui, 1:Default

	gosub SetAttach
	Gui, Show, , Anchor (Attach) Example
Return

F10::
	GuiControl, Move, MyEdit1, w100 h140 ; move control to a size relative to current Gui dimensions
	Attach(hGui) 
Return

Win2:
	Gui, 2:Show, , Window
Return

OnAttach(Hwnd) {
	global
	if (Hwnd != hGui)
		return
	hWinToRedraw := hwnd
	SetTimer, redraw, -100
}

Redraw:
	WinSet, Redraw, ,ahk_id %hWinToRedraw%
return

SetAttach:
	Attach("OnAttach")
	Attach(MyEdit,		"w h")
	Attach(MyButton,	"x y")
	Attach(MyGroup,		"y w")
	Attach(MyCombo,		"y")
	Attach(MyText,		"y")
	Attach(LB,			"w0.5 h")
	Attach(Edit,		"x0.5 w0.5 h")
	Attach(CloseButton,	"x0.75 y")
Return

GuiEscape:
GuiClose:
	ExitApp
return

#include ..\..\inc
#include _Forms.ahk