ITL_StructureConstructor(this, ptr = 0)
{
	local hr, rcinfo := this.base["internal://rcinfo-instance"]

	if (!ptr)
	{
		ptr := DllCall(NumGet(NumGet(rcinfo+0), 16*A_PtrSize, "Ptr"), "Ptr", rcinfo, "Ptr") ; IRecordInfo::RecordCreate()
	}
	else
	{
		hr := DllCall(NumGet(NumGet(rcinfo+0), 03*A_PtrSize, "Ptr"), "Ptr", rcinfo, "Ptr", ptr, "Int") ; IRecordInfo::RecordInit()
		if (ITL_FAILED(hr))
		{
			throw Exception("RecordInit() failed.", -1, ITL_FormatError(hr))
		}
	}

	this["internal://type-instance"] := ptr
}