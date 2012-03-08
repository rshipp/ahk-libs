#NoEnv

;All functions return an SQLite result code (0 for success)

;Loads SQLite3
SQLiteStartup()
{
 global hSQLite
 global SQLiteColumnDelimiter
 global SQLiteRowDelimiter
 If (SQLiteColumnDelimiter = "")
  SQLiteColumnDelimiter = |
 If (SQLiteRowDelimiter = "")
  SQLiteRowDelimiter = `n
 hSQLite := DllCall("LoadLibrary","Str",A_ScriptDir . "\SQLite3.dll")
 Return, (!hSQLite || ErrorLevel || DllCall("sqlite3\sqlite3_initialize") || ErrorLevel)
}

;Unloads SQLite3
SQLiteShutdown()
{
 global hSQLite
 Return, (!DllCall("FreeLibrary","UInt",hSQLite) || ErrorLevel)
}

;Opens a database
SQLiteOpenDB(ByRef hDatabase,DBFile = ":memory:") ;Variable to store the database handle in, Path to the database file (omit to create a database in memory, pass an empty string makes a temporary database on disk)
{
 hDatabase = 
 Return, DllCall("sqlite3\sqlite3_open","Str",DBFile,"UInt*",hDatabase,"Cdecl Int")
}

;Closes an open database
SQLiteCloseDB(ByRef hDatabase) ;Database handle
{
 Temp1 := DllCall("sqlite3\sqlite3_close","UInt",hDatabase,"Cdecl Int"), hDatabase := ""
 Return, Temp1
}

;Gets the result of an SQL query
SQLiteGetTable(hDatabase,SQL,ByRef Rows,ByRef Cols,ByRef Names = "",ByRef Result = "",MaxResult = -1) ;Database handle, SQL query, Variable to store the number of rows in, Variable to store the number of columns in, Variable to store the names (labels) of the columns in, Variable to store the result (columns separated by "ColDelim", rows separated by "RowDelim"), Maximum number of results (-1 for all rows, 0 to get only the number of rows and columns, 1 to get column names as well as the number of rows and columns)
{
 global SQLiteColumnDelimiter
 global SQLiteRowDelimiter
 Rows := 0, Cols := 0, pResult := 0, Names := "", Result := "", Row := "", Offset := 0
 Temp1 := DllCall("sqlite3\sqlite3_get_table","UInt",hDatabase,"UInt",&SQL,"UInt*",pResult,"UInt*",Rows,"UInt*",Cols,"UInt",0,"Cdecl Int")
 If Temp1
  Return, Temp1
 If MaxResult = 0
  Return, DllCall("sqlite3\sqlite3_free_table","UInt",pResult,"Cdecl")
 % (MaxResult = 1) ? MaxResult := 0 : ((MaxResult < 0 || MaxResult > Rows) ? MaxResult := Rows)
 Loop, %Cols%
  Names .= DllCall("MulDiv","UInt",NumGet(pResult + Offset),"Int",1,"Int",1,"Str") . SQLiteColumnDelimiter, Offset += 4
 Temp1 := StrLen(SQLiteColumnDelimiter)
 StringTrimRight, Names, Names, Temp1
 Temp2 := 0 - Temp1
 Loop, %MaxResult%
 {
  Loop, %Cols%
   Row .= DllCall("MulDiv","UInt",NumGet(pResult + Offset),"Int",1,"Int",1,"Str") . SQLiteColumnDelimiter, Offset += 4
  Result .= SubStr(Row,1,Temp2) . SQLiteRowDelimiter, Row := ""
 }
 StringTrimRight, Result, Result, Temp1
 Return, DllCall("SQLite3\sqlite3_free_table","UInt",pResult,"Cdecl")
}

;Executes a non-query SQL statement, and does not handle results
SQLiteExec(hDatabase,SQL) ;Database handle, SQL statement
{
 Return, DllCall("sqlite3\sqlite3_exec","UInt",hDatabase,"UInt",&SQL,"UInt",0,"UInt",0,"UInt*",0,"Cdecl Int")
}

;Prepares a single-statement SQL query
SQLitePrepareQuery(ByRef hQuery,hDatabase,ByRef SQL) ;Variable to store the query handle in, Database handle, SQL statement to be prepared
{
 hQuery = 0
 Return, DllCall("sqlite3\sqlite3_prepare_v2","UInt",hDatabase,"UInt",&SQL,"Int",StrLen(SQL),"UInt*",hQuery,"UInt",0,"Cdecl Int")
}

;Binds values to SQL parameters
SQLiteBindQuery(hQuery,SQLParameter = 1,ByRef Value = "") ;Query handle, Parameter index or named parameter, Value to bind
{
 If SQLParameter Is Not Digit
 {
  SQLParameter := DllCall("sqlite3\sqlite3_bind_parameter_index","UInt",hQuery,"UInt",&SQLParameter,"Cdecl Int")
  If Not SQLParameter
   Return, 1
 }
 If Value Is Number
 {
  If Value Is Integer
   Return, DllCall("sqlite3\sqlite3_bind_int64","UInt",hQuery,"UInt",SQLParameter,"UInt",Value,"Cdecl Int")
  Else
   Return, DllCall("sqlite3\sqlite3_bind_double","UInt",hQuery,"UInt",SQLParameter,"Double",Value,"Cdecl Int")
 }
 Return, DllCall("sqlite3\sqlite3_bind_text","UInt",hQuery,"UInt",1,"UInt",&Value,"UInt",StrLen(Value),"UInt",0,"Cdecl Int")
}

;Resets a query prepared with "SQLitePrepareQuery" for reuse
SQLiteResetQuery(hQuery) ;Query handle
{
 Return, DllCall("sqlite3\sqlite3_reset","UInt",hQuery,"Cdecl Int")
}

;Frees a query prepared with "SQLitePrepareQuery", and invalidates the query handle
SQLiteFreeQuery(hQuery) ;Query handle
{
 Return, DllCall("sqlite3\sqlite3_finalize","UInt",hQuery,"Cdecl Int")
}

;Gets the column names (labels) from a query prepared with "SQLitePrepareQuery"
SQLiteGetColumnNames(hQuery,ByRef ColumnCount,ByRef Names) ;Query handle, Variable to store the number of columns in, Variable to store the column names in (delimited by "SQLiteColumnDelimiter")
{
 global hSQLite
 global SQLiteColumnDelimiter
 Names := "", ColumnCount := DllCall("sqlite3\sqlite3_column_count","UInt",hQuery,"Cdecl Int")
 If Not ColumnCount
  Return, 1
 Temp1 := DllCall("GetProcAddress","UInt",hSQLite,"Str","sqlite3_column_name")
 Loop, %ColumnCount%
  Names .= DllCall(Temp1,"UInt",hQuery,"Int",A_Index - 1,"Cdecl Str") . SQLiteColumnDelimiter
 StringTrimRight, Names, Names, StrLen(SQLiteColumnDelimiter)
 Return, 0
}

;Gets the next row of data from a query prepared with "SQLitePrepareQuery"
SQLiteGetData(hQuery,ByRef Row) ;Query handle, Variable to store the row of data in (delimited by "SQLiteColumnDelimiter")
{
 global hSQLite
 global SQLiteColumnDelimiter
 Row := "", Code := DllCall("sqlite3\sqlite3_step","UInt",hQuery,"Cdecl Int")
 If Code <> 100 ;SQLITE_ROW
 {
  If Code <> 101 ;SQLITE_DONE
   SQLiteFreeQuery(hQuery)
  Return, Code
 }
 DataCount := DllCall("sqlite3\sqlite3_data_count","UInt",hQuery,"Cdecl Int")
 If Not DataCount
  Return, 1
 Temp1 := DllCall("GetProcAddress","UInt",hSQLite,"Str","sqlite3_column_text")
 Loop, %DataCount%
  Row .= DllCall(Temp1,"UInt",hQuery,"Int",A_Index - 1,"Cdecl Str") . SQLiteColumnDelimiter
 StringTrimRight, Row, Row, StrLen(SQLiteColumnDelimiter)
 Return, 100 ;SQLITE_ROW
}

;Gets the ROWID of the most recent INSERT into the database
SQLiteLastInsertRowID(hDatabase,ByRef RowID) ;Database handle, Variable to put the ROWID in
{
 RowID := DllCall("SQLite3\sqlite3_last_insert_rowid","UInt",hDatabase,"Cdecl UInt")
 Return, 0
}

;Gets the number of rows changed by the most recent query
SQLiteRecentChanges(hDatabase,ByRef Rows) ;Database handle, Variable to store the number of changed rows in
{
 Rows := DllCall("SQLite3\sqlite3_changes","UInt",hDatabase,"Cdecl UInt")
 Return, 0
}

;Get the total number of rows changed, added, or removed since the DB connection was created.
SQLiteTotalChanges(hDatabase,ByRef Rows) ;Database handle, Variable to store the total number of changed rows in
{
 Rows := DllCall("SQLite3\sqlite3_total_changes","UInt",hDatabase,"Cdecl UInt")
 Return, 0
}

;Sets time out for database "busy handler"
SQLiteSetTimeOut(hDatabase,TimeOut = 1000) ;Database handle, Time out in milliseconds
{
 Return, DllCall("SQLite3\sqlite3_busy_timeout","UInt",hDatabase,"Cdecl Int")
}

;Gets the version number of the SQLite DLL
SQLiteGetVersion(ByRef Version)
{
 Version := DllCall("sqlite3\sqlite3_libversion","Cdecl Str")
 Return, 0
}

;Gets the last SQLite error
SQLiteGetLastError(ByRef hDatabase,ByRef ErrorMessage,ByRef UseExtended = 0) ;Database handle, Variable to store the error message in, Whether or not extended result codes will be used
{
 static Code0 := "OK" ;Successful result

 static Code1 := "ERROR" ;SQL error or missing database
 static Code2 := "INTERNAL" ;Internal logic error in SQLite
 static Code3 := "PERM" ;Access permission denied
 static Code4 := "ABORT" ;Callback routine requested an abort
 static Code5 := "BUSY" ;The database file is locked
 static Code6 := "LOCKED" ;A table in the database is locked
 static Code7 := "NOMEM" ;A malloc() failed
 static Code8 := "READONLY" ;Attempt to write a readonly database
 static Code9 := "INTERRUPT" ;Operation terminated by sqlite3_interrupt()
 static Code10 := "IOERR" ;Some kind of disk I/O error occurred
 static Code11 := "CORRUPT" ;The database disk image is malformed
 static Code12 := "NOTFOUND" ;NOT USED. Table or record not found
 static Code13 := "FULL" ;Insertion failed because database is full
 static Code14 := "CANTOPEN" ;Unable to open the database file
 static Code15 := "PROTOCOL" ;Unable to open the database file
 static Code16 := "EMPTY" ;Database is empty
 static Code17 := "SCHEMA" ;The database schema changed
 static Code18 := "TOOBIG" ;String or BLOB exceeds size limit
 static Code19 := "CONSTRAINT" ;Abort due to constraint violation
 static Code20 := "MISMATCH" ;Data type mismatch
 static Code21 := "MISUSE" ;Library used incorrectly
 static Code22 := "NOLFS" ;Uses OS features not supported on host
 static Code23 := "AUTH" ;Authorization denied
 static Code24 := "FORMAT" ;Auxiliary database format error
 static Code25 := "RANGE" ;2nd parameter to sqlite3_bind out of range
 static Code26 := "NOTADB" ;File opened that is not a database file
 static Code100 := "ROW" ;sqlite3_step() has another row ready
 static Code101 := "DONE" ;sqlite3_step() has finished executing

 static Code266 := "IOERR_READ"
 static Code522 := "IOERR_SHORT_READ"
 static Code778 := "IOERR_WRITE"
 static Code1034 := "IOERR_FSYNC"
 static Code1290 := "IOERR_DIR_FSYNC"
 static Code1546 := "IOERR_TRUNCATE"
 static Code1802 := "IOERR_FSTAT"
 static Code2058 := "IOERR_UNLOCK"
 static Code2314 := "IOERR_RDLOCK"
 static Code2570 := "IOERR_DELETE"
 static Code2826 := "IOERR_BLOCKED"
 static Code3082 := "IOERR_NOMEM"
 static Code3338 := "IOERR_ACCESS"
 static Code3594 := "IOERR_CHECKRESERVEDLOCK"
 static Code3850 := "IOERR_LOCK"
 static Code4106 := "IOERR_CLOSE"
 static Code4362 := "IOERR_DIR_CLOSE"
 static Code4618 := "IOERR_SHMOPEN"
 static Code4874 := "IOERR_SHMSIZE"
 static Code5130 := "IOERR_SHMLOCK"
 static Code5386 := "IOERR_SHMMAP"
 static Code5642 := "IOERR_SEEK"
 static Code262 := "LOCKED_SHAREDCACHE"
 static Code261 := "BUSY_RECOVERY"
 static Code270 := "CANTOPEN_NOTEMPDIR"
 static Code267 := "CORRUPT_VTAB"
 static Code264 := "READONLY_RECOVERY"
 static Code520 := "READONLY_CANTLOCK"

 ErrorMessage := DllCall("SQLite3\sqlite3_" . (UseExtended ? "extended_" : "") . "errcode","UInt",hDatabase,"Cdecl UInt"), ErrorMessage := "SQLITE_" . Code%ErrorMessage% . ": " . DllCall("sqlite3\sqlite3_errmsg","UInt",hDatabase,"Cdecl Str")
 Return, 0
}