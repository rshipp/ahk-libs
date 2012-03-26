/*
Function: ImportTypeLib
loads a type library and returns a wrapper object

Parameters:
	lib - either the path to the library or the GUID if it is registered within the system.
		If the path passed points to a file (e.g. a DLL) containing the type library, but it is not the first resource, append the index like so:
		> ImportTypeLib("C:\Path\to\Lib.dll\2")
	[opt] version - if a GUID is passed, specify the type library version here. Defaults to "1.0" (use exactly that format!).
*/
ImportTypeLib(lib, version = "1.0")
{
	local ver, verMajor, verMinor, libid, hr

	if (ITL_GUID_IsGUIDString(lib))
	{
		if (!RegExMatch(version, "^(?P<Major>\d+)\.(?P<Minor>\d+)$", ver))
		{
			throw Exception("Invalid version specified: """ version """.", -1)
		}

		hr := ITL_GUID_FromString(lib, libid)
		if (ITL_FAILED(hr))
		{
			throw Exception("LIBID could not be converted: """ lib """.", -1, ITL_FormatError(hr))
		}

		hr := DllCall("OleAut32\LoadRegTypeLib", "Ptr", &libid, "UShort", verMajor, "UShort", verMinor, "UInt", 0, "Ptr*", lib, "Int") ; error handling is done below

		VarSetCapacity(libid, 0)
	}
	else
	{
		hr := DllCall("OleAut32\LoadTypeLib", "Str", lib, "Ptr*", lib, "Int") ; error handling is done below
	}

	if (ITL_FAILED(hr) || !lib)
	{
		throw Exception("Loading of type library failed.", -1, ITL_FormatError(hr))
	}
	return new ITL_Wrapper.ITL_TypeLibWrapper(lib)
}

#include Lib\ITL_FAILED.ahk
#include Lib\ITL_FormatError.ahk
#include Lib\ITL_GUID.ahk
#include Lib\ITL_HasEnumFlag.ahk
#include Lib\ITL_Mem.ahk
#Include Lib\ITL_SUCCEEDED.ahk
#include Lib\ITL_VARIANT.ahk

#include ITL_CoClassConstructor.ahk
#include ITL_AbstractClassConstructor.ahk
#include ITL_StructureConstructor.ahk
#include ITL_InterfaceConstructor.ahk

#include ITL_Wrapper.ahk