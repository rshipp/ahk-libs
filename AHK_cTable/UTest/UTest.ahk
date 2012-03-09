/* Title: UTest 
modified by Naveen Garg 
changes: removed dependency on lowlevel functions which were brittle.
         added stack trace information for failed tests

originally by majkinetor: http://www.autohotkey.com/forum/author-majkinetor.html
forum: http://www.autohotkey.com/forum/viewtopic.php?t=49262

		  Unit testing framework.

		  (see Utest.png)

 Usage:	
		 UTest will scan the script for functions which name starts with "Test_". Test functions have no parameter and use one of the 
		 Assert functions. If Assert function fails, test will fail and you will see that in the result output.txt with stack trace of failed tests.


		 To test your script, use the following template :

		(start code)
			ahktest() ; use ahktest(1) if you want more debug output ...
			Return 
            #include UTest.ahk
			
            Test_MyTest1() {
				assert(1, expr2, expr3)
			}

			Test_MyTest2(expr1, expr2) {
			}
			...
			...
			#include FunctionsToTest.ahk
		(end code)

 
*/			
bFullOutput := 0

ahktest(FullOutput = 0) {						       
	
	#SingleInstance, force							       
	Global bFullOutput
	
	bFullOutput := FullOutput
	
	UTest("Result", UTest_Start( UTest("NoGui") ))	;execute tests
	output := "All tests successfull"
	If FileExist("output.txt") {
		run, notepad output.txt									
		FileRead, output, output.txt
	}
	return output
}

       
Assert(b1="", b2=1, b3=1, b4=1, b5=1, b6=1, b7=1, b8=1, b9=1, b10=1) {
	e := {}
	bFail := 0
	iFail := ""
	loop, 10{
		if A_Index == 1
			Continue
		if !b%A_Index% {
			e.insert("Test on param " A_Index " failed")
			if bFail {
				iFail := iFail ","
			}
			iFail := iFail " " A_Index
			bFail := 1
		}
	}
		
	if e[1]{
		stack := getStackTrace()
		stack := RemoveUTestFunctionsFromStackTrace(stack)
		te := exception("fail", -1)
		s :=  tostring(e) "at Line " getLineSource(te.line, te.file) "`nin file " te.file " line " te.line "`nstacktrace: " 
		stack[0] := s
		
		UTest_setFail(getLineSource(te.line, te.file),iFail, te.line)
		throw stack
	} 
	else {
		; Unit tests where succesfull ...
		UTest_setOK()
	}
}

UTest_Edit( Path, LineNumber ) {
	Run, "notepad" "%Path%"
	SetTitleMatchMode, 2
	WinWait, Editor
	Sleep 200
	SendInput {Ctrl Down}g{Ctrl Up}
	Sleep 200
	SendInput %LineNumber%{Enter}
}

;===================================================== PRIVATE ======================================


UTest_runTests() {
	FileDelete, output.txt
	tests := UTest_GetTests(), bNoGui := UTest("NoGui")
	if  (tests = "") {
		msgbox No tests found !
		ExitApp
	}

	bTestsFail := 0
	Global bFullOutput
	loop, parse, tests, `n 
	{
		StringSplit, f, A_LoopField, %A_Space%
		fName := SubStr(f1,6)
		; OutputDebug % "f1:" f1
		try {
			%f1%()		
		} catch e{
			if (bFullOutput = 1) {
				FileAppend % "Test " fname " - " A_Index . ":`n" tostring(e) "******************************************`n", output.txt
			}
		}
		bFail := UTest("F")
		Param := UTest("Param")
		Name := UTest("Name")
		Line := UTest("Line")
		ifEqual, bFail, 1, SetEnv, bTestsFail, 1

		s .= (bFail ? "FAIL" : "OK") "," fName "," f2 "," Name "," Param "`n"
		UTest("F", 0),	UTest("Param", ""), UTest("Name", "")

		if !bNoGui
			LV_Add("Icon" (bFail+1) " " (bFail ? "Select" : ""), bFail ? "FAIL" : "OK", fName, Line, Name, Param)
	}
	
	if !bNoGui
		LV_ModifyCol(), LV_ModifyCol(1, 50), LV_ModifyCol(3, 35)
		;, LV_ModifyCol(4, 150), LV_ModifyCol(5, 50)

	UTest("TestsFail", bTestsFail)
	return SubStr(s, 1, -1)
}

UTest_getTests() {
	s := UTest_GetFunctions()
	loop, parse, s, `n
	{
		if SubStr(A_LoopField, 1, 5)="Test_"
			t .= A_LoopField "`n"
	}
	return SubStr(t, 1, -1)
}

UTest_getFunctions() {
	funcs := object()
	fnames := ""
	FileRead, script, %A_ScriptName%
	pos := 1
	while pos{
		pos := regexmatch(script, "([\w_\d]+)\(", m, pos)
		pos += strlen(m1)
		f := func(m1)
		name := f.name
	
		if !f.name
			Continue

		if !f.IsBuiltIn
			funcs[name] := f.name
	} 
	for i, j in funcs {
		fnames .= j . "`n"
	}
    ; msgbox % fnames
   return SubStr(fNames, 1, -1)
}     

UTest_getFreeGuiNum() {
	loop, 99  {
		Gui %A_Index%:+LastFoundExist
		IfWinNotExist
			return A_Index
	}
	return 0
}

UTest_start( bNoGui = false) {
	if !bNoGui
		hGui := UTest_CreateGui()
	s := UTest_RunTests()
	
	if (hGui){
		Result := UTest("TestsFail") ? "FAIL" : "OK"
		ControlSetText,Static1, %Result%, ahk_id %hGui%
	}
	return s
}

UTest_createGui() {
	w := 500, h := 400
	n := UTest_getFreeGuiNum() 

	Gui, %n%: +LastFound +LabelUTest_ +Resize +MinSize
	hGui := WinExist()
	Gui, %n%: Add, ListView, HWNDMyLV w%w% h%h% gUTest_OnList, Result|Test|Line|Name|Param
	ImageListID := IL_Create(2)  ; Create an ImageList to hold 10 small icons.
	LV_SetImageList(ImageListID)  ; Assign the above ImageList to the current ListView.
    IL_Add(ImageListID, "shell32.dll", 209)
	IL_Add(ImageListID, "shell32.dll", 132)

	Gui, %n%: Font, s20 bold cRED, Courier New
	Gui, %n%: Add, Text, HWNDMySummary w%w% h40
	Gui, %n%: Show,autosize, UTest - %A_ScriptName%
	UTest("GUINO", n)
	
	gosub SetAttach

	Hotkey, ifWinActive, ahk_id %hGui%
	Hotkey, ESC, UTest_Close
	Hotkey, ifWinActive
	return hGui
	
 SetAttach:
	Attach(MyLV, "w h")
	Attach(MySummary, "y")
    return
	
 UTest_Close:
 	ExitApp
 
	return
}

UTest_setFail(Name="", Param="", Line="") {
	UTest("Param", UTest("Param") " " Param)
	UTest("Name",  UTest("Name") " " Name)
	UTest("Line",  Line)
	UTest("F", 1 )
	return 1
}

UTest_setOK(Name="", Param="", Line="") {
	UTest("Param", UTest("Param") " " Param)
	UTest("Name",  UTest("Name") " " Name)
	UTest("Line", Line)
	UTest("F", 0 )
	return 1
}

UTest_onList:
	ifNotEqual, A_GuiEvent, DoubleClick, return

	LV_GetText(lineNumber, LV_GetNext(), 3)
	UTest_Edit(A_ScriptFullPath, lineNumber)
return

UTest(var="", value="~`a ", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="") { 
	static
	_ := %var%
	ifNotEqual, value,~`a , SetEnv, %var%, %value%
	return _

	return
}

#include util.ahk
#include tostring.ahk
#include Attach.ahk