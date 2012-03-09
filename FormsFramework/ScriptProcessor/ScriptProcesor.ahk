#NoTrayIcon
#SingleInstance, force
	
	Gui, Margin, 0, 0
	Gui, Add, Button, x5 y5 g_OnButtonClick w100 0x8000, Add Files
	Gui, Add, Button, xp+290 yp g_OnButtonClick w100 0x8000, Process
	Gui, Add, Listbox, hscroll xm y+5 w400 h300
    Gui, SHow, AutoSize, ScriptProcessor v1.0 by majkinetor
	ControlGet, files, List,,ListBox1,A
return


_OnButtonClick:
	operation := A_GuiControl

	if (operation = "Add Files")
	{
   		FileSelectFile, fn,M,,Select file to minimize,AHK Scripts (*.ahk)
		ifEqual,ErrorLevel,1,return
		path := SubStr(fn, 1, j := InStr(fn, "`n")-1)
		files := SubStr(fn, j+2)
		StringReplace, files, files, `n, |%path%\, A
		GuiControl,,ListBox1, %path%\%files%
	}
	if (operation = "Process")
	{
		ControlGet, files, List,,ListBox1,A
		loop, parse, files, `n
			if !ProcessFile(A_LoopField, "* mini"){
				MsgBox, 16, , Problem processing file:`n%A_LoopField%
				break
			}
	}
return

ProcessFile(FileName, NewFileName) {
	if SubStr(NewFileName, 1,1)="*"
	{
		j := InStr(FileName, ".", 0)
		ifNotEqual, j,0, SetEnv, ext, % SubStr(FileName, j)
		NewFileName := SubStr(FileName, 1, j-1) SubStr(NewFileName,2) ext
	}
	FileRead, content, %FileName%
	r := Mini(content)
	ifEqual, r, 0, return 0
	FileDelete, %NewFileName%
	FileAppend, %content%, %NewFileName%
	return 1
}

Mini(ByRef Content) {
	DelComments(Content)
	DelBlanks(Content)
	Trim(Content)
	return 1
}

DelComments(ByRef Content) {
	re = S)/\*(.|[\r\n])*?\*/
    Content := regexreplace(Content,re) ; '/*' anything '*/'
    Content := regexreplace(Content,"[ \t^]+\;(.*)") ; ';'anything
	return ErrorLevel=0 ? 1 : 0
}

Trim(ByRef Content) {
	AutoTrim, on
	c := Content, Content := ""
	loop, parse, c, `r`n,
	{	
		line = %A_loopField%
		ifEqual, line, , continue
		Content .= line "`n"
	}
	return 1
}

DelBlanks(ByRef Content) {
	Content := regexreplace(content,"\n\s*\n", "`n")
	return ErrorLevel=0 ? 1 : 0
}

Anchor(c, a, r = false) { ; v3.5.1 - Titan
	static d
	GuiControlGet, p, Pos, %c%
	If !A_Gui or ErrorLevel
		Return
	i = x.w.y.h./.7.%A_GuiWidth%.%A_GuiHeight%.`n%A_Gui%:%c%=
	StringSplit, i, i, .
	d .= (n := !InStr(d, i9)) ? i9 :
	Loop, 4
		x := A_Index, j := i%x%, i6 += x = 3
		, k := !RegExMatch(a, j . "([\d.]+)", v) + (v1 ? v1 : 0)
		, e := p%j% - i%i6% * k, d .= n ? e . i5 : ""
		, RegExMatch(d, RegExReplace(i9, "([[\\\^\$\.\|\?\*\+\(\)])", "\$1")
		. "(?:([\d.\-]+)/){" . x . "}", v)
		, l .= InStr(a, j) ? j . v1 + i%i6% * k : ""
	r := r ? "Draw" :
	GuiControl, Move%r%, %c%, %l%
}