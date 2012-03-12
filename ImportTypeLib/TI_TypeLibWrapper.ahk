class TI_TypeLibWrapper
{
	__New(lib)
	{
		static valid_typekinds := 0
		local typeKind := -1, hr, typename, obj, typeInfo := 0

		if (!IsObject(valid_typekinds)) ; init static field
			 valid_typekinds := { 0 : TI_Wrapper.TI_EnumWrapper, 1 : TI_Wrapper.TI_StructureWrapper, 5 : TI_Wrapper.TI_CoClassWrapper, 3 : TI_Wrapper.TI_InterfaceWrapper }

		if (this != TI_Wrapper.TI_TypeLibWrapper)
		{
			ObjInsert(this, "__New", Func("TI_AbstractClassConstructor"))
			this["internal://typelib-instance"] := lib
			this["internal://typelib-name"] := this.GetName()

			Loop % DllCall(NumGet(NumGet(lib+0), 03*A_PtrSize, "Ptr"), "Ptr", lib, "Int") ; ITypeLib::GetTypeInfoCount()
			{
				hr := DllCall(NumGet(NumGet(lib+0), 05*A_PtrSize, "Ptr"), "Ptr", lib, "UInt", A_Index - 1, "UInt*", typeKind, "Int") ; ITypeLib::GetTypeKind()
				if (FAILED(hr))
				{
					throw Exception("Type information kind no. " A_Index - 1 " could not be read.", -1, TI_FormatError(hr))
				}
				if (!valid_typekinds.HasKey(typeKind))
				{
					continue
				}

				hr := DllCall(NumGet(NumGet(lib+0), 04*A_PtrSize, "Ptr"), "Ptr", lib, "UInt", A_Index - 1, "Ptr*", typeInfo, "Int") ; ITypeLib::GetTypeInfo()
				if (FAILED(hr))
				{
					throw Exception("Type information no. " A_Index - 1 " could not be read.", -1, TI_FormatError(hr))
				}

				typename := this.GetName(A_Index - 1), obj := valid_typekinds[typeKind]
				this[typename] := new obj(typeInfo, this)
			}
		}
	}

	GetName(index = -1)
	{
		local hr, name := 0, lib

		lib := this["internal://typelib-instance"]
		hr := DllCall(NumGet(NumGet(lib+0), 09*A_PtrSize, "Ptr"), "Ptr", lib, "UInt", index, "Ptr*", name, "Ptr*", 0, "UInt*", 0, "Ptr*", 0, "Int") ; ITypeLib::GetDocumentation()
		if (FAILED(hr))
		{
			throw Exception("Name for the " (index == -1 ? "type library" : "type description no. " index) " could not be read.", -1, TI_FormatError(hr))
		}

		return StrGet(name, "UTF-16")
	}

	GetGUID(obj = -1, returnRaw = false, passRaw = false)
	{
		local hr, guid, lib, info, attr := 0, result

		lib := this["internal://typelib-instance"]
		if obj is not integer
		{
			if (!IsObject(obj)) ; it's a string, a field name
				obj := this[obj]

			if (IsObject(obj)) ; a field, either passed directly or via name
				info := obj["internal://typeinfo-instance"]
			else
				throw Exception("Field could not be retrieved.", -1)
		}
		else if (obj != -1)
		{
			if (passRaw)
				info := obj ; also allow passing an ITypeInfo pointer directly
			else
			{
				hr := DllCall(NumGet(NumGet(lib+0), 04*A_PtrSize, "Ptr"), "Ptr", lib, "UInt", obj, "Ptr*", info, "Int") ; ITypeLib::GetTypeInfo()
				if (FAILED(hr) || !info)
				{
					throw Exception("Type information could not be read.", -1, TI_FormatError(hr))
				}
			}
		}

		if (obj == -1)
		{
			hr := DllCall(NumGet(NumGet(lib+0), 07*A_PtrSize, "Ptr"), "Ptr", lib, "Ptr*", attr, "Int") ; ITypeLib::GetLibAttr()
			if (FAILED(hr) || !attr)
			{
				throw Exception("TLIBATTR could not be read.", -1, TI_FormatError(hr))
			}

			guid := Mem_Allocate(16), Mem_Copy(attr, guid, 16) ; TLIBATTR::guid
			if (returnRaw)
				result := guid
			else
				result := GUID_ToString(guid), Mem_Release(guid)

			DllCall(NumGet(NumGet(lib+0), 12*A_PtrSize, "Ptr"), "Ptr", lib, "Ptr", attr) ; ITypeLib::ReleaseTLibAttr()
		}
		else
		{
			hr := DllCall(NumGet(NumGet(info+0), 03*A_PtrSize, "Ptr"), "Ptr", info, "Ptr*", attr, "Int") ; ITypeInfo::GetTypeAttr()
			if (FAILED(hr) || !attr)
			{
				throw Exception("TYPEATTR could not be read.", -1, TI_FormatError(hr))
			}

			guid := Mem_Allocate(16), Mem_Copy(attr, guid, 16) ; TYPEATTR::guid
			if (returnRaw)
				result := guid
			else
				result := GUID_ToString(guid), Mem_Release(guid)

			DllCall(NumGet(NumGet(info+0), 19*A_PtrSize, "Ptr"), "Ptr", info, "Ptr", attr, "Int") ; ITypeInfo::ReleaseTypeAttr()
		}

		return result
	}
}