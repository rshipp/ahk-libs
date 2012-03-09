_("mo! w d")

	Choose()

	Gui, +LastFounds +Resize -caption
	hGui := WinExist()

	Gui, Show, w500 h600 Hide

	Gui, Add, Edit,		HWNDhEdit, F1 - show/hide
	hSplit := Splitter_Add()
	Gui, Add, ListView,	HWNDhList, Top control
	Gui, Add, Text,		h100 0x200 HWNDhText,  Bottom
	Gui, Add, MonthCal, HWNDhCal	

	IniRead, spos, config2.ini, Config, Splitter, %A_Space%
	IniRead, bVisible, config2.ini, Config, Visible, %A_Space%
	IfEqual, bVisible, , SetEnv, bVisible, 1

	SetGui(iLayout)

	if !bVisible
		HideControls(true)

	if !Win_Recall("<", "", "config2.ini")
		Gui, Show

	bHidden := 0
return

F1:: HideControls(bHidden := !bHidden)

SetGui(type=""){
	global 

	if type = 1
	{
		Align(hEdit,  "L"),					Attach(hEdit,	"h")
		Align(hSplit, "L", 6)	,			Attach(hSplit,	"h")
		Align(hList,  "T", 200) ,			Attach(hList,	"w")
		Align(hText,  "B")		,			Attach(hText,	"y w")
		Align(hCal,   "F")		,			Attach(hCal,	"w h")
	
		sdef = %hEdit% | %hList% %hText% %hCal%		
		Splitter_Set( hSplit, sdef, spos != "" ? spos : 100 )
		return
	}

	if type = 2
	{

		Align(hList,  "T", 200) ,			Attach(hList,	"w")
		Align(hEdit,  "L"),					Attach(hEdit,	"h")
		Align(hSplit, "L", 6)	,			Attach(hSplit,	"h")
		Align(hText,  "B")		,			Attach(hText,	"y w")
		Align(hCal,   "F")		,			Attach(hCal,	"w h")
	
		sdef = %hEdit% | %hText% %hCal%			
		Splitter_Set( hSplit, sdef, spos != "" ? spos : 100 )
		return
	}

	if type = 3
	{
		Align(hCal,   "T", 220),			Attach(hCal,	"w")
		Align(hEdit,  "T"),					Attach(hEdit,	"w h")
		Align(hSplit, "T", 6),				Attach(hSplit,	"y w")
		Align(hText,  "B"),					Attach(hText,	"y w")
		Align(hList,  "F") ,				Attach(hList,	"y w")
	
		sdef = %hEdit% - %hList% 	
		Splitter_Set( hSplit, sdef, spos != "" ? spos : 300 )
		return
	}
}

Choose() {
	global iLayout

	IniRead, iLayout, config2.ini, Config, Layout, %A_Space%
	ifNotEqual, iLayout, ,return

	layouts =
	(LTrim Join
		Layout1:    Edit on left, List on top, Text on bottom, Callendar filling up.|
		Layout2:    List on top, Edit on the left, Calendar on the right and Text bellow it.|
		Layout3:    Everything stacks on top of eachother with List filling up.
	)

	Gui, +LastFound +ToolWindow +LabelChoose
	h := WinExist()
	Gui, Font, s10 Arial Narrow
	Gui, Add, Text, , Doubleclick Layout.`nThe choosen layout will be saved in config file.`nDelete config2.ini to restore this dialog.
	Gui, Add, ListBox, gOnLayout w600, %layouts%
	Gui, Show
	
	while 1
	{
		ifWinNotExist, ahk_id %h%
			break
		sleep 100
	}
}

OnLayout:
	if A_GuiEvent = DoubleClick
	{
		SendMessage, 0x188, 0, 0, ListBox1, A
		iLayout := ErrorLevel+1
		Gui, Destroy
		IniWrite, %iLayout%, config2.ini, Config, Layout
	}
return

HideControls(bHide) {
	global 
	if (!bHide)
	{
		WinShow, ahk_id %hText%
		WinShow, ahk_id %hEdit%	
	} else {
		WinHide, ahk_id %hText%
		WinHide, ahk_id %hEdit%	
	}
	Align(hGui)		;re-align (it will reset attach automatically if present among includes)
}

SaveGui() {
	global 
	b := Win_Is(hText, "visible")
	if !b
		HideControls(false)

	p := Splitter_GetPos(hSplit)

	Win_Recall(">", "", "config2.ini")
	IniWrite, %p%, config2.ini, Config, Splitter
	IniWrite, %b%, config2.ini, Config, Visible
}


ESC::
	SaveGui()
	ExitApp
return

GuiEscape:
GuiClose:
	if iLayout !=
		SaveGui()
	ExitApp
return

#include ..\..\inc
#include _Forms.ahk