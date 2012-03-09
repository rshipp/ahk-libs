; <AutoHotkey L> is required to run this script.
/*
File: Main.ahk
Script: ComGenerator

Purpose:
	automatic creation of classes compatible with the CCF (https://github.com/maul-esel/COM-Classes).

Authors:
	* maul.esel

Requirements:
	AutoHotkey - AutoHotkey_L v1.1+
	Libraries - CCF (https://github.com/maul-esel/COM-Classes)

License:
	http://unlicense.org
*/
/*
script header
*/
#SingleInstance off
#NoTrayIcon
#NoEnv
#KeyHistory 0
ListLines Off
SetBatchLines -1

/*
check app mode
*/
if !IsUIMode() ; process was launched from a cmd app
{
	Cmd_Run(Cmd_Arguments())
	ExitApp ERROR.SUCCESS
}
else ; UI mode
{
	Gosub BuildGui
}
return

/*
Function: Status
Reports the current status to the user
*/
Status(text = "Done.")
{
	return IsUIMode() ? Gui_Status(text) : Cmd_Status(text)
}

/*
Function: Error
Reports an error to the user.

Parameters:
	[opt] UINT code - the error to report. Take the value from the ERROR class.
	[opt] BOOL exit - if the app is in CMD mode, defines whether the app should be shut down.
	[opt] STR msg - an additional message to display.
*/
Error(code = -1, exit = false, msg = "")
{
	return IsUIMode() ? Gui_Error(code, msg) : Cmd_Error(code, exit, msg)
}

/*
Function: IsUIMode
retrieves whether the app is in UI mode or not.
*/
IsUIMode()
{
	static value := !DllCall("AttachConsole", "UInt", -1)
	return value
}

GetName4IID(iid)
{
	Status("Reading interface name for interface """ . iid . """...")
	name := Registry_GetName4IID(iid)
	if (!name)
	{
		return "", Error(ERROR.READ_NAME, false, "IID: " . iid), Status()
	}
	return name, Status(), Error()
}

GetTypeLibID4IID(iid)
{
	Status("Reading type library guid for interface """ . iid . """...")
	guid := Registry_GetTypeLibID4IID(iid)
	if (!guid)
	{
		return 0, Error(ERROR.READ_TYPELIB, true, "IID: " . iid), Status()
	}
	return guid, Status(), Error()
}

GetTypeLibVersion4IID(iid)
{
	Status("Reading type library version for """ . iid . """...")
	version := Registry_GetTypeLibVersion4IID(iid)
	if (!version)
	{
		return "", Error(ERROR.READ_TYPELIB_VERSION, true, "IID: " . iid), Status()
	}
	return version, Status(), Error()
}

SearchIID4Name(name)
{
	Status("Searching IID for interface """ . name . """...")
	iid := Registry_SearchIID4Name(name)
	if (!iid)
	{
		return 0, Error(ERROR.FIND_INTERFACE, true, "Interface: " . name), Status()
	}
	return iid, Status(), Error()
}

LoadTypeLibrary(guid, vMajor, vMinor)
{
	Status("Loading type library """ . guid . """...")
	try
	{
		lib := TypeLib.FromRegistry(guid, vMajor, vMinor)
	}
	catch exception
	{
		return false, Error(ERROR.LOAD_LIBRARY, true, "Type library: " . guid), Status()
	}
	return lib, Status(), Error()
}

LoadTypeInfo(lib, iid)
{
	Status("Loading type info for """ . iid . """...")
	try
	{
		type := lib.GetTypeInfoOfGuid(iid)
	}
	catch exception
	{
		return false, Error(ERROR.LOAD_TYPE, true, "IID: " . iid), Status()
	}
	return type, Status(), Error()
}

/*
#Includes (not executed at loadtime)
*/
#include %A_ScriptDir%\CCF
#include Type Information Header.ahk

#include %A_ScriptDir%
#include Gui.ahk
#include Cmd.ahk
#include <CCFGenerator>
#include <Error>
#Include <ErrorHandler>
#include <AHKVersion>
#include <PseudoProperty>