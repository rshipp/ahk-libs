/*
File: CCFGenerator.ahk
Script: ComGenerator

Purpose:
	the actual creation of classes

Authors:
	* maul.esel

Requirements:
	AutoHotkey - AutoHotkey_L v1.1+
	Libraries - CCF (https://github.com/maul-esel/COM-Classes)

License:
	http://unlicense.org
*/
class CCFGenerator
{
	Methods := []

	PseudoProperties := []

	version := AHKVersion.NONE

	typeInfo := 0

	typeInfo2 := 0

	typeAttr := 0

	__New(type, version)
	{
		if (version == AHKVersion.NONE)
			throw Exception("An AutoHotkey version must be specified.", -1)

		this.typeInfo := type, this.version := version
		, this.typeAttr := type.GetTypeAttr(), this.typeInfo.AddRef()

		if (this.IsIDispatch() && this.typeAttr.guid != Dispatch.IID)
			throw Exception("Dispatch interfaces must not be wrapped.", -1)

		pTypeInfo2 := type.QueryInterface(TypeInfo2.IID)
		if (pTypeInfo2)
			this.typeInfo2 := new TypeInfo2(pTypeInfo2)
	}

	__Delete()
	{
		this.typeInfo.ReleaseTypeAttr(this.typeAttr), this.typeInfo.Release()
		if (this.typeInfo2)
			this.typeInfo2.Release()
	}

	isAHK_L()
	{
		return this.version == AHKVersion.AHK_L
	}

	isAHK2()
	{
		return this.version == AHKVersion.AHK2
	}

	Generate()
	{
		tkind := this.typeAttr.typekind
		if (tkind == TYPEKIND.ENUM)
			return this.GenerateEnumClass()
		else if (tkind == TYPEKIND.RECORD)
			return this.GenerateStructClass()
		else if (tkind == TYPEKIND.INTERFACE)
			return this.GenerateInterfaceClass()
		else
			throw Exception("CCFGenerator.Generate(): The specified type information cannot be wrapped into a CCF class.", -1, "Type was of kind """ Obj_FindValue(TYPEKIND, tkind) """.")
	}

	GenerateInterfaceClass()
	{
		if (!this.typeInfo.GetDocumentation(MEMBERID.NIL, interface_name, interface_doc))
			throw Exception("Error calling TypeInfo.GetDocumentation()", -1, this.typeInfo.error.description)

		; TODO: if not already wrapped {
		baseRef := this.typeInfo.GetRefTypeOfImplType(0)
		, baseInfo := this.typeInfo.GetRefTypeInfo(baseRef)
		, baseGenerator := new CCFGenerator(baseInfo, this.version)

		try {
			;result := baseGenerator.Generate()
		} catch exception {
			;throw Exception("CCFGenerator.GenerateInterfaceClass(): The base type could not be generated.", -1, ex.extra)
		}
		; }

		list := ""
		Loop % this.typeAttr.cFuncs
		{
			;MsgBox enter iteration
			func%A_Index% := this.typeInfo.GetFuncDesc(A_Index - 1) ; crashes here in 2nd iteration - why???
			;MsgBox will now generate...
			list .= this.GenerateMethod(func%A_Index%)
			this.typeInfo.ReleaseFuncDesc(func%A_Index%)
			;MsgBox leave iteration
		}

		MsgBox interface %interface_name% {`n%list%}
	}

	GenerateMethod(func)
	{
		local list
		this.typeInfo.GetDocumentation(func.memid, function_name, function_doc)
		list := "`t" this.ResolveType(func.elemdescFunc.tdesc) " " function_name "( "

		if (func.funckind != FUNCKIND.PUREVIRTUAL)
			throw Exception("Can only wrap pure virtual methods!", -1, """" interface_name "::" function_name "()"" is of kind """ Obj_FindValue(FUNCKIND, func.funckind) """.")

		vtbl_index := func.oVft // A_PtrSize

		if (this.isAHK2())
		{
			this.Methods.Insert(function_name "()`n{`n`t`n}`n")
		}
		else if (this.isAHK_L())
		{
			this.Methods.Insert(function_name "()`n{`n`t`n}`n")
		}

		this.typeInfo.GetNames(func.memid, names)
		Loop % func.cParams
		{
			try {
				list .= this.ResolveType(func.lprgelemdescParam[A_Index].tdesc) A_Space
			} catch {
			}
			list .= names[A_Index + 1]
			if (A_Index < func.cParams)
				list .= ", "
		}
		list .= " ) [" Obj_FindValue(INVOKEKIND, func.invkind) "] at vtable-index " vtbl_index "`n"

		/*
		if (func.invkind != INVOKEKIND.METHOD)
		{
			property_name := "" ; todo
			property := this.FindPseudoProperty(property_name)
			if (!IsObject(property))
			{
				property := new AHK.PseudoProperty(property_name)
				this.PseudoProperties.Insert(property)
			}

			if (func.invkind == INVOKEKIND.PROPERTYGET)
				property.getMethod := function_name
			else if (func.invkind == INVOKEKIND.PROPERTYPUT || func.invkind == INVOKEKIND.PROPERTYPUTREF)
				property.setMethod := function_name
		}
		*/
		return list
	}

	FindPseudoProperty(name)
	{
		for each, property in this.PseudoProperties
			if (property.Name == name)
				return property
		return ""
	}

	GenerateStructClass()
	{
	
	}

	GenerateEnumClass()
	{
		if (!this.typeInfo.GetDocumentation(MEMBERID.NIL, enum_name, enum_doc))
			throw Exception("Error calling TypeInfo.GetDocumentation()", -1, this.typeInfo.error.description)
		for each, var in ITypeInfoEx_LoadVariables(this.typeInfo)
		{
			MsgBox % var.varkind " - " Obj_FindValue(VARKIND, var.varkind) " - " var.lpstrSchema
			if (var.varkind != VARKIND.CONST)
				throw Exception("CCFGenerator.GenerateEnumClass(): only constant variables can be wrapped!", -1)

			if (!this.typeInfo.GetDocumentation(var.memid, name, doc))
				throw Exception("CCFGenerator.GenerateEnumClass(): Error calling TypeInfo.GetDocumentation():`n`t" . this.typeInfo.error.description, -1)

			/*
			TODO:
				* (map to AHK type)
				* create documentation
				* get value from var.lpvarValue
			*/
			type := var.elemdescVar.tdesc.vt
			if (type == VARENUM.PTR || type == VARENUM.ARRAY || type == VARENUM.CARRAY || type == VARENUM.USERDEFINED)
			{
				throw Exception("CCFGenerator.GenerateEnumClass(): Cannot handle pointers, arrays, safearrays or user-defined types in enumerations!", -1)
			}
			NumPut(NumGet(1*var.lpvarValue, 00, "UInt64"), value, 00, "UInt64")
		}
	}

	IsIDispatch()
	{
		return CCFramework.HasEnumFlag(this.typeAttr.wTypeFlags, TYPEFLAG.FDISPATCHABLE)
	}

	GetNameForHREFTYPE(href)
	{
		info := this.typeInfo.GetRefTypeInfo(href)
		info.GetDocumentation(-1, name)
		return name
	}

	ResolveType(tdesc)
	{
		;MsgBox % "vt == " tdesc.vt
		if (tdesc.vt == VARENUM.PTR)
		{
		;	MsgBox type is pointer
			return this.ResolveType(tdesc.lptdesc) "*"
		}
		else if (tdesc.vt == VARENUM.SAFEARRAY)
			return "ComObjArray[" this.ResolveType(tdesc.lptdesc) "]"
		else if (tdesc.vt == VARENUM.CARRAY)
		{
			; todo
		}
		else if (tdesc.vt == VARENUM.USERDEFINED)
		{
		;	MsgBox % "type is userdefined: " tdesc.hreftype
			return this.GetNameForHREFTYPE(tdesc.hreftype)
		}
		;MsgBox type is normal

		vt := tdesc.vt, suffix := ""
		if CCFramework.HasEnumFlag(vt, VARENUM.BYREF)
		{
			suffix := "*", vt ^= VARENUM.BYREF
			MsgBox type is byref
		}

		; "normal" types
		if (vt == VARENUM.I1)
			return "Char"
		else if (vt == VARENUM.UI1)
			return "UChar"
		else if (vt == VARENUM.I2)
			return "Short"
		else if (vt == VARENUM.UI2)
			return "UShort"
		else if (vt == VARENUM.I4 || vt == VARENUM.BOOL || vt == VARENUM.INT || vt == VARENUM.HRESULT || vt == VARENUM.ERROR)
			return "Int"
		else if (vt == VARENUM.UI4 || vt == VARENUM.UINT)
			return "UInt"
		else if (vt == VARENUM.I8 || vt == VARENUM.UI8 || vt == VARENUM.CY)
			return "Int64"
		else if (vt == VARENUM.R4)
			return "Float"
		else if (vt == VARENUM.R8)
			return "Double"
		else if (vt == VARENUM.DATE)
			throw Exception("Type 'DATE' could not be mapped.", -1, "Not implemented")
		else if (vt == VARENUM.BSTR || vt == VARENUM.LPSTR)
			return "Str"
		else if (vt == VARENUM.LPWSTR)
			return this.isAHK_L() ? "WStr" : "Str"
		else if (vt == VARENUM.DISPATCH || vt == VARENUM.UNKNOWN)
			return "Ptr"
		else if (vt == VARENUM.VARIANT)
			throw Exception("Type 'VARIANT' could not be mapped.", -1, "Not implemented")
		else if (vt == VARENUM.DECIMAL)
			throw Exception("Type 'DECIMAL' could not be mapped.", -1, "Not implemented")
		else if (vt == VARENUM.VOID)
			return ""
		throw Exception("Could not resolve type", -1, "VT value: " vt (name := Obj_FindValue(VARENUM, vt) ? " - " name : ""))
	}
}

