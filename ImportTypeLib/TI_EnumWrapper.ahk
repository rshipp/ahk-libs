class TI_EnumWrapper extends TI_Wrapper.TI_WrapperBaseClass
{
	__New(typeInfo, lib)
	{
		local Base

		if (this != TI_Wrapper.TI_EnumWrapper)
		{
			Base.__New(typeInfo, lib)
			ObjInsert(this, "__New", Func("TI_AbstractClassConstructor"))
		}
	}

	__Get(field)
	{
		static VARKIND_CONST := 2, DISPID_UNKNOWN := -1
		local hr, info, typeName, varID := DISPID_UNKNOWN, index := -1, varDesc := 0, varValue := ""

		if (field != "base" && !RegExMatch(field, "^internal://")) ; ignore base and internal properties (handled by TI_WrapperBaseClass)
		{
			info := this["internal://typeinfo-instance"]
			typeName := this["internal://typeinfo-name"]

			hr := DllCall(NumGet(NumGet(info+0), 10*A_PtrSize, "Ptr"), "Ptr", info, "Str*", field, "UInt", 1, "UInt*", varID, "Int") ; ITypeInfo::GetIDsOfNames()
			if (FAILED(hr) || varID == DISPID_UNKNOWN)
			{
				; allow omitting a typename prefix:
				; if the enum is called "MyEnum" and the field is called "MyEnum_Any",
				; then allow both "MyEnum.MyEnum_Any" and "MyEnum.Any"
				if (!InStr(field, typeName . "_", true) == 1) ; omit this if the field is already prefixed with the type name
				{
					hr := DllCall(NumGet(NumGet(info+0), 10*A_PtrSize, "Ptr"), "Ptr", info, "Str*", typeName "_" . field, "UInt", 1, "UInt*", varID, "Int") ; ITypeInfo::GetIDsOfNames()
				}
				if (FAILED(hr) || varID == DISPID_UNKNOWN) ; recheck as the above "if" might have changed it
				{
					throw Exception("GetIDsOfNames for """ field """ failed.", -1, TI_FormatError(hr))
				}
			}

			hr := DllCall(NumGet(NumGet(info+0), 25*A_PtrSize, "Ptr"), "Ptr", info, "UInt", varID, "UInt*", index, "Int") ; ITypeInfo2::GetVarIndexOfMemId()
			if (FAILED(hr) || index < 0)
			{
				throw Exception("GetVarIndexOfMemId for """ field """ failed.", -1, TI_FormatError(hr))
			}

			hr := DllCall(NumGet(NumGet(info+0), 06*A_PtrSize, "Ptr"), "Ptr", info, "UInt", index, "Ptr*", varDesc, "Int") ; ITypeInfo::GetVarDesc()
			if (FAILED(hr) || !varDesc)
			{
				throw Exception("VARDESC for """ field """ could not be read.", -1, TI_FormatError(hr))
			}

			if (NumGet(1*varDesc, 08 + 6 * A_PtrSize, "UShort") != VARKIND_CONST) ; VARDESC::varkind
			{
				throw Exception("Cannot read non-constant enumeration member """ field """!", -1)
			}

			varValue := VARIANT_GetValue(NumGet(1 * varDesc, 04 + A_PtrSize, "Ptr")) ; VARDESC::lpvarValue
			DllCall(NumGet(NumGet(info+0), 21*A_PtrSize, "Ptr"), "Ptr", info, "Ptr", varDesc) ; ITypeInfo::ReleaseVarDesc()

			return varValue
		}
	}

	__Set(field, params*)
	{
		if (field != "base" && !RegExMatch(field, "^internal://")) ; ignore base and internal properties (handled by TI_WrapperBaseClass)
		{
			throw Exception("A field must not be set on an enumeration class!", -1)
		}
	}

	_NewEnum()
	{
		local hr, typeName, info, obj, attr := 0, varCount, varDesc := 0, varID, pVarName := 0, varValue

		obj := this["internal://enumerator-object"]
		if (!IsObject(obj))
		{
			obj := this["internal://enumerator-object"] := {}
			typeName := this["internal://typeinfo-name"]
			info := this["internal://typeinfo-instance"]

			hr := DllCall(NumGet(NumGet(info+0), 03*A_PtrSize, "Ptr"), "Ptr", info, "Ptr*", attr, "Int") ; ITypeInfo::GetTypeAttr()
			if (FAILED(hr) || !attr)
			{
				throw Exception("TYPEATTR could not be read.", -1, TI_FormatError(hr))
			}
			varCount := NumGet(1*attr, 42+1*A_PtrSize, "UShort") ; TYPEATTR::cVars
			DllCall(NumGet(NumGet(info+0), 19*A_PtrSize, "Ptr"), "Ptr", info, "Ptr", attr) ; ITypeInfo::ReleaseTypeAttr()

			Loop % varCount
			{
				hr := DllCall(NumGet(NumGet(info+0), 06*A_PtrSize, "Ptr"), "Ptr", info, "UInt", A_Index - 1, "Ptr*", varDesc, "Int") ; ITypeInfo::GetVarDesc()
				if (FAILED(hr) || !varDesc)
				{
					throw Exception("VARDESC no. " A_Index - 1 " could not be read.", -1, TI_FormatError(hr))
				}

				varID := NumGet(1*varDesc, 00, "Int") ; VARDESC::memid
				hr := DllCall(NumGet(NumGet(info+0), 12*A_PtrSize, "Ptr"), "Ptr", info, "Int", varID, "Ptr*", pVarName, "Ptr", 0, "UInt", 0, "Ptr", 0, "Int") ; ITypeInfo::GetDocumentation()
				if (FAILED(hr) || !pVarName)
				{
					throw Exception("GetDocumentation() failed.", -1, TI_FormatError(hr))
				}
				varValue := VARIANT_GetValue(NumGet(1 * varDesc, 04 + A_PtrSize, "Ptr")) ; VARDESC::lpvarValue

				obj[StrGet(pVarName, "UTF-16")] := varValue

				DllCall(NumGet(NumGet(info+0), 21*A_PtrSize, "Ptr"), "Ptr", info, "Ptr", varDesc) ; ITypeInfo::ReleaseVarDesc()
				pVarName := 0, varDesc := 0
			}
		}

		return ObjNewEnum(obj)
	}

	NewEnum()
	{
		return this._NewEnum()
	}
}