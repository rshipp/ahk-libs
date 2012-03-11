#Include <Base>
#Include <DataBase>
#Include <DataBaseSQLLite>
#Include <DataBaseMySQL>

class DataBaseFactory
{
	/*
		This static Method returns an Instance of an DataBase derived Object
	*/
	OpenDataBase(dbType, connectionString){
		if(dbType = "SQLite")
		{
			OutputDebug, Open Database of known type [%dbType%]
			SQLite_Startup()
			;//parse connection string. for now assume its a path to the requested DB
			handle := SQLite_OpenDB(connectionString)
			return new DataBaseSQLLite(handle)
			
		} if(dbType = "MySQL") {
			OutputDebug, Open Database of known type [%dbType%]
			MySQL_StartUp()
			conData := MySQL_CreateConnectionData(connectionString)
			return new DataBaseMySQL(conData)
		} else {
			throw Exception("The given Database Type is unknown! [" . dbType "]",-1)
		}
	}
	
	__New(){
		throw Exception("This is a static class, dont instante it!",-1)
	}
}