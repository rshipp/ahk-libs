TI_CoClassConstructor(this, iid = 0)
{
	static IMPLTYPEFLAG_FDEFAULT := 1
	local info, typeAttr := 0, hr, iid_mem, instance := 0

	info := this.base["internal://typeinfo-instance"]

	hr := DllCall(NumGet(NumGet(info+0), 03*A_PtrSize, "Ptr"), "Ptr", info, "Ptr*", typeAttr, "Int") ; ITypeInfo::GetTypeAttr()
	if (FAILED(hr) || !typeAttr)
	{
		throw Exception("TYPEATTR could not be read.", -1, FormatError(hr))
	}

	if (!iid)
	{
		iid := this.base["internal://default-iid"] ; get coclass default interface
		if (!iid) ; there's no default interface
		{
			throw Exception("An IID must be specified to create an instance of this class.", -1)
		}
	}

	hr := GUID_FromString(iid, iid_mem)
	if (FAILED(hr))
	{
		throw Exception("GUID could not be converted.", -1, FormatError(hr))
	}
	iid := &iid_mem

	hr := DllCall(NumGet(NumGet(info+0), 16*A_PtrSize, "Ptr"), "Ptr", info, "Ptr", 0, "Ptr", iid, "Ptr*", instance, "Int") ; ITypeInfo::CreateInstance()
	if (FAILED(hr) || !instance)
	{
		throw Exception("CreateInstance failed.", -1, FormatError(hr))
	}
	return instance
}