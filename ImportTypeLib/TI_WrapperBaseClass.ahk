class TI_WrapperBaseClass
{
	__New(typeInfo, lib)
	{
		local hr, name := 0

		if (this != TI_Wrapper.TI_WrapperBaseClass)
		{
			ObjInsert(this, "internal://data-storage", {})
			this["internal://typelib-object"] := lib, ObjAddRef(lib)
			this["internal://typeinfo-instance"] := typeInfo

			hr := DllCall(NumGet(NumGet(typeInfo+0), 12*A_PtrSize, "Ptr"), "Ptr", typeInfo, "Int", -1, "Ptr*", name, "Ptr*", 0, "UInt*", 0, "Ptr*", 0, "Int")
			if (FAILED(hr) || !name)
			{
				throw Exception("Name for the type description could not be read.", -1, TI_FormatError(hr))
			}

			this["internal://typeinfo-name"] := StrGet(name, "UTF-16")
		}
	}

	__Delete()
	{
		ObjRelease(this["internal://typelib-object"])
	}

	__Set(property, value)
	{
		return this["internal://data-storage"][property] := value
	}

	__Get(property)
	{
		if (property != "base" && property != "internal://data-storage")
			return this["internal://data-storage"][property]
	}
}