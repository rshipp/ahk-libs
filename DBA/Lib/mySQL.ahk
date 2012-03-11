/*============================================================
mysql.ahk
Provides a set of functions to connect and query a mysql database

Based upon the published lib of panofish
http://www.autohotkey.com/forum/topic67280.html


Offical Documentation of the C-API
http://dev.mysql.com/doc/refman/5.0/en/c.html
============================================================
*/


/*
   Parses the given Connectionstring to a ConnectionData
   
   An typical Connectionstring looks like:
   Server=myServerAddress;Port=1234;Database=myDataBase;Uid=myUsername;Pwd=myPassword;
   
   Further Info: http://www.connectionstrings.com/mysql
*/
MySQL_CreateConnectionData(connectionString){
   connectionData := {}
   StringSplit, connstr, connectionString, `;
   Loop, % connstr0
   {
      StringSplit, segment,  connstr%a_index%, =
      connectionData[segment1] := segment2
   }
   return connectionData
}



MySQL_StartUp(){
   global MySQL_ExternDir
   MySQL_ExternDir := A_WorkingDir
   
   libDllpath := MySQL_DLLPath()

   if(!FileExist(libDllpath))
   {
      msg := "MySQL Libaray not found!`n" libDllpath " (file missing)"
      OutputDebug, %msg%
      throw Exception(msg,-1)
   }
   
   
   hModule := DllCall("LoadLibrary", "Str", libDllpath)
      
   if (hModule == 0)
   {
      msg := "LoadLibrary failed, can't load module:`n" libDllpath
      OutputDebug, %msg%
      throw Exception(msg, -1)
   }else 
      return hModule
}

MySQL_DLLPath(path = "") {
   static DLLPath := ""
   static dllname := "libmySQL.dll"

   if(DLLPath == ""){
      ; search the dll
      prefix := (A_PtrSize == 8) ? "x64\" : ""
      dllpath := prefix . dllname
      
      if (FileExist(A_ScriptDir . "\" . dllpath))
         DLLPath := A_ScriptDir . "\"  . dllpath
      else
         DLLPath := A_ScriptDir . "\Lib\" . dllpath
   }
   
   if (path != "")
      DLLPath := Path

   return DLLPath
}


/*****************************************************************
 Connect to mysql database and return db handle
 
 host:
 user:
 password:
 database:
 port:          3306(default)
******************************************************************
*/
MySQL_Connect(host, user, password, database, port = 3306){   


   db := DllCall("libmySQL.dll\mysql_init", "ptr", 0)
   If (db = 0)
   {
      MsgBox 16, MySQL Error 445, Not enough memory to connect to MySQL
      ExitApp
   }

   connection := DllCall("libmySQL.dll\mysql_real_connect"
         , "ptr", db
         , "AStr", host       ; host name
         , "AStr", user       ; user name
         , "AStr", password   ; password
         , "AStr", database   ; database name
         , "UInt", port   ; port
         , "UInt", 0   ; unix_socket
         , "UInt", 0)   ; client_flag

   If (connection == 0)
   {
      HandleMySQLError(db, "Cannot connect to database")
      return
   }
   
   ;debugging only:
   ;MsgBox % "Ping database: " . MySQL_Ping(db) . "`nServer version: " . MySQL_GetVersion(db)
   
   return db
}

MySQL_Close(db){
   DllCall("libmySQL.dll\mysql_close", "ptr", db)
}



MySQL_GetVersion(db){
   serverVersion := DllCall("libmySQL.dll\mysql_get_server_info", "ptr", db, "AStr")
   return serverVersion
}
MySQL_Ping(db){
   return DllCall("libmySQL.dll\mysql_ping", "ptr", db)
}

MySQL_GetLastErrorNo(db){
   return DllCall("libmySQL.dll\mysql_errno", "ptr", db)
}

MySQL_GetLastErrorMsg(db){
   return DllCall("libmySQL.dll\mysql_error", "ptr", db, "AStr")
}

/*
Retrieves a complete result set to the client.
*/
MySQL_Store_Result(db) {
   return DllCall("libmySQL.dll\mysql_store_result", "ptr", db)
}

/*
Retrieves the resultset row-by-row
*/
MySQL_Use_Result(db) {
   return DllCall("libmySQL.dll\mysql_use_result", "ptr", db)
}

/*
Returns a requestResult for the given query
*/
MySQL_Query(db, query){
   return DllCall("libmySQL.dll\mysql_query", "ptr", db , "AStr", query)
}

MySQL_free_result(requestResult){
   return DllCall("libmySQL.dll\mysql_free_result", "ptr", requestResult)
}

/*
Returns the number of columns in a result set.
*/
MySQL_num_fields(requestResult) {
   Return DllCall("libmySQL.dll\mysql_num_fields", "ptr", requestResult)
}

/*
Returns the lengths of all columns in the current row.
*/
MySQL_fetch_lengths(requestResult) {
   Return , DllCall("libmySQL.dll\mysql_fetch_lengths", "ptr", requestResult)
}


/*
Fetches the next row from the result set.
*/
MySQL_fetch_row(requestResult) {
   Return , DllCall("libmySQL.dll\mysql_fetch_row", "ptr", requestResult)
}


/*
Fetches given Field
*/
Mysql_fetch_field_direct(requestResult, fieldnum) {
   return DllCall("libmySQL.dll\mysql_fetch_field_direct", "ptr", requestResult, "Uint", fieldnum)
}

/*
Fetches the next field from the result set.
*/
Mysql_fetch_field(requestResult) {
   return DllCall("libmySQL.dll\mysql_fetch_field", "ptr", requestResult)
}

/*
Fetches all fields of the resultSet
*/
MySQL_fetch_fields(requestResult){
   global MySQL_Field
   
   fields := []
   fieldCount := MySQL_num_fields(requestResult)
   
   Loop, % fieldCount
   {
      fptr := Mysql_fetch_field(requestResult)
      fields[A_index] := new MySQL_Field(fptr)
   }
   return fields
}


/*
; mysql error handling
*/
HandleMySQLError(db, message, query="") {
   errorCode := DllCall("libmySQL.dll\mysql_errno", "UInt", db)
   errorStr := DllCall("libmySQL.dll\mysql_error", "UInt", db, "AStr")
   MsgBox 16, MySQL Error: %message%, Error %errorCode%: %errorStr%`n`n%query%
   Return
}





;============================================================
; mysql get address
;============================================================ 
GetUIntAtAddress(_addr, _offset)
{
   local addr
   addr := _addr + _offset * 4
   return *addr + (*(addr + 1) << 8) +  (*(addr + 2) << 16) + (*(addr + 3) << 24)
}

;============================================================
; internal: dump resultset from given Query to string
;============================================================ 
__MySQL_Query_Dump(_db, _query)
{
   local resultString, result, requestResult, fieldCount
   local row, lengths, length, fieldPointer, field

   query4error := RegExReplace(_query , "\t", "   ")    ; convert tabs to spaces so error message formatting is legible
   result := DllCall("libmySQL.dll\mysql_query", "UInt", _db , "AStr", _query)
         
   If (result != 0) {
      errorMsg = %_query%
      HandleMySQLError(_db, "dbQuery Fail", query4error)
      Return
   }
   
   requestResult := MySql_Store_Result(_db)
   
   if (requestResult = 0) {    ; call must have been an insert or delete ... a select would return results to pass back
      return
   }
   
   fieldCount := MySQL_num_fields(requestResult)
   
   
   myfields := MySQL_fetch_fields(requestResult)
   for each, fifi in myfields
   {
      MsgBox % "name: " fifi.Name() "`n org name: " fifi.OrgName() "`ntable: " fifi.Table() "`norg table: " fifi.OrgTable()
   }
   
   Loop
   {
      row := MySQL_fetch_row(requestResult)
      if (!row)
         break

      ; Get a pointer on a table of lengths (unsigned long)
      lengths := MySQL_fetch_lengths(requestResult)
            
      Loop %fieldCount%
      {
         length := GetUIntAtAddress(lengths, A_Index - 1)
         fieldPointer := GetUIntAtAddress(row, A_Index - 1)
         field := StrGet(fieldPointer, length, "CP0")
         resultString := resultString . field
         if (A_Index < fieldCount)
            resultString := resultString . "|"     ; seperator for fields
      }
      resultString := resultString . "`n"          ; seperator for records  
   }
   MySQL_free_result(requestResult)
   resultString := RegExReplace(resultString , "`n$", "")     
   
   return resultString
}



 ;============================================================
 ; Escape mysql special characters
 ; This must be done to sql insert columns where the characters might contain special characters, such as user input fields
 ;
 ; Escape Sequence     Character Represented by Sequence
 ; \'     A single quote (“'”) character.
 ; \"     A double quote (“"”) character.
 ; \n     A newline (linefeed) character.
 ; \r     A carriage return character.
 ; \t     A tab character.
 ; \\     A backslash (“\”) character.
 ; \%     A “%” character. Usually indicates a wildcard character
 ; \_     A “_” character. Usually indicates a wildcard character
 ; \b     A backspace character.
 ;
 ; these 2 have not yet been included yet
 ; \Z     ASCII 26 (Control+Z). Stands for END-OF-FILE on Windows
 ; \0     An ASCII NUL (0x00) character.
 ;
 ; example call:
 ;     description := mysql_escape_string(description)
 ;============================================================

 Mysql_escape_string(unescaped_string)
 {
     escaped_string := RegExReplace(unescaped_string, "\\", "\\")     ; \
     escaped_string := RegExReplace(escaped_string, "'", "\'")        ; '
     
     escaped_string := RegExReplace(escaped_string, "`t", "\t")       ; \t
     escaped_string := RegExReplace(escaped_string, "`n", "\n")       ; \n
     escaped_string := RegExReplace(escaped_string, "`r", "\r")       ; \r
     escaped_string := RegExReplace(escaped_string, "`b", "\b")       ; \b
     
     ; these characters appear to insert fine in mysql    
     ;escaped_string := RegExReplace(escaped_string, "%", "\%")        ; %
     ;escaped_string := RegExReplace(escaped_string, "_", "\_")        ; _
     ;escaped_string := RegExReplace(escaped_string, """", "\""")      ; "
     
     return escaped_string
 }


/*
typedef struct st_mysql_field {
  char *name;                 /* Name of column */
  char *org_name;             /* Original column name, if an alias */
  char *table;                /* Table of column if column was a field */
  char *org_table;            /* Org table name, if table was an alias */
  char *db;                   /* Database for table */
  char *catalog;	      /* Catalog for table */
  char *def;                  /* Default value (set by mysql_list_fields) */
  unsigned long length;       /* Width of column (create length) */
  unsigned long max_length;   /* Max width for selected set */
  unsigned int name_length;
  unsigned int org_name_length;
  unsigned int table_length;
  unsigned int org_table_length;
  unsigned int db_length;
  unsigned int catalog_length;
  unsigned int def_length;
  unsigned int flags;         /* Div flags */
  unsigned int decimals;      /* Number of decimals in field */
  unsigned int charsetnr;     /* Character set */
  enum enum_field_types type; /* Type of field. See mysql_com.h for types */
  void *extension;
} MYSQL_FIELD;
*/

/*
'mysql_port is a long
'mysql_unix port is a long (pointer)
'sizeof(MYSQL_FIELD)=32
Public Type API_MYSQL_FIELD
  name As Long
  table As Long
  def As Long
  type As API_enum_field_types
  length As Long
  max_length As Long
  flags As Long
  decimals As Long
End Type
*/
class MySQL_Field
{
   ptr := 0
   
   __new(ptr){
      this.ptr := ptr
   }
   
   Name(){
      adr := GetUIntAtAddress(this.ptr, 0)
      return StrGet(adr, 255, "CP0")
   }
   
   OrgName(){
      adr := GetUIntAtAddress(this.ptr, 4)
      return StrGet(adr, 255, "CP0")
   }
   
   Table(){
      adr := GetUIntAtAddress(this.ptr, 8)
      return StrGet(adr, 255, "CP0")
   }
   OrgTable(){
      adr := GetUIntAtAddress(this.ptr, 12)
      return StrGet(adr, 255, "CP0")
   }
   
}











