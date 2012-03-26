class ITL_StructureWrapper extends ITL_Wrapper.ITL_WrapperBaseClass
{
	__New(typeInfo, lib)
	{
		static GUID_NULL := "{00000000-0000-0000-0000-000000000000}", IID_ICreateTypeInfo := "{00020405-0000-0000-C000-000000000046}"
		local Base, hr := 0x00, rcinfo := 0, guid:= 0

		if (this != ITL_Wrapper.ITL_StructureWrapper)
		{
			Base.__New(typeInfo, lib)

			; If there's no GUID specified, this would cause GetRecordInfoFromTypeInfo() to fail
			; So we're trying to add a random-generated GUID just to keep it satisfied.
			if (lib.GetGUID(typeInfo, false, true) == GUID_NULL)
			{
				createInfo := ComObjQuery(typeInfo, IID_ICreateTypeInfo) ; query for the ICreateTypeInfo interface which can be used to modify the type
				if (!createInfo)
				{
					throw Exception("QueryInterface() for ICreateTypeInfo failed.", -1, "This is needed because the type """ this["internal://typeinfo-name"] """ does not have a GUID.")
				}

				hr := ITL_GUID_Create(guid) ; dynamically create a new GUID
				if (ITL_FAILED(hr))
				{
					throw Exception("Creating a GUID failed.", -1, ITL_FormatError(hr))
				}

				hr := DllCall(NumGet(NumGet(createInfo+0), 03*A_PtrSize, "Ptr"), "Ptr", createInfo, "Ptr", &guid, "Int") ; ICreateTypeInfo::SetGuid() - assign a GUID for the type
				if (ITL_FAILED(hr))
				{
					throw Exception("ICreateTypeInfo::SetGUID() failed.", -1, ITL_FormatError(hr))
				}
			}

			hr := DllCall("OleAut32\GetRecordInfoFromTypeInfo", "Ptr", typeInfo, "Ptr*", rcinfo, "Int") ; retrieve an IRecordInfo instance for a type
			if (ITL_FAILED(hr) || !rcinfo)
			{
				throw Exception("GetRecordInfoFromTypeInfo() failed for type """ this["internal://typeinfo-name"] """.", -1, ITL_FormatError(hr))
			}
			this["internal://rcinfo-instance"] := rcinfo

			ObjInsert(this, "__New", Func("ITL_StructureConstructor"))
		}
	}

	__Delete()
	{
		local hr, ptr, rcinfo
		if (ptr := this["internal://type-instance"])
		{
			rcinfo := this.base["internal://rcinfo-instance"]
			hr := DllCall(NumGet(NumGet(rcinfo+0), 18*A_PtrSize, "Ptr"), "Ptr", rcinfo, "Ptr", ptr, "Int") ; IRecordInfo::RecordDestroy()
			if (ITL_FAILED(hr))
			{
				throw Exception("RecordDestroy() failed.", -1, ITL_FormatError(hr))
			}
		}
		else
		{
			rcinfo := this["internal://rcinfo-instance"]
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
		static INVOKE_PROPERTYPUT := 4
		local hr, ptr, variant := 0, rcinfo

		if (field != "base" && !RegExMatch(field, "^internal://")) ; ignore base and internal properties (handled by ITL_WrapperBaseClass)
		{
			ptr := this["internal://type-instance"]
			, rcinfo := this.base["internal://rcinfo-instance"]

			ITL_VARIANT_Create(value, variant)
			hr := DllCall(NumGet(NumGet(rcinfo+0), 12*A_PtrSize, "Ptr"), "Ptr", rcinfo, "UInt", INVOKE_PROPERTYPUT, "Ptr", ptr, "Str", field, "Ptr", &variant, "Int") ; IRecordInfo::PutField()
			if (ITL_FAILED(hr))
			{
				throw Exception("PutField() failed.", -1, ITL_FormatError(hr))
			}

			return value
		}
	}

	_NewEnum()
	{
		local hr, info, rcinfo, attr := 0, obj, names_array, varCount := -1, name := ""

		obj := this["internal://enumerator-object"]
		if(!IsObject(obj))
		{
			obj := this["internal://enumerator-object"] := {} ; create a storage object
			rcinfo := this.base["internal://rcinfo-instance"]

			; call GetFieldNames() with a NULL array pointer -> retrieve the total field count through "varCount"
			hr := DllCall(NumGet(NumGet(rcinfo+0), 14 * A_PtrSize, "Ptr"), "Ptr", rcinfo, "UInt*", varCount, "Ptr", 0, "Int") ; IRecordInfo::GetFieldNames()
			if (ITL_FAILED(hr) || varCount == -1)
			{
				throw Exception("IRecordInfo::GetFieldNames() failed.", -1, ITL_FormatError(hr))
			}

			VarSetCapacity(names_array, varCount * A_PtrSize, 00) ; allocate name array memory
			; call it again, this time supplying a valid array pointer
			hr := DllCall(NumGet(NumGet(rcinfo+0), 14 * A_PtrSize, "Ptr"), "Ptr", rcinfo, "UInt*", varCount, "Ptr", &names_array, "Int") ; IRecordInfo::GetFieldNames()
			if (ITL_FAILED(hr))
			{
				throw Exception("IRecordInfo::GetFieldNames() failed.", -1, ITL_FormatError(hr))
			}

			Loop %varCount%
			{
				name := StrGet(NumGet(names_array, (A_Index - 1) * A_PtrSize, "Ptr"))
				obj.Insert(name, this[name])
			}
		}

		return ObjNewEnum(obj)
	}

	NewEnum()
	{
		return this._NewEnum()
	}

	_Clone()
	{
		local hr, rcinfo := this.base["internal://rcinfo-instance"], ptrNew := 0, ptrOld := this["internal://type-instance"], newObj

		newObj := new this.base()
		ptrNew := newObj["internal://type-instance"]

		hr := DllCall(NumGet(NumGet(rcinfo+0), 05*A_PtrSize, "Ptr"), "Ptr", rcinfo, "Ptr", ptrOld, "Ptr", ptrNew, "Int") ; IRecordInfo::RecordCopy()
		if (ITL_FAILED(hr) || !ptrNew)
		{
			throw Exception("IRecordInfo::RecordCopy() failed.", -1, ITL_FormatError(hr))
		}

		return newObj
	}

	Clone()
	{
		return this._Clone()
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