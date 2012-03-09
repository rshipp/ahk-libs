_("mo")
	hForm := Form_New("e3 Resize x100 w300 h550 MinSize220")
	Form_Add(hForm, "Toolbar", "Execute,11`nView,7`n-----`nHelp,12", "gOnToolbar", "Align T")
	Form_Add(hForm, "TreeView", "", "gOnTV", "Align F", "Attach w h r2")
	Populate()

	Form_Show("", "", "Choose Sample")
return

OnToolbar(hCtrl, Event, Txt) {
	ifEqual, Event, hot, return

	if Txt = Execute
		Execute()
	
	if Txt = View
	{
		script := SelectionPath(dir)
		ifEqual, script, , Run, %dir%
		else Run, %A_AhkPath% "%A_ScriptDir%\tests\HiEdit\_Test.ahk" "%script%", %A_ScriptDir%\tests\HiEdit
	}

	if Txt = Help
		Run, _doc\index.html 
}

Populate() {
    loop tests\*.*, 1
		if A_LoopFileName not in _res,.svn
		{
			r := TV_Add(A_LoopFileName, 0)
			loop, %A_LoopFileFullPath%\*.ahk
				TV_Add(A_LoopFileName, r)
		}
}

Execute() {
	script := SelectionPath(dir)
	Run, %script%, %dir%
}

SelectionPath(ByRef dir="") {
	id := TV_GetSelection()
	p := TV_GetParent(id)
	TV_GetText(sn, id)
	TV_GetText(pn, p)	

	if b := InStr(sn, ".ahk") 
		dir  = %A_ScriptDir%\tests\%pn%
	else 
		dir = %A_ScriptDir%\tests\%sn%
	return b ? dir "\" sn : ""
}

OnTV:
	if A_GuiEvent = DoubleClick
		Execute()
return

Form1_Close:
	ExitApp
return

F1:: Execute()

#include inc
#include _Forms.ahk