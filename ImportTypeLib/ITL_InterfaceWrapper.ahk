; class: ITL_InterfaceWrapper
; This class enwraps COM interfaces and provides the ability to call methods, set and retrieve properties.
class ITL_InterfaceWrapper extends ITL_Wrapper.ITL_WrapperBaseClass
{
	; method: __New
	; This is the constructor for the wrapper, used by ITL_TypeLibWrapper.
	__New(typeInfo, lib)
	{
		local Base
		if (this != ITL_Wrapper.ITL_InterfaceWrapper)
		{
			Base.__New(typeInfo, lib)
			ObjInsert(this, "__New", Func("ITL_InterfaceConstructor")) ; change constructor for instances
			this["internal://interface-iid"] := lib.GetGUID(typeInfo, false, true) ; save IID
		}
	}

	; method: __Call
	; calls a method in the wrapped interface
	__Call(method, params*)
	{
		; code inspired by AutoHotkey_L source (script_com.cpp)
		static DISPATCH_METHOD := 0x1
		, DISPID_UNKNOWN := -1
		, sizeof_DISPPARAMS := 8 + 2 * A_PtrSize, sizeof_EXCEPINFO := 12 + 5 * A_PtrSize, sizeof_VARIANT := 8 + 2 * A_PtrSize
		, DISP_E_MEMBERNOTFOUND := -2147352573, DISP_E_UNKNOWNNAME := -2147352570
		, INVOKEKIND_FUNC := 1
		local paramCount, dispparams, rgvarg := 0, hr, info, dispid := DISPID_UNKNOWN, instance, excepInfo, err_index, result, variant, index := -1, funcdesc := 0, vt ;, fn

		paramCount := params.maxIndex() > 0 ? params.maxIndex() : 0 ; the ternary is necessary, otherwise it would hold an empty string, causing calculations to fail
		info := this["internal://typeinfo-instance"]
		instance := this["internal://type-instance"]

		; init structures
		if (VarSetCapacity(dispparams, sizeof_DISPPARAMS, 00) != sizeof_DISPPARAMS)
		{
			;throw Exception("Out of memory.", -1)
			throw Exception(ITL_FormatException("Out of memory", "Memory allocation for DISPPARAMS failed.", ErrorLevel)*)
		}
		if (VarSetCapacity(result, sizeof_VARIANT, 00) != sizeof_VARIANT)
		{
			;throw Exception("Out of memory.", -1)
			throw Exception(ITL_FormatException("Out of memory", "Memory allocation for the result VARIANT failed.", ErrorLevel)*)
		}
		if (VarSetCapacity(excepInfo, sizeof_EXCEPINFO, 00) != sizeof_EXCEPINFO)
		{
			;throw Exception("Out of memory.", -1)
			throw Exception(ITL_FormatException("Out of memory", "Memory allocation for EXCEPINFO failed.", ErrorLevel)*)
		}

		; get MEMBERID for called method:
		hr := DllCall(NumGet(NumGet(info+0), 10*A_PtrSize, "Ptr"), "Ptr", info, "Str*", method, "UInt", 1, "UInt*", dispid, "Int") ; ITypeInfo::GetIDsOfNames()
		if (ITL_FAILED(hr) || dispid == DISPID_UNKNOWN)
		{
			/*
			if (hr == DISP_E_UNKNOWNNAME)
			{
				if (IsFunc(fn := "Obj" . LTrim(method, "_"))) ; if member not found: check for internal method
				{
					return %fn%(this, params*)
				}
			}
			*/
			;throw Exception("GetIDsOfNames() for """ method """ failed.", -1, ITL_FormatError(hr))
			throw Exception(ITL_FormatException("Failed to call a method."
											, "ITypeInfo::GetIDsOfNames() for """ method """ failed."
											, ErrorLevel, hr
											, dispid != DISPID_UNKNOWN, "Invalid DISPID: " dispid)*)
		}

		if (paramCount > 0)
		{
			if (VarSetCapacity(rgvarg, sizeof_VARIANT * paramCount, 00) != (sizeof_VARIANT * paramCount)) ; create VARIANT array
				throw Exception("Out of memory.", -1)

			hr := DllCall(NumGet(NumGet(info+0), 24*A_PtrSize, "Ptr"), "Ptr", info, "UInt", dispid, "UInt", INVOKEKIND_FUNC, "UInt*", index) ; ITypeInfo2::GetFuncIndexOfMemId(_this, dispid, invkind, [out] index)
			if (ITL_FAILED(hr) || index == -1)
			{
				;throw Exception("ITypeInfo2::GetFuncIndexOfMemId() failed.", -1, ITL_FormatError(hr))
				throw Exception(ITL_FormatException("Failed to call a method."
												, "ITypeInfo2::GetFuncIndexOfMemId() for """ method """ failed."
												, ErrorLevel, hr
												, index == -1, "Invalid function index: " index)*)
			}

			hr := DllCall(NumGet(NumGet(info+0), 05*A_PtrSize, "Ptr"), "ptr", info, "UInt", index, "Ptr*", funcdesc) ; ITypeInfo::GetFuncDesc(_this, index, [out] funcdesc)
			if (ITL_FAILED(hr) || !funcdesc)
			{
				;throw Exception("ITypeInfo::GetFuncDesc() failed.", -1, ITL_FormatError(hr))
				throw Exception(ITL_FormatException("Failed to call a method."
												, "ITypeInfo::GetFuncDesc() for """ method """ (index " index ") failed."
												, ErrorLevel, hr
												, !funcdesc, "Invalid FUNCDESC pointer: " funcdesc)*)
			}

			paramArray := NumGet(1*funcdesc, 04 + A_PtrSize, "Ptr") ; FUNCDESC::lprgelemdescParam
			if (!paramArray)
			{
				;throw Exception("Array of parameter descriptions could not be read.", -1)
				throw Exception(ITL_FormatException("Failed to call a method."
												, "The array of parameter descriptions (FUNCDESC::lprgelemdescParam) could not be read."
												, ErrorLevel, ""
												, !paramArray, "Invalid ELEMDESC[] pointer: " paramArray)*)
			}

			Loop % paramCount
			{
				vt := NumGet(1*paramArray, (A_Index - 1) * (4*A_PtrSize) + A_PtrSize, "UShort") ; ELEMDESC[A_Index - 1]::tdesc::vt

				ITL_VARIANT_Create(params[A_Index], variant) ; create VARIANT and put it in the array
				, ITL_Mem_Copy(&variant, &rgvarg + (A_Index - 1) * sizeof_VARIANT, sizeof_VARIANT)
			}
			NumPut(&rgvarg, dispparams, 00, "Ptr") ; DISPPARAMS::rgvarg - the pointer to the VARIANT array
			NumPut(paramCount, dispparams, 2 * A_PtrSize, "UInt") ; DISPPARAMS::cArgs - the number of arguments passed

			DllCall(NumGet(NumGet(info+0), 20*A_PtrSize, "Ptr"), "Ptr", info, "Ptr", funcdesc) ; ITypeInfo::ReleaseFuncDesc(_this, funcdesc)
		}

		; invoke the function
		; currently, the excepinfo structure is not used; also, the last parameter (index of a bad argument if any) is not passed
		hr := DllCall(NumGet(NumGet(info+0), 11*A_PtrSize, "Ptr"), "Ptr", info, "Ptr", instance, "UInt", dispid, "UShort", DISPATCH_METHOD, "Ptr", &dispparams, "Ptr", &result, "Ptr", &excepInfo, "Ptr", 0, "Int") ; ITypeInfo::Invoke()
		if (ITL_FAILED(hr))
		{
			/*
			if (hr == DISP_E_MEMBERNOTFOUND)
			{
				; If member not found: check for internal method
				; A 2nd check is needed here because a class / interface could have a property with the same name as an AHK object function.
				; In that case, GetIDsOfNames() would do well, but it would fail here.
				; In all other cases, i.e. where the class / interface does not have such a property, GetIDsOfNames would fail - thus a check is needed there, too.
				if (IsFunc(fn := "Obj" . LTrim(method, "_")))
				{
					return %fn%(this, params*)
				}
			}
			*/
			; use EXCEPINFO here!
			;throw Exception("""" method "()"" could not be called.", -1, ITL_FormatError(hr))
			throw Exception(ITL_FormatException("Failed to call a method."
											, "ITypeInfo::Invoke() failed for """ method """."
											, ErrorLevel, hr)*)
		}
		return ITL_VARIANT_GetValue(&result) ; return the result of the call
	}

	; method: __Get
	; retrieves instance properties from an interface
	__Get(property)
	{
		; code inspired by AutoHotkey_L source (script_com.cpp)
		static DISPATCH_PROPERTYGET := 0x2, DISPATCH_METHOD := 0x1
		, DISPID_UNKNOWN := -1
		, sizeof_DISPPARAMS := 8 + 2 * A_PtrSize, sizeof_EXCEPINFO := 12 + 5 * A_PtrSize, sizeof_VARIANT := 8 + 2 * A_PtrSize
		local dispparams, hr, info, dispid := DISPID_UNKNOWN, instance, excepInfo, err_index, result

		if (property != "base" && !RegExMatch(property, "^internal://")) ; ignore base and internal properties (handled by ITL_WrapperBaseClass)
		{
			; init structures
			if (VarSetCapacity(dispparams, sizeof_DISPPARAMS, 00) != sizeof_DISPPARAMS)
			{
				;throw Exception("Out of memory.", -1)
				throw Exception(ITL_FormatException("Out of memory", "Memory allocation for DISPPARAMS failed.", ErrorLevel)*)
			}
			if (VarSetCapacity(result, sizeof_VARIANT, 00) != sizeof_VARIANT)
			{
				;throw Exception("Out of memory.", -1)
				throw Exception(ITL_FormatException("Out of memory", "Memory allocation for the result VARIANT failed.", ErrorLevel)*)
			}
			if (VarSetCapacity(excepInfo, sizeof_EXCEPINFO, 00) != sizeof_EXCEPINFO)
			{
				;throw Exception("Out of memory.", -1)
				throw Exception(ITL_FormatException("Out of memory", "Memory allocation for EXCEPINFO failed.", ErrorLevel)*)
			}

			info := this["internal://typeinfo-instance"]
			instance := this["internal://type-instance"]

			; get MEMBERID for the method to be retrieved:
			hr := DllCall(NumGet(NumGet(info+0), 10*A_PtrSize, "Ptr"), "Ptr", info, "Str*", property, "UInt", 1, "UInt*", dispid, "Int") ; ITypeInfo::GetIDsOfNames()
			if (ITL_FAILED(hr) || dispid == DISPID_UNKNOWN)
			{
				;throw Exception("GetIDsOfNames() for """ property """ failed.", -1, ITL_FormatError(hr))
				throw Exception(ITL_FormatException("Failed to retrieve a property."
												, "ITypeInfo::GetIDsOfNames() for """ property """ failed."
												, ErrorLevel, hr
												, dispid == DISPID_UNKNOWN, "Invalid DISPID: " dispid)*)
			}

			; get the property:
			; as with __Call, excepinfo is not yet used
			hr := DllCall(NumGet(NumGet(info+0), 11*A_PtrSize, "Ptr"), "Ptr", info, "Ptr", instance, "UInt", dispid, "UShort", DISPATCH_METHOD | DISPATCH_PROPERTYGET, "Ptr", &dispparams, "Ptr", &result, "Ptr", &excepInfo, "Ptr", 0, "Int") ; ITypeInfo::Invoke()
			if (ITL_FAILED(hr))
			{
				;throw Exception("""" property """ could not be retrieved.", -1, ITL_FormatError(hr))
				throw Exception(ITL_FormatException("Failed to retrieve a property."
												, "ITypeInfo::Invoke() for """ property """ failed."
												, ErrorLevel, hr)*)
			}
			return ITL_VARIANT_GetValue(&result) ; return the result, i.e. the value of the property
		}
	}

	; method: __Set
	; sets an instance property
	__Set(property, value)
	{
		; code inspired by AutoHotkey_L source (script_com.cpp)
		static DISPATCH_PROPERTYPUTREF := 0x8, DISPATCH_PROPERTYPUT := 0x4
		, DISPID_UNKNOWN := -1, DISPID_PROPERTYPUT := -3
		, sizeof_DISPPARAMS := 8 + 2 * A_PtrSize, sizeof_EXCEPINFO := 12 + 5 * A_PtrSize
		, VT_UNKNOWN := 13, VT_DISPATCH := 9
		, DISP_E_MEMBERNOTFOUND := -2147352573
		local variant, dispparams, hr, info, dispid := DISPID_UNKNOWN, vt, instance, excepInfo, err_index, variant

		if (property != "base" && !RegExMatch(property, "^internal://")) ; ignore base and internal properties (handled by ITL_WrapperBaseClass)
		{
			; init structures
			if (VarSetCapacity(dispparams, sizeof_DISPPARAMS, 00) != sizeof_DISPPARAMS)
			{
				;throw Exception("Out of memory.", -1)
				throw Exception(ITL_FormatException("Out of memory", "Memory allocation for DISPPARAMS failed.", ErrorLevel)*)
			}
			if (VarSetCapacity(excepInfo, sizeof_EXCEPINFO, 00) != sizeof_EXCEPINFO)
			{
				;throw Exception("Out of memory.", -1)
				throw Exception(ITL_FormatException("Out of memory", "Memory allocation for EXCEPINFO failed.", ErrorLevel)*)
			}

			; create a VARIANT from the new value
			ITL_VARIANT_Create(value, variant)
			NumPut(&variant, dispparams, 00, "Ptr") ; DISPPARAMS::rgvarg - the VARIANT "array", a single item here
			NumPut(1, dispparams, 2 * A_PtrSize, "UInt") ; DISPPARAMS::cArgs - the count of VARIANTs (1 in this case)

			NumPut(&DISPID_PROPERTYPUT, dispparams, A_PtrSize, "Ptr") ; DISPPARAMS::rgdispidNamedArgs - indicate a property is being set
			NumPut(1, dispparams, 2 * A_PtrSize + 4, "UInt") ; DISPPARAMS::cNamedArgs

			info := this["internal://typeinfo-instance"]
			instance := this["internal://type-instance"]

			; get MEMBERID for the method to be set:
			hr := DllCall(NumGet(NumGet(info+0), 10*A_PtrSize, "Ptr"), "Ptr", info, "Str*", property, "UInt", 1, "UInt*", dispid, "Int") ; ITypeInfo::GetIDsOfNames()
			if (ITL_FAILED(hr) || dispid == DISPID_UNKNOWN) ; an error code was returned or the ID is invalid
			{
				;throw Exception("GetIDsOfNames() for """ property """ failed.", -1, ITL_FormatError(hr))
				throw Exception(ITL_FormatException("Failed to set a property."
												, "ITypeInfo::GetIDsOfNames() for """ property """ failed."
												, ErrorLevel, hr
												, dispid == DISPID_UNKNOWN, "Invalid DISPID: " dispid)*)
			}

			; get VARTYPE from the VARIANT structure
			vt := NumGet(variant, 00, "UShort")
			; for VT_UNKNOWN and VT_DISPATCH, invoke with DISPATCH_PROPERTYPUTREF first:
			if (vt == VT_DISPATCH || vt == VT_UNKNOWN)
			{
				; as with __Call, excepinfo is not yet used
				hr := DllCall(NumGet(NumGet(info+0), 11*A_PtrSize, "Ptr"), "Ptr", info, "Ptr", instance, "UInt", dispid, "UShort", DISPATCH_PROPERTYPUTREF, "Ptr", &dispparams, "Ptr*", 0, "Ptr", &excepInfo, "UInt*", err_index, "Int") ; ITypeInfo::Invoke()
				if (ITL_SUCCEEDED(hr))
				{
					return value ; return the original value to allow "a := obj.prop := value" and similar
				}
				else if (hr != DISP_E_MEMBERNOTFOUND) ; if member not found, retry below with DISPATCH_PROPERTYPUT
				{
					;throw Exception("""" property """ could not be set.", -1, ITL_FormatError(hr)) ; otherwise an error occured
					throw Exception(ITL_FormatException("Failed to set a property."
													, "ITypeInfo::Invoke() for """ property """ failed."
													, ErrorLevel, hr)*)
				}
			}

			; set the property:
			; as with __Call, excepinfo is not yet used
			hr := DllCall(NumGet(NumGet(info+0), 11*A_PtrSize, "Ptr"), "Ptr", info, "Ptr", instance, "UInt", dispid, "UShort", DISPATCH_PROPERTYPUT, "Ptr", &dispparams, "Ptr*", 0, "Ptr", &excepInfo, "UInt*", err_index, "Int") ; ITypeInfo::Invoke()
			if (ITL_FAILED(hr))
			{
				;throw Exception("""" property """ could not be set.", -1, ITL_FormatError(hr))
				throw Exception(ITL_FormatException("Failed to set a property."
												, "ITypeInfo::Invoke() for """ property """ failed."
												, ErrorLevel, hr)*)
			}
			return value ; return the original value to allow "a := obj.prop := value" and similar
		}
	}
}