/*
File: Registry.ahk
Script: ComGenerator

Purpose:
	holds functions to retrieve information about a registered type.

Authors:
	* maul.esel

Requirements:
	AutoHotkey - AutoHotkey_L v1.1+
	Libraries - CCF (https://github.com/maul-esel/COM-Classes)

License:
	http://unlicense.org
*/
/*
Function: Registry_GetName4IID
gets the interface name for the specified IID.

Parameters:
	STR iid - the IID of the interface

Returns:
	STR name - the interface name, if found
*/
Registry_GetName4IID(iid)
{
	RegRead, name, HKCR, Interface\%iid%
	return name
}

/*
Function: Registry_GetTypeLibID4IID
gets the type library GUID for the specified interface.

Parameters:
	STR iid - the IID of the interface

Returns:
	STR guid - the GUID of the type library, if found.
*/
Registry_GetTypeLibID4IID(iid)
{
	RegRead, lib, HKCR, Interface\%iid%\TypeLib
	return lib
}

/*
Function: Registry_GetTypeLibVersion4IID
gets the type library version for the specified interface

Parameters:
	STR iid - the IID of the interface

Returns:
	STR version - the version number, if found
*/
Registry_GetTypeLibVersion4IID(iid)
{
	RegRead version, HKCR, Interface\%iid%\TypeLib, Version
	return version
}

/*
Function: Registry_GetMethodCount4IID
gets the number of methods in the specified interface

Parameters:
	STR iid - the IID of the interface

Returns:
	UINT count - the method count, including inherited members. If this is 0, the number was not found.
*/
Registry_GetMethodCount4IID(iid)
{
	RegRead count, HKCR, Interface\%iid%\NumMethod
	return count
}

/*
Function: Registry_SearchIID4Name
searches the registry for the IID of the given interface name

Parameters:
	STR name - the name of the interface

Returns:
	STR iid - the IID of the interface, if found. 0 if not found.
*/
Registry_SearchIID4Name(name)
{
	Loop HKCR, Interface, 2
	{
		RegRead current_name, HKCR, Interface\%A_LoopRegName%
		if (current_name == name)
			return A_LoopRegName
	}
	return 0
}