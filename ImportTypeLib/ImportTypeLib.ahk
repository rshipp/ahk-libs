ImportTypeLib(lib, version = "1.0")
{
	local verMajor, verMinor, libid, hr

	if (GUID_IsGUIDString(lib))
	{
		if (!TI_GetVersion(version, verMajor, verMinor))
		{
			throw Exception("Invalid version specified: """ version """.", -1)
		}

		hr := GUID_FromString(lib, libid)
		if (FAILED(hr))
		{
			throw Exception("LIBID could not be converted: """ lib """.", -1, TI_FormatError(hr))
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
		throw Exception("Loading of type library failed.", -1, TI_FormatError(hr))
	}
	return new TI_Wrapper.TI_TypeLibWrapper(lib)
}

#include TI_CoClassConstructor.ahk
#include TI_AbstractClassConstructor.ahk
#include TI_StructureConstructor.ahk
#include TI_InterfaceConstructor.ahk

#include TI_Wrapper.ahk