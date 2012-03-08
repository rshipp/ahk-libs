#NoEnv

DB := new Database()
DB.Open("place")

class Database
{
    static DatabaseCount := 0 ;number of open databases
    static ReturnValues := Object(0,"SQLITE_OK"         ;Successful result.
                                 ,1,"SQLITE_ERROR"      ;SQL error or missing database
                                 ,2,"SQLITE_INTERNAL"   ;Internal logic error in SQLite
                                 ,3,"SQLITE_PERM"       ;Access permission denied
                                 ,4,"SQLITE_ABORT"      ;Callback routine requested an abort
                                 ,5,"SQLITE_BUSY"       ;The database file is locked
                                 ,6,"SQLITE_LOCKED"     ;A table in the database is locked
                                 ,7,"SQLITE_NOMEM"      ;A malloc() failed
                                 ,8,"SQLITE_READONLY"   ;Attempt to write a readonly database
                                 ,9,"SQLITE_INTERRUPT"  ;Operation terminated by sqlite3_interrupt()
                                ,10,"SQLITE_IOERR"      ;Some kind of disk I/O error occurred
                                ,11,"SQLITE_CORRUPT"    ;The database disk image is malformed
                                ,12,"SQLITE_NOTFOUND"   ;Unknown opcode in sqlite3_file_control()
                                ,13,"SQLITE_FULL"       ;Insertion failed because database is full
                                ,14,"SQLITE_CANTOPEN"   ;Unable to open the database file
                                ,15,"SQLITE_PROTOCOL"   ;Database lock protocol error
                                ,16,"SQLITE_EMPTY"      ;Database is empty
                                ,17,"SQLITE_SCHEMA"     ;The database schema changed
                                ,18,"SQLITE_TOOBIG"     ;String or BLOB exceeds size limit
                                ,19,"SQLITE_CONSTRAINT" ;Abort due to constraint violation
                                ,20,"SQLITE_MISMATCH"   ;Data type mismatch
                                ,21,"SQLITE_MISUSE"     ;Library used incorrectly
                                ,22,"SQLITE_NOLFS"      ;Uses OS features not supported on host
                                ,23,"SQLITE_AUTH"       ;Authorization denied
                                ,24,"SQLITE_FORMAT"     ;Auxiliary database format error
                                ,25,"SQLITE_RANGE"      ;2nd parameter to sqlite3_bind out of range
                                ,26,"SQLITE_NOTADB"     ;File opened that is not a database file
                               ,100,"SQLITE_ROW"        ;sqlite3_step() has another row ready
                               ,101,"SQLITE_DONE"       ;sqlite3_step() has finished executing
                               
                               ,266,"SQLITE_IOERR_READ"
                               ,522,"SQLITE_IOERR_SHORT_READ"
                               ,778,"SQLITE_IOERR_WRITE"
                              ,1034,"SQLITE_IOERR_FSYNC"
                              ,1290,"SQLITE_IOERR_DIR_FSYNC"
                              ,1546,"SQLITE_IOERR_TRUNCATE"
                              ,1802,"SQLITE_IOERR_FSTAT"
                              ,2058,"SQLITE_IOERR_UNLOCK"
                              ,2314,"SQLITE_IOERR_RDLOCK"
                              ,2570,"SQLITE_IOERR_DELETE"
                              ,2826,"SQLITE_IOERR_BLOCKED"
                              ,3082,"SQLITE_IOERR_NOMEM"
                              ,3338,"SQLITE_IOERR_ACCESS"
                              ,3594,"SQLITE_IOERR_CHECKRESERVEDLOCK"
                              ,3850,"SQLITE_IOERR_LOCK"
                              ,4106,"SQLITE_IOERR_CLOSE"
                              ,4362,"SQLITE_IOERR_DIR_CLOSE"
                              ,4618,"SQLITE_IOERR_SHMOPEN"
                              ,4874,"SQLITE_IOERR_SHMSIZE"
                              ,5130,"SQLITE_IOERR_SHMLOCK"
                              ,5386,"SQLITE_IOERR_SHMMAP"
                              ,5642,"SQLITE_IOERR_SEEK"
                               ,262,"SQLITE_LOCKED_SHAREDCACHE"
                               ,261,"SQLITE_BUSY_RECOVERY"
                               ,270,"SQLITE_CANTOPEN_NOTEMPDIR"
                               ,267,"SQLITE_CORRUPT_VTAB"
                               ,264,"SQLITE_READONLY_RECOVERY"
                               ,520,"SQLITE_READONLY_CANTLOCK")

    ;create a database object
    __New(LibraryPath = "")
    {
        If Database.DatabaseCount = 0 ;no databases exist yet
        {
            If (LibraryPath = "") ;library path not given
                LibraryPath := A_ScriptDir . "\SQLite3.dll"
            this.hModule := DllCall("LoadLibrary","Str",LibraryPath) ;load the database library
            If !this.hModule
                throw Exception("Could not load database library from """ . LibraryPath . """.")
        }
        Database.DatabaseCount ++ ;increment the database count

        this.hDatabase := 0
    }

    __Delete()
    {
        Database.DatabaseCount --
        If Database.DatabaseCount = 0 ;all databases have been closed
            DllCall("FreeLibrary","UPtr",this.hModule), this.hModule := 0 ;free the database library
    }

    ;open a database or create one if it does not exist
    Open(DatabaseFile = ":memory:") ;filename of the database (omit to create database in memory, or blank to create a database in a temporary file)
    {
        Value := DllCall("sqlite3\sqlite3_open" . (A_IsUnicode ? "16" : ""),"Str",DatabaseFile,"UPtr*",hDatabase,"CDecl Int") ;open the database file
        If this.ReturnValues[Value] != "SQLITE_OK" ;error opening database
            throw Exception("SQLite error " . Value . "(" . this.ReturnValues[Value] . ").")
        this.hDatabase := hDatabase
        Return, this
    }

    class Query
    {
        __New(SQL)
        {
            DllCall("sqlite3\sqlite3_prepare" . (A_IsUnicode ? "16" : "") . "_v2","UPtr",hDatabase,"Str",SQL,"Int",StrLen(SQL) << !!A_IsUnicode,"UPtr*",hQuery,"UPtr",0,"CDecl Int")
        }
    }
}