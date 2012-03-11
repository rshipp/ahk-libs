#NoEnv
;#Warn All
;#Warn, LocalSameAsGlobal, Off

SetWorkingDir %A_ScriptDir% 
#Include <Database>


initialSQL := "SELECT * FROM Test"
databaseType := "SQLite" ;MySQL | SQLite

if(databaseType = "SQLite"){
	
	connectionString := A_ScriptDir . "\TEST.DB" ; SQLite Connectionstring
	; creates new DB when DB Path doesnt Exist
	if(FileExist(connectionString))
	   FileDelete, %connectionString%
	db := DataBaseFactory.OpenDataBase("SQLite", connectionString) ; SQLite
	CreateTestData(db) ; SQLite
	
} else if(databaseType = "MySQL") {

	connectionString := "Server=localhost;Port=3306;Database=test;Uid=root;Pwd=toor;"
	db := DataBaseFactory.OpenDataBase("MySQL", connectionString) ; MySQL
	
} else {
		MsgBox, 16, Error, Unkonwn Database type: '%databaseType%'!
}


Gui, +LastFound +OwnDialogs
Gui, Margin, 10, 10
Gui, Add, Text, w100 h20 0x200 vTX, SQL statement:
Gui, Add, ComboBox, x+0 ym w590 vSQL Sort, %initialSQL%||
GuiControlGet, P, Pos, SQL
GuiControl, Move, TX, h%PH%
Gui, Add, Button, ym w80 hp vRun gRunSQL Default, Run
Gui, Add, Text, xm h20 w100 0x200, Table name:
Gui, Add, GroupBox, xm w780 h330 , Results
Gui, Add, ListView, xp+10 yp+18 w760 h300 vResultsLV,
Gui, Add, Button, gTestRecordSetClick, [Test RecordSet]
Gui, Add, StatusBar,
Gui, Show, , sqlite test oop


res := db.Query("Select * from Test")
if(is(res,"Table")){
	SB_SetText("The Selection yielded " res.Count() " results.")
	ShowTable("ResultsLV", res)
}

TestInsert(db)

return

TestRecordSetClick:
	TestRecordSet(db, initialSQL)
return

GuiClose:
	db.Close()
Exitapp

;=======================================================================================================================
; Execute SQL-Statement
;=======================================================================================================================
RunSQL:
	GuiControlGet, SQL
	state := ""
	if(Trim(SQL) == "")
	{
	   SB_SetText("No text entered")
	   Return
	}
	res := db.Query(SQL)
	
	if(is(res, "Table")){
		SB_SetText("The Selection yielded " res.Count() " results.")
		ShowTable("ResultsLV", res)
	} else {
		state := "Non selection Query executed! Ret: " res
	}
	
	if(!IsObject(res) && !res){
			state := "!# " db.GetLastErrorMsg() " " res
	}
	if(state != "")
		SB_SetText(state)
return

TestInsert(db){
	;Table Layout: Name, Fname, Phone, Room
	record := {}
	record.Name := "Hans"
	record.Fname := "Meier"
	record.Phone := "93737337"
	record.Room := "wtf is room!? :D"
	db.Insert(record, "Test")
	
	res := db.Query("Select * from Test")
	if(is(res,"Table")){
		SB_SetText("The Selection yielded " res.Count() " results.")
		ShowTable("ResultsLV", res)
	}
}


TestRecordSet(db, sQry){
	rs := db.OpenRecordSet(sQry)
	while(!rs.EOF){	
		name := rs["Name"] 
		phone := rs["Phone"]

		MsgBox %name% %phone%
		rs.MoveNext()
	}
	rs.Close()
	MsgBox done :)
}

ShowTable(listView, table){
	
	GuiControl, -ReDraw, %listView%
	Gui, ListView, %listView%
	if(!is(table, "Table"))
		throw Exception("Table Object expected!",-1)
	
	LV_Delete()
	Loop, % LV_GetCount("Column")
	   LV_DeleteCol(1)
   
	for each, colName in table.Columns 
		LV_InsertCol(A_Index,"", colName)
	
	columnCount := table.Columns.Count()
	
	for each, row in table.Rows
	{
		rowNum := LV_Add("", "")
		Loop, % columnCount
			LV_Modify(rowNum, "Col" . A_index, row[A_index])
	}
	LV_ModifyCol()
	GuiControl, +ReDraw, %listView%
}

CreateTestData(db){
	
	SB_SetText("Create Test Data")
	
	db.Query("CREATE TABLE Test (Name, Fname, Phone, Room, PRIMARY KEY(Name ASC, FName ASC));")
	
	db.BeginTransaction()
	{
		_SQL := "INSERT INTO Test VALUES('Name#', 'Fname#', 'Phone#', 'Room#');"
		sQry := ""
		i := 501
		Loop, 1000 {
		   StringReplace, cSQL, _SQL, #, %i%, All
			sQry .= cSQL
		   i++
		}
		if (!db.Query(sQry)) {
			  Msg := "ErrorLevel: " . ErrorLevel . "`n" . SQLite_LastError()
			  MsgBox, 0, ERROR from EXEC, %Msg%
		}
	}db.EndTransaction()
}
