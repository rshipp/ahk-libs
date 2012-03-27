class ITL_WrapperBaseClass
{
	__New(typeInfo, lib)
	{
		local hr, name := 0, typeInfo2
		static IID_ITypeInfo2 := "{00020412-0000-0000-C000-000000000046}"

		if (this != ITL_Wrapper.ITL_WrapperBaseClass)
		{
			ObjInsert(this, "internal://data-storage", {})
			this["internal://typelib-object"] := lib, ObjAddRef(lib)

			hr := DllCall(NumGet(NumGet(typeInfo+0), 12*A_PtrSize, "Ptr"), "Ptr", typeInfo, "Int", -1, "Ptr*", name, "Ptr*", 0, "UInt*", 0, "Ptr*", 0, "Int") ; ITypeInfo::GetDocumentation()
			if (ITL_FAILED(hr) || !name)
			{
				;throw Exception("Name for the type description could not be read.", -1, ITL_FormatError(hr))
				throw Exception(ITL_FormatException("Failed to create a wrapper instance."
												, "ITypeInfo::GetDocumentation() failed."
												, ErrorLevel, hr
												, !name, "Invalid name pointer: " name)*)
			}

			this["internal://typeinfo-name"] := StrGet(name, "UTF-16")

			typeInfo2 := ComObjQuery(typeInfo, IID_ITypeInfo2)
			if (!typeInfo2)
			{
				;throw Exception("QueryInterface() failed.", -1)
				throw Exception(ITL_FormatException("Failed to create a wrapper instance."
												, "QueryInterface() for ITypeInfo2 failed."
												, ErrorLevel, ""
												, !typeInfo2, "Invalid ITypeInfo2 pointer returned by ComObjQuery() : " typeInfo2)*)
			}
			this["internal://typeinfo-instance"] := typeInfo2, ObjAddRef(typeInfo2)
		}
	}

	__Delete()
	{
		ObjRelease(this["internal://typelib-object"])
		, ObjRelease(this["internal://typeinfo-instance"])
	}

	__Set(property, value)
	{
		if (property != "base" && !RegExMatch(property, "^internal://"))
			return this["internal://data-storage"][property] := value
	}

	__Get(property)
	{
		if (property != "base" && !RegExMatch(property, "^internal://"))
			return this["internal://data-storage"][property]
	}
}