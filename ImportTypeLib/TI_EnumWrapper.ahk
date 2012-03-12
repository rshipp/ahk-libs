class TI_EnumWrapper extends TI_Wrapper.TI_WrapperBaseClass
{
	__New(typeInfo, lib)
	{
		local hr, attr := 0, varCount, varDesc := 0, varName := 0, varID, varValue, pVarName := 0, typeName, Base

		if (this != TI_Wrapper.TI_EnumWrapper)
		{
			Base.__New(typeInfo, lib)
			typeName := this["internal://typeinfo-name"]

			hr := DllCall(NumGet(NumGet(typeInfo+0), 03*A_PtrSize, "Ptr"), "Ptr", typeInfo, "Ptr*", attr, "Int") ; ITypeInfo::GetTypeAttr()
			if (FAILED(hr) || !attr)
			{
				throw Exception("TYPEATTR could not be read.", -1, TI_FormatError(hr))
			}
			varCount := NumGet(1*attr, 42+1*A_PtrSize, "UShort") ; TYPEATTR::cVars

			DllCall(NumGet(NumGet(typeInfo+0), 19*A_PtrSize, "Ptr"), "Ptr", typeInfo, "Ptr", attr) ; ITypeInfo::ReleaseTypeAttr()

			Loop % varCount
			{
				hr := DllCall(NumGet(NumGet(typeInfo+0), 06*A_PtrSize, "Ptr"), "Ptr", typeInfo, "UInt", A_Index - 1, "Ptr*", varDesc, "Int") ; ITypeInfo::GetVarDesc()
				if (FAILED(hr) || !varDesc)
				{
					throw Exception("VARDESC no. " A_Index - 1 " could not be read.", -1, TI_FormatError(hr))
				}

				varID := NumGet(1*varDesc, 00, "Int") ; VARDESC::memid
				hr := DllCall(NumGet(NumGet(typeInfo+0), 12*A_PtrSize, "Ptr"), "Ptr", typeInfo, "Int", varID, "Ptr*", pVarName, "Ptr", 0, "UInt", 0, "Ptr", 0, "Int") ; ITypeInfo::GetDocumentation()
				if (FAILED(hr) || !pVarName)
				{
					throw Exception("GetDocumentation() failed.", -1, TI_FormatError(hr))
				}
				varValue := NumGet(NumGet(1 * varDesc, 04 + A_PtrSize, "Ptr"), 08, "Int") ; VARDESC::lpvarValue::lVal

				varName := StrGet(pVarName, "UTF-16")
				if (InStr(varName, typeName . "_", true) == 1)
					varName := SubStr(varName, StrLen(typeName) + 2, StrLen(varName) - StrLen(typeName))
				this[varName] := varValue

				DllCall(NumGet(NumGet(typeInfo+0), 21*A_PtrSize, "Ptr"), "Ptr", typeInfo, "Ptr", varDesc) ; ITypeInfo::ReleaseVarDesc()
				varName := 0, varDesc := 0
			}

			ObjInsert(this, "__New", Func("TI_AbstractClassConstructor"))
		}
	}
}