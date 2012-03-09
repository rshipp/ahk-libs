_("mo! e")
	OnExit OnExit
	;oldTaskbar := AppBar_SetTaskbar("+autohide")
	Shell_GetQuickLaunch()

	GroupAdd, AppBar, ahk_class DV2ControlHost		;add start menu so first appbar doesn't close when we launch it.

	n := AppBar_New(hApp1)
	Fatal("Can't create Appbar", n=0)
	
	AppBar_New(hApp2,  "Edge=Left", "Pos=p-300 h100", "Style=Show OnTop", "Label=AppBar2")
	Fatal("Can't create Appbar", k=0)

	AppBar_New(hApp3,  "Edge=Left", "AutoHide=Slide", "Pos=w100 h100 p300", "Label=AppBar3")
	Fatal("Can't create Appbar", k=0)

; This works too :)
;	Run, Notepad
;	WinWait, Untitled
;	WinSet, Style, 
;	hApp3 := WinExist("Untitled")
;	AppBar_New(hApp3,  "Edge=Right", "AutoHide=Blend", "Pos=w100 h100 p300", "Label=AppBar3")


	Gui, %n%:Add, Text, HWNDhDummy
	Gui, %n%:Add, Button, HWNDhStart gOnStart x4 w50 y2, Start
	hRebar := Rebar_Add(hApp1, "", "", "x60 h32 w" A_ScreenWidth-60)	
	
	hQuickLaunch := MakeQuickLaunch(hApp1, w)	
	hTaskBar := MakeTaskBar(hApp1)
	hTray	:= MakeTray(hApp1, w2)

;	ReBar_Insert(hRebar, hDummy)	;put this dummy one so next one can be moved.
	ReBar_Insert(hRebar, hQuickLaunch, "L " w+20 , "S gripperalways usechevron")
	ReBar_Insert(hRebar, hTaskBar, "L " A_ScreenWidth - w - w2 - 100)
	ReBar_Insert(hRebar, hTray)

	Shell_SetHook("OnShell")
return


Refresh() {
	global
	MakeTaskbar(hTaskBar, true)
	MakeTray(hTray, w, true)
}


OnShell(Event, Param) {	
	global
	static WINDOWCREATED=1, WINDOWDESTROYED=2, WINDOWACTIVATED=4, GETMINRECT=5, REDRAW=6, TASKMAN=7, LANGUAGE=8, SYSMENU=9, ENDTASK=10, APPCOMMAND=12, ENDTASK

	if Event in %WINDOWCREATED%,%WINDOWDESTROYED%
		Refresh()		

	if Event = 4		;event doesn't work on Vista.
		Toolbar_CheckButton(hTaskbar, "." Param)
}

OnQuickLaunch(hCtrl, Event, Txt, Pos, Id)){
	if (Event="click") {
		t := v("qlt" id), d := v("qld" id)
		Run, %t%,%d%
	}
	else if (Event="rclick")
		Shell_ContextMenu( v("qll" id) )	
}

OnTaskBar(hCtrl, Event, Txt, Pos, Id)){
	global hApp1

	if Event=click
		WinActivate, ahk_id %id%
	
	if Event=rclick
		Win_ShowSysMenu(Id)
}

OnTray(hCtrl, Event, Txt, Pos, Id){
	static lastpos
	IfEqual, Event, hot
	{
		if (lastpos != pos)
			ShowTooltip( Tray_GetTooltip( pos ) )
		lastpos := pos
		return 1		;prevent hot item showing, the same as windows tray
	}
}

ShowTooltip( Msg, X="" ,Y="", TimeIn=500, TimeOut=1500){
	static 
	_Msg := Msg, _X:=X, _Y:=Y
	MouseGetPos, , , , _ctrl

	t1 := -TimeIn, t2 := -TimeOut
	SetTimer, ShowTooltipOn, %t1%
	return

 ShowTooltipOff:
	Tooltip, , , , 19
 return

 ShowTooltipOn:
	SetTimer, ShowTooltipOff, %t2%
	MouseGetPos, , , , ctrl
	ifNotEqual, ctrl, %_ctrl%, return
	Tooltip,%_Msg% , _X, _Y, 19
 return
}

;AppBarContextMenu:
;	ShowMenu("[Menu]`nToggle Lock")
;return

Menu:
	if A_ThisMenuItem contains Lock
		Rebar_Lock(hRebar, "~")
return


OnExit:
	AppBar_Remove(hApp1)
	AppBar_Remove(hApp2)
	AppBar_Remove(hApp3)
	if oldTaskbar
		AppBar_SetTaskbar(oldTaskbar)

	Shell_SetHook()
	ExitApp
return


MakeTaskBar(hGui, refresh=0) {
	static hIL, hT
	
	if !refresh
		 hIL := ImageList_Create(24, 24, 0x21, 10, 10), 	hT := Toolbar_Add(hGui, "OnTaskbar", "FLAT TOOLTIPS LIST", hIL, "x0")
	else ImageList_Remove(hIL), Toolbar_Clear(hT)


	s := Taskbar_Define("", "wto") 
	loop, parse, s, `n
	{
		StringSplit, k, A_LoopField, |
		ifEqual, k2, , continue
		if StrLen(k2) > 20
			k2 := SubStr(k2, 1, 20) "..."
		k3 := GetWindowIcon(k1)
		StringReplace, k2, k2,`,,,A
		i := ImageList_AddIcon( hIL, k3 ), b .= k2 ",,,CHECKGROUP SHOWTEXT," k1 "`n"
	}
	Toolbar_Insert(hT, b)
	return hT
}

MakeTray(hGui, ByRef w, Refresh=0){

	static hIL, hT
	if !refresh
		 hIL := ImageList_Create(24, 24, 0x21, 10, 10), hT := Toolbar_Add(hGui, "OnTray", "FLAT LIST", hIL, "x0")
	else ImageList_Remove(hIL), Toolbar_Clear(hT)

	s := Tray_Define("", "o")	
	loop, parse, s, `n
		i := ImageList_AddIcon( hIL, A_LoopField ), b .= A_Index "`n"
	Toolbar_Insert(hT, b)
	Toolbar_GetMaxSize(hT, w, h)
	return hT
}

MakeQuickLaunch( hGui, ByRef w ) {
	hT:= Toolbar_Add(hGui, "OnQuickLaunch", "ADJUSTABLE FLAT TOOLTIPS LIST", hIL := IL_Create(10, `10, 0), "x0")
	files := Shell_GetQuickLaunch()
	loop, parse, files, `n
	{
		FileGetShortcut, %A_LoopField%, target, dir, , , icon, iconno
		if (icon iconno = "") 
			 IL_Add(hIL, target)
		else IL_Add(hIl, icon, iconno)
		
		SplitPath, A_LoopFIeld, , , , name
		btns .= name "`n"
		v( "qlt" A_Index+10000, target)
		v( "qld" A_Index+10000, dir)
		v( "qll" A_Index+10000, A_LoopField)
	}
	Toolbar_Insert(hT, btns)
	
	Toolbar_GetMaxSize(hT, w, h)			;adjust size so chevron works. Chevron will show if width is lesser then ideal 
	ControlMove,,,,%w%,, ahk_id %hT%		; (which is taken as size of the control on insert by Rebar)
											; AUtosize() doesn't work as it sets h too, and that fucks up...	
	return hT
}

OnStart:
	WinGetPos, x , , , h, ahk_id %hApp1%
	Shell_SMShow(x, h)
return

GetWindowIcon(pHandle, pLarge=true){

	if (pLarge)
		 SendMessage, 0x7F, 1 , 0,, ahk_id %pHandle%
	else SendMessage, 0x7F, 0, 0,, ahk_id %pHandle%
	hIcon := ErrorLevel 
			
	if !hIcon { 
		SendMessage, 0x7F, 0, 0,, ahk_id %pHandle%
		hIcon := ErrorLevel
		if !hIcon { 
			hIcon := DllCall( "GetClassLong", "uint", pHandle, "int", -34 )
			if !hIcon
				hIcon := DllCall("LoadIcon", "uint", 0, "uint", 32512 ) ; 
		} 
	} 

	return hIcon
}


#include AppBar.ahk
#include Rebar.ahk
#include Toolbar.ahk
#include Shell.ahk
#include ShellContextMenu.ahk
#include Tray.ahk
#include ShowMenu.ahk
#include IL.ahk
#include Win.ahk
#include Taskbar.ahk
#include _.ahk