; class: ITL_ConstantMemberWrapperBaseClass
; This is the base class for types that have constant variable members, i.e. enums and modules.
class ITL_ConstantMemberWrapperBaseClass extends ITL_Wrapper.ITL_WrapperBaseClass
{
	; method: __Get
	; gets the value of an enumeration field or module constant.
	__Get(field)
	{
		static VARKIND_CONST := 2, DISPID_UNKNOWN := -1
		local hr, info, typeName, varID := DISPID_UNKNOWN, index := -1, varDesc := 0, varValue := ""

		if (field != "base" && !RegExMatch(field, "^internal://")) ; ignore base and internal properties (handled by ITL_WrapperBaseClass)
		{
			info := this["internal://typeinfo-instance"]
			typeName := this["internal://typeinfo-name"]

			; get the member id for the given field name
			hr := DllCall(NumGet(NumGet(info+0), 10*A_PtrSize, "Ptr"), "Ptr", info, "Str*", field, "UInt", 1, "UInt*", varID, "Int") ; ITypeInfo::GetIDsOfNames()
			if (ITL_FAILED(hr) || varID == DISPID_UNKNOWN)
			{
				; allow omitting a typename prefix:
				; if the enum is called "MyEnum" and the field is called "MyEnum_Any",
				; then allow both "MyEnum.MyEnum_Any" and "MyEnum.Any"
				if (!InStr(field, typeName . "_", true) == 1) ; omit this if the field is already prefixed with the type name
				{
					hr := DllCall(NumGet(NumGet(info+0), 10*A_PtrSize, "Ptr"), "Ptr", info, "Str*", typeName "_" . field, "UInt", 1, "UInt*", varID, "Int") ; ITypeInfo::GetIDsOfNames()
				}
				if (ITL_FAILED(hr) || varID == DISPID_UNKNOWN) ; recheck as the above "if" might have changed it
				{
					throw Exception("GetIDsOfNames() for """ field """ failed.", -1, ITL_FormatError(hr))
				}
			}

			; map the member id to the index of the variable:
			hr := DllCall(NumGet(NumGet(info+0), 25*A_PtrSize, "Ptr"), "Ptr", info, "UInt", varID, "UInt*", index, "Int") ; ITypeInfo2::GetVarIndexOfMemId()
			if (ITL_FAILED(hr) || index < 0)
			{
				throw Exception("GetVarIndexOfMemId() for """ field """ failed.", -1, ITL_FormatError(hr))
			}

			; now use the index to get the VARDESC structure:
			hr := DllCall(NumGet(NumGet(info+0), 06*A_PtrSize, "Ptr"), "Ptr", info, "UInt", index, "Ptr*", varDesc, "Int") ; ITypeInfo::GetVarDesc()
			if (ITL_FAILED(hr) || !varDesc)
			{
				throw Exception("VARDESC for """ field """ could not be read.", -1, ITL_FormatError(hr))
			}

			; check if it is actually a constant we can map (it is very unlikely / impossible that it's something different, yet check to be sure)
			if (NumGet(1*varDesc, 04 + 7 * A_PtrSize, "UShort") != VARKIND_CONST) ; VARDESC::varkind
			{
				throw Exception("Cannot read non-constant member """ field """!", -1)
			}

			; get the VARIANT value out of the structure and get it's real value:
			varValue := ITL_VARIANT_GetValue(NumGet(1 * varDesc, 2 * A_PtrSize, "Ptr")) ; VARDESC::lpvarValue

			; we don't need the VARDESC structure anymore, so officially release it:
			DllCall(NumGet(NumGet(info+0), 21*A_PtrSize, "Ptr"), "Ptr", info, "Ptr", varDesc) ; ITypeInfo::ReleaseVarDesc()

			return varValue
		}
	}

	; method: __Set
	; throws an error if an attempt is made to change a constant value
	__Set(field, params*)
	{
		if (field != "base" && !RegExMatch(field, "^internal://")) ; ignore base and internal properties (handled by ITL_WrapperBaseClass)
		{
			; throw an exception as setting constants is impossible
			throw Exception("A field must not be set on this class!", -1)
		}
	}

	; method: _NewEnum
	; allows the object to be used within a for-loop
	_NewEnum()
	{
		static VARKIND_CONST := 2
		local hr, typeName, info, obj, attr := 0, varCount, varDesc := 0, varID, pVarName := 0, varValue

		; only loop through the members once, since the constant values won't change
		obj := this["internal://enumerator-object"]
		if (!IsObject(obj)) ; if this is the first iteration
		{
			obj := this["internal://enumerator-object"] := {} ; create a storage object
			typeName := this["internal://typeinfo-name"]
			info := this["internal://typeinfo-instance"]

			; get some attributes of the type
			hr := DllCall(NumGet(NumGet(info+0), 03*A_PtrSize, "Ptr"), "Ptr", info, "Ptr*", attr, "Int") ; ITypeInfo::GetTypeAttr()
			if (ITL_FAILED(hr) || !attr)
			{
				throw Exception("TYPEATTR could not be read.", -1, ITL_FormatError(hr))
			}
			; get the count of variables from the attribute structure
			varCount := NumGet(1*attr, 42+1*A_PtrSize, "UShort") ; TYPEATTR::cVars

			; release the structure as we don't need it any longer
			DllCall(NumGet(NumGet(info+0), 19*A_PtrSize, "Ptr"), "Ptr", info, "Ptr", attr) ; ITypeInfo::ReleaseTypeAttr()

			Loop % varCount ; loop through all variables
			{
				; get the variable description for the current variable (from zero-based index)
				hr := DllCall(NumGet(NumGet(info+0), 06*A_PtrSize, "Ptr"), "Ptr", info, "UInt", A_Index - 1, "Ptr*", varDesc, "Int") ; ITypeInfo::GetVarDesc()
				if (ITL_FAILED(hr) || !varDesc)
				{
					throw Exception("VARDESC no. " A_Index - 1 " could not be read.", -1, ITL_FormatError(hr))
				}

				; check if it is actually a constant we can map (it is very unlikely / impossible that it's something different, yet check to be sure)
				if (NumGet(1*varDesc, 04 + 7 * A_PtrSize, "UShort") != VARKIND_CONST) ; VARDESC::varkind
				{
					throw Exception("Cannot read non-constant member """ field """!", -1)
				}

				; from the structure, get the variable member id:
				varID := NumGet(1*varDesc, 00, "Int") ; VARDESC::memid

				; retrieve the field name
				hr := DllCall(NumGet(NumGet(info+0), 12*A_PtrSize, "Ptr"), "Ptr", info, "Int", varID, "Ptr*", pVarName, "Ptr", 0, "UInt", 0, "Ptr", 0, "Int") ; ITypeInfo::GetDocumentation()
				if (ITL_FAILED(hr) || !pVarName)
				{
					throw Exception("GetDocumentation() failed.", -1, ITL_FormatError(hr))
				}

				; get the VARIANT out of the structure and retrieve its value:
				varValue := ITL_VARIANT_GetValue(NumGet(1 * varDesc, 2 * A_PtrSize, "Ptr")) ; VARDESC::lpvarValue

				; store the field in the enumerator object:
				obj[StrGet(pVarName, "UTF-16")] := varValue

				; release the structure as we're finished with this variable
				DllCall(NumGet(NumGet(info+0), 21*A_PtrSize, "Ptr"), "Ptr", info, "Ptr", varDesc) ; ITypeInfo::ReleaseVarDesc()
				; reset local variables
				pVarName := 0, varDesc := 0
			}
		}

		; return a builtin enumerator for the field-value object:
		return ObjNewEnum(obj)
	}

	NewEnum()
	{
		; allow both syntaxes: obj.NewEnum() redirects to obj._NewEnum()
		return this._NewEnum()
	}
}