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

	if (GUID_IsGUIDString(lib))
	{
		if (!RegExMatch(lib, "^(?P<Major>\d+)\.(?P<Minor>\d+)$", ver))
		{
			throw Exception("Invalid version specified: """ version """.", -1)
		}

		hr := GUID_FromString(lib, libid)
		if (FAILED(hr))
		{
			throw Exception("LIBID could not be converted: """ lib """.", -1, FormatError(hr))
		}

		hr := DllCall("OleAut32\LoadRegTypeLib", "Ptr", &libid, "UShort", verMajor, "UShort", verMinor, "Ptr*", lib, "Int") ; error handling is done below

		VarSetCapacity(libid, 0)
	}
	else
	{
		hr := DllCall("OleAut32\LoadTypeLib", "Str", lib, "Ptr*", lib, "Int") ; error handling is done below
	}

	if (FAILED(hr))
	{
		throw Exception("Loading of type library failed.", -1, FormatError(hr))
	}
	return new TI_Wrapper.TI_TypeLibWrapper(lib)
}

#include TI_CoClassConstructor.ahk
#include TI_AbstractClassConstructor.ahk
#include TI_StructureConstructor.ahk
#include TI_InterfaceConstructor.ahk

#include TI_Wrapper.ahk