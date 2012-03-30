; various misc. helper functions, later t be sorted out to separate classes / libs / files.

ITL_IsSafeArray(obj)
{
	static VT_ARRAY := 0x2000
	return IsObject(obj) && ITL_HasEnumFlag(ComObjType(obj), VT_ARRAY)
}

ITL_SafeArrayType(obj)
{
	static VT_ARRAY := 0x2000, VT_NULL := 1
	if (ITL_IsSafeArray(obj))
		return ComObjType(obj) ^ VT_ARRAY
	return VT_NULL
}

ITL_CreateStructureSafeArray(type, dims*)
{
	static VT_RECORD := 0x24
	local arr, hr

	if (dims.MaxIndex() > 8 || dims.MinIndex() != 1)
		throw Exception(ITL_FormatException("Failed to create a structure SAFEARRAY."
										, "Invalid dimensions were specified."
										, ErrorLevel)*)

	arr := ComObjArray(VT_RECORD, dims*)
	hr := DllCall("OleAut32\SafeArraySetRecordInfo", "Ptr", ComObjValue(arr), "Ptr", type[ITL.Properties.TYPE_RECORDINFO], "Int")
	if (ITL_FAILED(hr))
		throw Exception(ITL_FormatException("Failed to create a structure SAFEARRAY."
										, "Could not set IRecordInfo."
										, ErrorLevel, hr)*)

	return arr
}

; for structures and interfaces
ITL_GetInstancePointer(instance)
{
	return instance[ITL.Properties.INSTANCE_POINTER]
}

ITL_CreateStructureArray(type, count)
{
	return new ITL.ITL_StructureArray(type, count)
}