/*
File: ITypeInfoEx.ahk
Script: ComGenerator

Purpose:
	holds functions used to extract extended information about TypeInfo instances.

Authors:
	* maul.esel

Requirements:
	AutoHotkey - AutoHotkey_L v1.1+
	Libraries - CCF (https://github.com/maul-esel/COM-Classes)

License:
	http://unlicense.org
*/
/*
Function: ITypeInfoEx_LoadFunctions
loads an array of FUNCDESC structures for all functions in a given TypeInfo

Parameters:
	TypeInfo type - the TypeInfo instance containing the functions

Returns:
	FUNCDESC[] funcs - an AHK-array of FUNCDESC instances

Remarks:
	- Requires the FUNCDESC struct to be wrapped & included in CCF. Otherwise the array contains raw pointers.
*/
ITypeInfoEx_LoadFunctions(type)
{
	arr := []
	Loop % type.GetTypeAttr().cFuncs
		arr.Insert(type.GetFuncDesc(A_Index - 1))
	return arr
}

/*
Function: ITypeInfoEx_LoadVariables
loads an array of VARDESC structures for all variables in a given TypeInfo

Parameters:
	TypeInfo type - the TypeInfo instance containing the variables

Returns:
	VARDESC[] funcs - an AHK-array of VARDESC instances

Remarks:
	- Requires the VARDESC struct to be wrapped & included in CCF. Otherwise the array contains raw pointers.
*/
ITypeInfoEx_LoadVariables(type)
{
	arr := []
	Loop % type.GetTypeAttr().cVars
		arr.Insert(type.GetVarDesc(A_Index - 1))
	return arr
}

/*
Function: ITypeInfoEx_IsDispatch
checks whether a given TypeInfo describes an IDispatch or dual interface

Parameters:
	TypeInfo type - the TypeInfo instance to test

Returns:
	BOOL isdisp - true if the interface is a dispinterface or a dual interface, false otherwise
*/
ITypeInfoEx_IsDispatch(type)
{
	attr := type.GetTypeAttr()
	return attr.typekind == TYPEKIND.DISPATCH || CCFramework.HasEnumFlag(attr.wTypeFlags, TYPEFLAG.FDUAL)
}