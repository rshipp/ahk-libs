_()

GetLine(Func){
	ifEqual, Func, , return
	WinGetTitle, title, EditPlus
  
	if !Editor_FileNameFromTitle(title, fn)
		return

	return FindFunction(fn, Func)
}

~^G::
	line := GetLine(Clipboard)
	if !line
		return
	Send, %line%{ENTER}
return



Editor_FileNameFromTitle(Title, ByRef Fn){
	j := RegExMatch(Title, "EditPlus.+\- \[(.+)\]", match)
	ifEqual, j, 0, return false
	
	Fn := match1
	if SubStr(Fn,0) = "*"
		Fn := SubStr(Fn, 1, -2) 
	return, true
}

FindFunction(Fn, Function)
{
	FileRead, txt, %Fn%
	re = `aiS)%Function%\([^)]*\)(\s|\n)*{
	j := RegExMatch(txt, re)
	ifEqual, j, 0, return 0

	len := -2
	loop, parse, txt,`n
	{
		len += StrLen(A_LoopField) + 1
		if (len > j)
			return A_Index
	}
}











































