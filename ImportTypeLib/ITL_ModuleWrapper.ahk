class ITL_ModuleWrapper extends ITL_Wrapper.ITL_ConstantMemberWrapperBaseClass
{
	__New(typeInfo, lib)
	{
		local Base

		if (this != ITL_Wrapper.ITL_ModuleWrapper)
		{
			Base.__New(typeInfo, lib)
			ObjInsert(this, "__New", Func("ITL_AbstractClassConstructor"))
		}
	}

	__Call(method, params*)
	{
		static DISPID_UNKNOWN := -1
		local id := DISPID_UNKNOWN, hr := 0, addr := 0, info

		info := this["internal://typeinfo-instance"]

		hr := DllCall(NumGet(NumGet(info+0), 10*A_PtrSize, "Ptr"), "Ptr", info, "Str*", method, "UInt", 1, "Ptr*", id, "Int")
		if (ITL_FAILED(hr) || id == DISPID_UNKNOWN)
		{
			throw Exception("GetIDsOfNames() for """ method "()"" failed.", -1, ITL_FormatError(hr))
		}

		hr := DllCall(NumGet(NumGet(info+0), 15*A_PtrSize, "Ptr"), "Ptr", info, "UInt", id, "UInt", 0, "Ptr*", addr, "Int")
		if (ITL_FAILED(hr) || !addr)
		{
			throw Exception("AddressOfMember() for """ method "()"" failed.", -1, ITL_FormatError(hr))
		}

		; call!
		; result := DllCall(addr, params*)
		; get return type

		return ; result
	}
}