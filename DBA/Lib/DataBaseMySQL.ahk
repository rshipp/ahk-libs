#NoEnv
#Include <mySQL>
#Include <DataBase>
#Include <RecordSetMySQL>

class MySQL
{
	__New(){
		throw Exception("This is a static Class. Don't create Instances from it!",-1)
	}
}

/*
	Represents a Connection to a SQLite Database
*/
class DataBaseMySQL extends DataBase
{
	_handleDB := 0
	_connectionData := []
	
	__New(connectionData){
		if(!IsObject(connectionData))
			throw Exception("Expected connectionData Array!")
		this._connectionData := connectionData
		
		this.Connect()
	}
	
	/*
		(Re) Connects to the db with the given creditals
	*/
	Connect(){
		connectionData := this._connectionData
		
		if(!connectionData.Port){
		  dbHandle := MySQL_Connect(connectionData.Server, connectionData.Uid, connectionData.Pwd, connectionData.Database)
		}else {
		  dbHandle := MySQL_Connect(connectionData.Server, connectionData.Uid, connectionData.Pwd, connectionData.Database, connectionData.Port)
		}
		this._handleDB := dbHandle
	}
	
	Close(){
		/*
		ToDo!
		*/
	}
	
	IsValid(){
		return (this._handleDB != 0)
	}
	
	GetLastError(){
		return MySQL_GetLastErrorNo(this._handleDB)
	}
	
	GetLastErrorMsg(){
		return MySQL_GetLastErrorMsg(this._handleDB)
	}
	
	SetTimeout(timeout = 1000){
		/* 
		todo 
		*/
	}
	
	
   ErrMsg() {
		return DllCall("libmySQL.dll\mysql_error", "UInt", this._handleDB, "AStr")
   }

   ErrCode() {
		return DllCall("libmySQL.dll\mysql_errno", "UInt", this._handleDB) ; "Cdecl UInt"
   }

   Changes() {
      /*
		ToDo
	  */
   }
	
	
	/*
		Querys the DB and returns a RecordSet
	*/
	OpenRecordSet(sql){
		
		result := MySQL_Query(this._handleDB, sql)
		
		if (result != 0) {
			errCode := this.ErrCode()
			if(errCode == 2003 || errCode == 2006 || errCode == 0){ ;// we've lost the connection
				;// try reconnect
				this.Connect()
				result := MySQL_Query(this._handleDB, sql)
				if (result != 0)
					return false ; we failed again. bye bye
			} else {
				HandleMySQLError(this._handleDB, "dbQuery Fail", sql)
				return false ; unexpected error. bye bye
			}
		}
		
		requestResult := MySQL_Use_Result(this._handleDB)
		if(!requestResult)
			return false
		
		return new RecordSetMySQL(this._handleDB, requestResult)
	}
	
	/*
		Querys the DB and returns a ResultTable or true/false
	*/
	Query(sql){
		return this._GetTableObj(sql)
	}
	
	EscapeString(str){
		return Mysql_escape_string(str)
	}
	
	
	BeginTransaction(){
		this.Query("START TRANSACTION;")
	}
	
	EndTransaction(){
		this.Query("COMMIT;")
	}
	
	InsertMany(records, tableName){
		
		sql := ""
		
		for each, record in records
		{
			insertSQL := "INSERT INTO " tableName " "
			colstring := "("
			valString := "VALUES ("
			for column, value in record
			{
				colstring .= column "," 
				valString .= "'" this.EscapeString(value) "', "
			}
			colstring := SubStr(colstring,1, strlen(colstring)-1)
			valString := SubStr(valString,1, strlen(valString)-2)
			colstring .= ")"
			valString .= ")"
			insertSQL .= colstring " " valString ";"
			sql .= insertSQL
		}
		
		return this.Query(sql)
	}
	
	Insert(record, tableName){
		records := new Collection()
		records.Add(record)
		return this.InsertMany(records, tableName)
	}
	
	
	
	_GetTableObj(sql, maxResult = -1) {
	
		result := MySQL_Query(this._handleDB, sql)
		
		if (result != 0) {
			errCode := this.ErrCode()
			if(errCode == 2004 || errCode == 2006 || errCode == 0){ ;// we probably lost the connection
				;// try reconnect
				this.Connect()
				result := MySQL_Query(this._handleDB, sql)
				if (result != 0)
					return false ; we failed again. bye bye
			} else {
				HandleMySQLError(this._handleDB, "dbQuery Fail", sql)
				return false ; unexpected error. bye bye
			}
		}

		requestResult := MySql_Store_Result(this._handleDB)

		if (!requestResult) ; the query was a non {SELECT, SHOW, DESCRIBE, EXPLAIN or CHECK TABLE} statement which doesn't yield any resultset
			return
		
		mysqlFields := MySQL_fetch_fields(requestResult)
		colNames := new Collection()
		columnCount := 0
		for each, mysqlField in mysqlFields
		{
			colNames.Add(mysqlField.Name())
			columnCount++
		}

		rowptr := 0
		myRows := new Collection()
		while((rowptr := MySQL_fetch_row(requestResult)))
		{
			rowIndex := A_Index
			datafields := new Collection()
			
			lengths := MySQL_fetch_lengths(requestResult)
			Loop, % columnCount
			{
				length := GetUIntAtAddress(lengths, A_Index - 1)
				fieldPointer := GetUIntAtAddress(rowptr, A_Index - 1)
				fieldValue := StrGet(fieldPointer, length, "CP0")
				datafields.Add(fieldValue)
			}
			myRows.Add(new Row(colNames, datafields))
		}
		MySQL_free_result(requestResult)
		
		tbl := new Table(myRows, colNames)
		return tbl
	}
		
}
