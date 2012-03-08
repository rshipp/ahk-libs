#NoEnv

#Include %A_ScriptDir%\SQLite3.ahk

DatabaseFile := A_ScriptDir . "\World.db3"
SQLQuery := "SELECT * FROM City WHERE Population < 100000 ORDER BY Population DESC"

SetBatchLines, -1

Gui, Font, s18 Bold, Arial
Gui, Add, Text, x2 y0 w470 h30 Center, SQLite Database
Gui, Font, s10
Gui, Add, Text, x2 y40 w50 h40, Query:
Gui, Font, Norm
Gui, Add, Edit, x52 y40 w340 h40 vSQLQuery, %SQLQuery%
Gui, Add, Button, x400 y40 w70 h40 gExecuteQuery Default, Execute
Gui, Font, s8
Gui, Add, ListView, x2 y90 w470 h260 vDataView

OnExit, ExitSub
SQLiteStartup()
If SQLiteOpenDB(hDatabase,DatabaseFile)
 Gosub, SQLiteError
Gui, Show, w475 h355, Database
Gosub, ExecuteQuery
Return

GuiEscape:
GuiClose:
ExitApp

ExecuteQuery:
GuiControlGet, SQLQuery,, SQLQuery
If SQLitePrepareQuery(hQuery,hDatabase,SQLQuery)
 Gosub, SQLiteError
GuiControl, -Redraw, DataView
Loop, %Columns%
 LV_DeleteCol(1)
If SQLiteGetColumnNames(hQuery,Columns,Names)
 Gosub, SQLiteError
Loop, Parse, Names, |
 LV_InsertCol(A_Index,"AutoHdr",A_LoopField)
GuiControl, +Count%Columns%, DataView
LV_Delete(), Timer()
While, ((Temp1 := SQLiteGetData(hQuery,TempRow)) <> 101)
{
 If (Temp1 <> 100)
  Gosub, SQLiteError
 LV_Add(), A_Index1 := A_Index
 Loop, Parse, TempRow, |
  LV_Modify(A_Index1,"Col" . A_Index,A_LoopField)
}
TotalTime := Timer()
Loop, %Columns%
 LV_ModifyCol(A_Index,"AutoHdr")
GuiControl, +Redraw, DataView
SQLiteFreeQuery(hQuery)
ToolTip, Query executed in %TotalTime% milliseconds., 0, 0
Return

SQLiteError:
SQLiteGetLastError(hDatabase,Message)
MsgBox %Message%
ExitApp

ExitSub:
SQLiteCloseDB(hDatabase)
SQLiteShutdown()
ExitApp

Timer()
{
 static TimerBefore
 TimerBefore <> "" ? (DllCall("QueryPerformanceCounter","Int64*",TimerAfter), DllCall("QueryPerformanceFrequency","Int64*",TicksPerMillisecond), TicksPerMillisecond /= 1000, Result := (TimerAfter - TimerBefore) / TicksPerMillisecond, TimerBefore := "") : DllCall("QueryPerformanceCounter","Int64*",TimerBefore)
 Return, Result
}

/*
SQLiteStartup()
SQLiteOpenDB(hDatabase,A_ScriptDir . "\World.db3")

;If SQLiteExec(database,"INSERT INTO tbl1 values('testing, testing',123);")
 ;ErrorMessage()
If SQLiteGetTable(hDatabase,"SELECT ID,Name,Population FROM City WHERE Population >= 5000000",Rows,Columns,Names,Result)
 ErrorMessage()
MsgBox % Result

SQL = SELECT * FROM City WHERE ID <= :MaxID
If SQLitePrepareQuery(hQuery,hDatabase,SQL)
 ErrorMessage()
If SQLiteGetColumnNames(hQuery,Columns,Names)
 ErrorMessage()
Loop, 3
{
 String = %A_Index%
 SQLiteBindQuery(hQuery,":MaxID",String)
 Result = 
 Loop
 {
  ;ListLines, Off
  Temp1 := SQLiteGetData(hQuery,TempRow)
  ;ListLines, On
  If Temp1 <> 100
  {
   If Temp1 = 101
    Break
   ErrorMessage()
  }
  Result .= TempRow . "`n"
  Rows = %A_Index%
 }
 SQLiteResetQuery(hQuery)
 StringTrimRight, Result, Result, StrLen(SQLiteRowDelimiter)
 MsgBox, %Names%`n"%Result%"`n`n%Columns%
 Clipboard = %Result%
}
SQLiteFreeQuery(hQuery)
SQLiteCloseDB(hDatabase)
SQLiteShutdown()
ExitApp

ErrorMessage()
{
 global hDatabase
 SQLiteGetLastError(hDatabase,Message)
 MsgBox %Message%
 ExitApp
}
*/