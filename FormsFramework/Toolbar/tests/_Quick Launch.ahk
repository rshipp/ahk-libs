#SingleInstance, force
SetBatchLines, -1
SetWinDelay, -1

	;============= SETUP ====================
	vertical := 1
	text	 := 1
	caption  := 1		
	icons	 := 0		;0 - small; 1 - large
	;========================================
	
	Gui, +LastFound +ToolWindow +AlwaysOnTop 
	Gui, % caption ? "" : "-caption"

	hGui := WinExist(),
	Gui, Show, w80 h40 Hide, Quick Launch		;set gui width & height (mandatory)

	hIL := IL_Create(5, 5, icons)
	hToolbar := Toolbar_Add(hGui, "OnToolbar",  (vertical ? "VERTICAL " : "") "NODIVIDER ADJUSTABLE TOOLTIPS FLAT", hIL)
	Toolbar_SetMaxTextRows(hToolbar, text )

	
	IniRead, files, quick_launch.cfg, config, files, %A_Space%
	if files != 
	{
		StringReplace, files, files, |, `n, A
		QL_AddFiles(files)
	}
	else msgbox Drop 1 or more exe's on the toolbar`n`nSetup of the toolbar is in the code.`n`nExit to save toolbar and its position

	IniRead, pos, quick_launch.cfg, config, pos
	Gui, Show, %pos%
return


OnToolbar(hToolbar, pEvent, pTxt, pPos, pId) {
	global 
	
	if pEvent = click
		Run, % aFiles_%pID%

	if pEvent in adjust,change
		QL_AddFiles()		;this will resize toolbar :)
}

QL_AddFiles( pFiles="" ) {
	local idx, w, h, name, btnDef, bv, btns
	static ID=100

	DetectHiddenWindows, on
	SysGet, f, 8		;SM_CYFIXEDFRAME , Thickness of the frame around the perimeter of a window that has a caption but is not sizable
	SysGet, cap, 4		;SM_CYCAPTION: Height of a caption area, in pixels.

    loop, parse, pFiles, `n
	{
		id++

		idx := IL_Add(hIL, A_LoopField)
		ifEqual idx, 0, continue

		SplitPath, A_LoopField,,,, name
		btnDef := name "," idx "," (vertical ? "WRAP": "") "," (text ? "showtext": "") "," id
		btns .= btnDef "`n"
		aFiles_%id% := A_LoopField
	}

	Toolbar_Insert(hToolbar, btns)

	Toolbar_GetMaxSize(hToolbar, w,h)
	w += (caption ? 2*f : 0) + 4 
	h += (caption ? cap+6 : 0) + 4
    WinMove, ahk_id %hGui%, , , ,w, h
	Toolbar_AutoSize(hToolbar)
}

QL_Save() {
	local t, cnt, files

	loop, % Toolbar_Count(hToolbar)
	{
		t := Toolbar_GetButton(hToolbar, A_Index, "id")
		files .= aFiles_%t% "|"		
	}

	WinGetPos, x, y,,, ahk_id %hGui%
	IniWrite, %files%, quick_launch.cfg, config, files
	IniWrite, x%x% y%y%, quick_launch.cfg, config, pos
}

GuiDropFiles:
	QL_AddFiles( A_GuiEvent ) 
return

GuiClose:
	QL_Save()
	ExitApp
return

#include ..\Toolbar.ahk		;version 2.0