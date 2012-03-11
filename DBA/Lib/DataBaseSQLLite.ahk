#NoEnv
#Include <SQLite_L>
#Include <DataBase>

class SQLite
{
	GetVersion(){
		return SQLite_LibVersion()
	}
	
	SQLiteExe(dbFile, commands, ByRef output){
		return SQLite_SQLiteExe(dbFile, commands, output)
	}
	
	__New(){
		throw Exception("This is a static Class. Don't create Instances from it!",-1)
	}
}

/*
	Represents a Connection to a SQLite Database
*/
class DataBaseSQLLite extends DataBase
{
	_handleDB := 0
	
	Close(){
		return SQLite_CloseDB(this._handleDB)
	}
	
	IsValid(){
		return (this._handleDB != 0)
	}
	
	GetLastError(){
		code := 0
		SQLite_ErrCode(this._handleDB, code)
		return code
	}
	
	GetLastErrorMsg(){
		msg := ""
		SQLite_ErrMsg(this._handleDB, msg)
		return msg
	}
	
	SetTimeout(timeout = 1000){
		return SQLite_SetTimeout(this._handleDB, timeout)
	}
	
	
   ErrMsg() {
      if (RC := DllCall("SQLite3\sqlite3_errmsg", "UInt", this._handleDB, "Cdecl UInt"))
         return StrGet(RC, "UTF-8")
      return ""
   }

   ErrCode() {
      return DllCall("SQLite3\sqlite3_errcode", "UInt", this._handleDB, "Cdecl UInt")
   }

   Changes() {
      return DllCall("SQLite3\sqlite3_changes", "UInt", this._handleDB, "Cdecl UInt")
   }
	
	
	/*
		Querys the DB and returns a RecordSet
	*/
	OpenRecordSet(sql){
		return new RecordSetSqlLite(this, SQlite_Query(this._handleDB, sql))
	}
	
	/*
		Querys the DB and returns a ResultTable or true/false
	*/
	Query(sql){
		if (RegExMatch(sql, "i)^\s*SELECT\s")){
			return, this._GetTableObj(sql)
		} else {
		  return SQLite_Exec(this._handleDB, sql)
		}
	}
	
	EscapeString(str){
		return Mysql_escape_string(str)
	}
	
	
	BeginTransaction(){
		this.Query("BEGIN TRANSACTION;")
	}
	
	EndTransaction(){
		this.Query("COMMIT TRANSACTION;")
	}
	
	__New(handleDB){
		this._handleDB := handleDB
	}
	
	InsertMany(records, tableName){
		SQLite_FetchData("Select * from " tableName, tableColumns)
		sql := ""
		
		for each, record in records
		{
			insertSQL := "INSERT INTO " tableName " "
			colstring := "("
			valString := "VALUES ("
			for column, value in record
			{
				colstring .= column ", " 
				valString .= "'" this.EscapeString(value) "', "
			}
			colstring := SubStr(colstring,1, strlen(colstring)-2)
			valString := SubStr(valString,1, strlen(valString)-2)
			colstring .= ")"
			valString .= ")"
			insertSQL .= colstring " " valString ";"
			sql .= insertSQL
		}
		
		return this.Query(sql)
	}
	
	Insert(record, tableName){
		col := new Collection()
		col.Add(record)
		return this.InsertMany(col, tableName)
	}
	
	
	
	_GetTableObj(sql, maxResult = -1) {
		err := 0, rc := 0, GetRows := 0
		i := 0
		rows := cols := 0
		names := new Collection()
		dbh := this._handleDB
		
		SQLite_LastError(" ")
	
	   if(!_SQLite_CheckDB(dbh)) {
		  SQLite_LastError("ERROR: Invalid database handle " . dbh)
		  ErrorLevel := _SQLite_ReturnCode("SQLITE_ERROR")
		  return False
	   }
	   if maxResult Is Not Integer
		  maxResult := -1
	   if (maxResult < -1)
		  maxResult := -1
	   mytable := ""
	   Err := 0
	   _SQLite_StrToUTF8(SQL, UTF8)
	   RC := DllCall("SQlite3\sqlite3_get_table", "UInt", dbh, "UInt", &UTF8, "UIntP", mytable
				   , "UIntP", rows, "UIntP", cols, "UIntP", err, "Cdecl Int")
	   If (ErrorLevel) {
		  SQLite_LastError("ERROR: DLLCall sqlite3_get_table failed!")
		  Return False
	   }
	   If (rc) {
		  SQLite_LastError(StrGet(err, "UTF-8"))
		  DllCall("SQLite3\sqlite3_free", "UInt", err)
		  ErrorLevel := rc
		  return false
	   }

	   if (maxResult = 0) {
		  DllCall("SQLite3\sqlite3_free_table", "UInt", mytable, "Cdecl")   
		  If (ErrorLevel) {
			 SQLite_LastError("ERROR: DLLCall sqlite3_close failed!")
			 Return False
		  }
		  Return True
	   }
	   if (maxResult = 1)
		  GetRows := 0
	   else if (maxResult > 1) && (maxResult < rows)
		  GetRows := MaxResult
	   else
		  GetRows := rows
	   Offset := 0
	   
	   Loop, % cols
	   {
		  names.Add(StrGet(NumGet(mytable+0, Offset), "UTF-8"))
		  Offset += 4
	   }

		myRows := new Collection()
		Loop, %GetRows% {
			i := A_Index
			fields := new Collection()
			Loop, % Cols 
			{
				fields.Add(StrGet(NumGet(mytable+0, Offset), "UTF-8"))
				Offset += 4
			}
			myRows.Add(new Row(Names, fields))
		}
		tbl := new Table(myRows, Names)
		
		; Free Results Memory
		DllCall("SQLite3\sqlite3_free_table", "UInt", mytable, "Cdecl")   
		if (ErrorLevel) {
			SQLite_LastError("ERROR: DLLCall sqlite3_close failed!")
			return false
		}
		return tbl
	}
	

   ReturnCode(RC) {
      static RCODE := {SQLITE_OK: 0          ; Successful result
                     , SQLITE_ERROR: 1       ; SQL error or missing database
                     , SQLITE_INTERNAL: 2    ; NOT USED. Internal logic error in SQLite
                     , SQLITE_PERM: 3        ; Access permission denied
                     , SQLITE_ABORT: 4       ; Callback routine requested an abort
                     , SQLITE_BUSY: 5        ; The database file is locked
                     , SQLITE_LOCKED: 6      ; A table in the database is locked
                     , SQLITE_NOMEM: 7       ; A malloc() failed
                     , SQLITE_READONLY: 8    ; Attempt to write a readonly database
                     , SQLITE_INTERRUPT: 9   ; Operation terminated by sqlite3_interrupt()
                     , SQLITE_IOERR: 10      ; Some kind of disk I/O error occurred
                     , SQLITE_CORRUPT: 11    ; The database disk image is malformed
                     , SQLITE_NOTFOUND: 12   ; NOT USED. Table or record not found
                     , SQLITE_FULL: 13       ; Insertion failed because database is full
                     , SQLITE_CANTOPEN: 14   ; Unable to open the database file
                     , SQLITE_PROTOCOL: 15   ; NOT USED. Database lock protocol error
                     , SQLITE_EMPTY: 16      ; Database is empty
                     , SQLITE_SCHEMA: 17     ; The database schema changed
                     , SQLITE_TOOBIG: 18     ; String or BLOB exceeds size limit
                     , SQLITE_CONSTRAINT: 19 ; Abort due to constraint violation
                     , SQLITE_MISMATCH: 20   ; Data type mismatch
                     , SQLITE_MISUSE: 21     ; Library used incorrectly
                     , SQLITE_NOLFS: 22      ; Uses OS features not supported on host
                     , SQLITE_AUTH: 23       ; Authorization denied
                     , SQLITE_FORMAT: 24     ; Auxiliary database format error
                     , SQLITE_RANGE: 25      ; 2nd parameter to sqlite3_bind out of range
                     , SQLITE_NOTADB: 26     ; File opened that is not a database file
                     , SQLITE_ROW: 100       ; sqlite3_step() has another row ready
                     , SQLITE_DONE: 101}     ; sqlite3_step() has finished executing
      return RCODE.HasKey(RC) ? RCODE[RC] : ""
   }	
}
