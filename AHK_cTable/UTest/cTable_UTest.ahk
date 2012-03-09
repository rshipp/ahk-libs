; http://www.autohotkey.com/forum/viewtopic.php?t=65995
;--------------------------------------------                                                           ; _DBG_
; Activate DBGView and clean up output                                                                  ; _DBG_
RunActivateOrSwitch("d:\Portable\PortableApps\WSCCPortable\App\WSCC\Sysinternals Suite\Dbgview.exe") 	; _DBG_
WinWaitActive, ahk_class dbgviewClass 																	; _DBG_
Sleep,10 																								; _DBG_
SendInput {Ctrl Down}{x}{Ctrl Up} 																		; _DBG_
;--------------------------------------------                                                           ; _DBG_
requiredVersion:="0.0.8.0"


; -------------------------------------------------------------------------------------------------------------
; ------------- DO NOT MODIFY INPUT DATA ----------------------------------------------------------------------
; ------------- If modified, Unittests need to be adapted -----------------------------------------------------
; -------------------------------------------------------------------------------------------------------------
Variable =      ; column names are specified as first row
(
First name%A_Tab%Last name%A_Tab%Occupation%A_Tab%Notes
Jack%A_Tab%Gates%A_Tab%Driver%A_Tab%
Mark%A_Tab%Weber%A_Tab%Student%A_Tab%His father is a driver.
Jim%A_Tab%Tucker%A_Tab%Driver%A_Tab%
Jill%A_Tab%Lochte%A_Tab%Artist%A_Tab%Jack's sister.
Jessica%A_Tab%Hickman%A_Tab%Student%A_Tab%
Mary%A_Tab%Jones%A_Tab%Teacher%A_Tab%Her favorite song is "D r i v e r".
Lenny%A_Tab%Stark%A_Tab%Driver%A_Tab%
Jack%A_Tab%Black%A_Tab%Actor%A_Tab%His wife is artist.
Anny%A_Tab%Jackman%A_Tab%Surfer%A_Tab%
Johny%A_Tab%Poor%A_Tab%Beggar%A_Tab%
Scott%A_Tab%Jenstan%A_Tab%Teacher%A_Tab%Lives in New York.
)

VariableRow =
(
Jack%A_Tab%Gates%A_Tab%Driver%A_Tab%
)

ahktest()
Return 

#include UTest.ahk
#include ..\cTable.ahk

Test_cTable_AccessByArrayIndex() {
   global variable
   oTable := new cTable(variable)
   Assert(oTable.3.2="Tucker")
}

Test_cTable_AddRow() {
   global variable
   oTable := new cTable(variable)
   oTable.AddRow("Joe", "Newman", "Kiteboarder", "Freestyle & Wave")
   Assert(oTable.12.2="Newman", oTable.MaxIndex()=12)
}

Test_cTable_Col2Num() {
   global variable
   oTable := new cTable(variable)
   Assert(oTable.Col2Num("Occupation")=3, oTable.Col2Num("First name|Notes")="1|4", oTable.Col2Num("Missing")= )
}

Test_cTable_DeleteRow() {
   global variable
   oTable := new cTable(variable)
   oTable2 := new cTable(variable)
   oTable2.DeleteRow(2)   ; delete 2. row   
   Assert(oTable.2.1="Mark", oTable2.2.1="Jim", oTable.MaxIndex()=11, oTable2.MaxIndex()=10)
   oTable2 := new cTable(variable)
   oTable2.DeleteRow(2)      ; delete last row
   Assert(oTable.11.1="Scott", oTable2.11.1="", oTable.11.1=oTable2.10.1, oTable.MaxIndex()=11, oTable2.MaxIndex()=10)
   oTable2 := new cTable(variable)
   oTable2.DeleteRow(0)   ; delete all rows
   Assert(oTable2.MaxIndex()="", oTable2.2.1="")
}

Test_cTable_InsertRow() {
   global variable
   oTable := new cTable(variable)
   oTable.InsertRow(2 ,"Mike", "Insertovich", "Actor")
   Assert(oTable.2.2="Insertovich", oTable.MaxIndex()=12)
}

Test_cTable_ManipulationByArrayIndex() {
   global variable
   oTable := new cTable(variable)
   Assert(oTable.1.1="Jack")
   oTable.1.1 := "Bobby" 
   Assert(oTable.1.1="Bobby")
}

Test_cTable_MaxIndex() {
   global variable
   oTable := new cTable(variable)
   Assert(oTable.MaxIndex()=11, oTable.ColumnNames.MaxIndex()=4)
}

Test_cTable_ModifyRow() {
   global variable
   oTable := new cTable(variable)
   oTable2 := new cTable(variable)
   oTable3 := new cTable(variable)
   oTable2.ModifyRow(3 ,"Sergey", "Modifysky", "Actor")   ; modify row number 3.
   oTable3.ModifyRow(0 ,"Chris", "Allman", "Actor")   ; modify all existing rows
   Assert(oTable.3.1="Jim", oTable2.3.1="Sergey", oTable3.1.1="Chris", oTable3.3.1="Chris", oTable3.11.1="Chris", oTable.MaxIndex()=11)
}

Test_cTable_NewFromScheme() {
   global variable
   oTable := new cTable(variable)
   oTable2 := oTable.NewFromScheme()
   Assert(oTable.ColumnNames.1=oTable2.ColumnNames.1, oTable.ColumnNames.3=oTable2.ColumnNames.3, oTable.MaxIndex()=11, oTable2.MaxIndex()="")
}


Test_cTable_Reload() {
   global variable
   oTable := new cTable(variable)
   oTable2 := new cTable(variable)
   oTable2.SaveAs("tmp_ctable.txt")
   oTable2.Reload()
   Assert(oTable.1.1=oTable2.1.1,oTable.11.4=oTable2.11.4)
}


Test_cTable_Row2Num() {
   global variable
   oTable := new cTable(variable)
   Assert(oTable.Row2Num("Jonny", "Rich", "Beggar")=, oTable.Row2Num("Jack", "Gates", "Driver")=1, oTable.Row2Num("Jonny", "Poor", "Beggar")=10)
}

Test_cTable_Search_AllColumn_ContainingP() {
   global variable
   oTable := new cTable(variable)
   oFound1 := oTable.Search("", "Driver", "containing+")  ; search whole table (all columns) for containing string "driver" but ignore withespaces
   Assert(oFound1.MaxIndex()=5, oFound1.5.3="Driver", oFound1.4.3="Teacher", oFound1.3.3="Driver", oFound1.2.3="Student", oFound1.1.3="Driver")
}

Test_cTable_Search_AllColumn_Exactly() {
   global variable
   oTable := new cTable(variable)
   oFound1 := oTable.Search("", "Jack", "exactly")  ; search whole table (all columns) for string "Jack" (not containing, but exactly) 
   Assert(oFound1.MaxIndex()=2, oFound1.1.1="Jack", oFound1.2.1="Jack")
}

Test_cTable_Search_MultiColumn_Containing() {
   global variable
   oTable := new cTable(variable)
   oFound1 := oTable.Search("Occupation|Notes", "Driver")    ; search Occupation and Notes columns for containing string "driver"
   Assert(oFound1.MaxIndex()=4, oFound1.4.3="Driver", oFound1.3.3="Driver", oFound1.2.3="Student", oFound1.1.3="Driver")
}

Test_cTable_Search_SingleColumn_Containing() {
   global variable
   oTable := new cTable(variable)
   oFound := oTable.Search("Occupation", "Drive") ; search Occupation column for containing string "drive"
   Assert(oFound.MaxIndex()=3, oFound.1.3="Driver", oFound.2.3="Driver",oFound.3.3="Driver")
}

Test_cTable_Search_SingleColumn_EndingWith() {
   global variable
   oTable := new cTable(variable)
   oFound := oTable.Search("First name", "ny", "EndingWith")    ;  search first names ending with "ny"
   Assert(oFound.MaxIndex()=3, oFound.1.1="Lenny", oFound.2.1="Anny", oFound.3.1="Johny")
}

Test_cTable_Search_SingleColumn_Regex() {
   global variable
   oTable := new cTable(variable)
   oFound := oTable.Search("Last name", "^J.*an$", "RegEx") ; Search for all last names starting with "J" and ending with "an".
   Assert(oFound.MaxIndex()=2, oFound.1.2="Jackman", oFound.2.2="Jenstan")
}

Test_cTable_Search_SingleColumn_StartingWith() {
   global variable
   oTable := new cTable(variable)
   oFound := oTable.Search("Last name", "ja|bla", "StartingWith")    ;  search last names starting with "ja" or "bla"
   Assert(oFound.MaxIndex()=2, oFound.1.2="Black", oFound.2.2="Jackman")
}

Test_cTable_Search_SingleColumn_Exactly() {
   global variable
   oTable := new cTable(variable)
   oFound1 := oTable.Search("Occupation", "Drive", "Exactly") ; search Occupation column for containing string "drive", as "exactly" is choosen nothing should be found
   oFound2 := oTable.Search("Occupation", "Driver", "Exactly") ; search Occupation column for containing string "driver"
   Assert(oFound1.MaxIndex()="", oFound2.MaxIndex()=3, oFound2.1.3="Driver", oFound2.2.3="Driver",oFound2.3.3="Driver")
}

Test_cTable_SearchChained() {
   global variable
   oTable := new cTable(variable)
   ; chained (multiple search) ...
   oFound2 := oFound2 := oTable.Search("Occupation|Notes", "Driver|artist").Search("First name", "J")
   Assert(oFound2.MaxIndex()=4, (oFound2.1.1="Jack" && oFound2.1.3="Driver")=1, (oFound2.2.1="Jim" && oFound2.2.3="Driver"), (oFound2.3.1="Jill" && oFound2.3.3="Artist"), (oFound2.4.1="Jack" && oFound2.4.4="His wife is artist.") )
}

Test_cTable_SearchChained_Plain() {
   global variable
   oTable := new cTable(variable)
   ; step 1: search "Occupation" and "Notes" columns for containing "Driver" or "artist" strings. "|" is query delimiter.
   ; step 2: search that search result again: search "First name" column for containing "J" string
   oFound := oTable.Search("Occupation|Notes", "Driver|artist")      ; store search results as object
   oFound2 := oFound.Search("First name", "J")      ; search oFound (second search filter)
   Assert(oFound.MaxIndex()=6, oFound2.MaxIndex()=4, (oFound2.1.1="Jack" && oFound2.1.3="Driver")=1, (oFound2.2.1="Jim" && oFound2.2.3="Driver"), (oFound2.3.1="Jill" && oFound2.3.3="Artist"), (oFound2.4.1="Jack" && oFound2.4.4="His wife is artist.") )
}

Test_cTable_StringReplace() {
   global variable
   oTable := new cTable(variable)
   oTable2 := new cTable(variable)
   oTable2.StringReplace("a", "X", "nn", "XXXX")   ; replaces "param1" with "param2", "param3" with "param4" (etc.) in all fields in table object.
   Assert(oTable.1.1="Jack", oTable2.1.1="JXck", oTable.4.3="Artist", oTable2.4.3="Xrtist", oTable.10.1="Johny", oTable2.10.1="Johny", oTable.9.1="Anny", oTable2.9.1="XXXXXy")
}
 
Test_cTable_StringReplace_CaseSensitive() {
   global variable
   oTable := new cTable(variable)
   oTable2 := new cTable(variable)
   StringCaseSense, On
   oTable2.StringReplace("a", "X", "nn", "XXXX")   ; replaces "param1" with "param2", "param3" with "param4" (etc.) in all fields in table object.
   Assert(oTable.1.1="Jack", oTable2.1.1="JXck", oTable.4.3="Artist", oTable2.4.3="Artist", oTable.9.1="Anny", oTable2.9.1="AXXXXy")
}


Test_cTable_ToString_Row() {
   global variable
   oTable := new cTable(variable)
   
   ; Get the first reference value ...
   index := 3
   allines := object()
   Loop, parse, variable, `n
      allines.insert(A_LoopField)
   refVar1 := allines[index+1]
   
   ; Get the second reference value ...
   index := 11
   allines := object()
   Loop, parse, variable, `n
      allines.insert(A_LoopField)
   var := allines[index+1]
   stringReplace  refVar2, var, %A_Tab%, #, 1
   
   ; do the unit test
   ; First: Using the standard ColumnDelimiter
   ; Second: Using # as ColumnDelimiter
   Assert(oTable.3.ToString()=refVar1, oTable.11.ToString("#")=refVar2)
}

Test_cTable_ToString_Table() {
   global variable
   oTable := new cTable(variable)
   
   ; Get the first reference value (table header)...
   index := 1
   allines := object()
   Loop, parse, variable, `n
      allines.insert(A_LoopField)
   refVar1 := allines[index]
   
   ; do the unit test
   Assert(variable=(oTable.HeaderToString() "`n" oTable.ToString()), oTable.HeaderToString()=refVar1)
}

Test_cTable_Version() {
   global variable
   global requiredVersion
   oTable := new cTable(variable)
   Assert(oTable.Version()>=requiredVersion)
}

Test_cTableRow_New() {
   global variableRow
   oRow := new cTableRow(VariableRow, 4)
   Assert(oRow.1="Jack")
}

Test_cTableRow_MaxIndex() {
   global variableRow
   oRow := new cTableRow(VariableRow, 4)
   Assert(oRow.MaxIndex()="4")
}

/*
Test_cTable_Fail() {
   Assert(1=2, 2=2, 3=2)
   Assert(3=4)
}
*/

#include, RunActivateOrSwitch.ahk  ; _DBG_
