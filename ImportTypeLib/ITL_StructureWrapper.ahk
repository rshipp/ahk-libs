class ITL_StructureWrapper extends ITL_Wrapper.ITL_WrapperBaseClass
{
	__New(typeInfo, lib)
	{
		local Base, hr, rcinfo := 0

		if (this != ITL_Wrapper.ITL_StructureWrapper)
		{
			Base.__New(typeInfo, lib)

			hr := DllCall("OleAut32\GetRecordInfoFromTypeInfo", "Ptr", typeInfo, "Ptr*", rcinfo, "Int")
			if (ITL_FAILED(hr) || !rcinfo)
			{
				throw Exception("GetRecordInfoFromTypeInfo() failed.", -1, ITL_FormatError(hr))
			}
			this["internal://rcinfo-instance"] := rcinfo

			ObjInsert(this, "__New", Func("ITL_StructureConstructor"))
		}
	}

	__Delete()
	{
		local hr, ptr, rcinfo := this["internal://rcinfo-instance"]
		if (ptr := this["internal://type-instance"])
		{
			hr := DllCall(NumGet(NumGet(rcinfo+0), 18*A_PtrSize, "Ptr"), "Ptr", rcinfo, "Ptr", ptr, "Int") ; IRecordInfo::RecordDestroy()
			if (ITL_FAILED(hr))
			{
				throw Exception("RecordDestroy() failed.", -1, ITL_FormatError(hr))
			}
		}
		else
		{
			ObjRelease(rcinfo)
		}
	}

	__Get(field)
	{
		static sizeof_VARIANT := 8 + 2 * A_PtrSize
		local hr, ptr, variant := 0, rcinfo

		if (field != "base" && !RegExMatch(field, "^internal://")) ; ignore base and internal properties (handled by ITL_WrapperBaseClass)
		{
			ptr := this["internal://type-instance"]
			rcinfo := this.base["internal://rcinfo-instance"]

			if (VarSetCapacity(variant, sizeof_VARIANT, 00) != sizeof_VARIANT)
				throw Exception("Out of memory.", -1)

			hr := DllCall(NumGet(NumGet(rcinfo+0), 10*A_PtrSize, "Ptr"), "Ptr", rcinfo, "Ptr", ptr, "Str", field, "Ptr", &variant, "Int") ; IRecordInfo::GetField()
			if (ITL_FAILED(hr))
			{
				throw Exception("GetField() failed.", -1, ITL_FormatError(hr))
			}

			return ITL_VARIANT_GetValue(&variant)
		}
	}

	__Set(field, value)
	{
		static INVOKE_PROPERTYPUTREF := 8
		local hr, ptr, variant := 0, rcinfo

		if (field != "base" && !RegExMatch(field, "^internal://")) ; ignore base and internal properties (handled by ITL_WrapperBaseClass)
		{
			ptr := this["internal://type-instance"]
			, rcinfo := this.base["internal://rcinfo-instance"]

			ITL_VARIANT_Create(value, variant)
			hr := DllCall(NumGet(NumGet(rcinfo+0), 12*A_PtrSize, "Ptr"), "Ptr", rcinfo, "UInt", INVOKE_PROPERTYPUTREF, "Ptr", ptr, "Str", field, "Ptr", &variant, "Int") ; IRecordInfo::PutField()
			if (ITL_FAILED(hr))
			{
				throw Exception("PutField() failed.", -1, ITL_FormatError(hr))
			}

			return value
		}
	}

	GetSize()
	{
		local hr, size := -1, rcinfo := this["internal://rcinfo-instance"]

		hr := DllCall(Numget(NumGet(rcinfo+0), 08*A_PtrSize, "Ptr"), "Ptr", rcinfo, "UInt*", size, "Int") ; IRecordInfo::GetSize()
		if (ITL_FAILED(hr) || size == -1)
		{
			throw Exception("GetSize() failed.", -1, ITL_FormatError(hr))
		}

		return size
	}
}