class TI_CoClassWrapper extends TI_Wrapper.TI_WrapperBaseClass
{
	__New(typeInfo, lib)
	{
		local hr, typeAttr := 0, implCount, implFlags := 0, implHref := -1, implInfo := 0, implAttr := 0, iid, Base
		static IMPLTYPEFLAG_FDEFAULT := 1

		if (this != TI_Wrapper.TI_CoClassWrapper)
		{
			Base.__New(typeInfo, lib)
			ObjInsert(this, "__New", Func("TI_CoClassConstructor"))
			this["internal://class-clsid"] := lib.GetGUID(typeInfo, false, true)

			; get default interface:
			; =======================================
			hr := DllCall(NumGet(NumGet(typeInfo+0), 03*A_PtrSize, "Ptr"), "Ptr", typeInfo, "Ptr*", typeAttr, "Int") ; ITypeInfo::GetTypeAttr()
			if (FAILED(hr) || !typeAttr)
			{
				throw Exception("TYPEATTR could not be read.", -1, FormatError(hr))
			}

			implCount := NumGet(1*typeAttr, 44+1*A_PtrSize, "UShort") ; TYPEATTR::cImplTypes
			Loop % implCount
			{
				hr := DllCall(NumGet(NumGet(typeInfo+0), 09*A_PtrSize, "Ptr"), "Ptr", typeInfo, "UInt", A_Index - 1, "UInt*", implFlags, "Int") ; ITypeInfo::GetImplTypeFlags()
				if (FAILED(hr))
				{
					throw Exception("ImplTypeFlags could not be read.", -1, FormatError(hr))
				}
				if (HasEnumFlag(implFlags, IMPLTYPEFLAG_FDEFAULT))
				{
					hr := DllCall(NumGet(NumGet(typeInfo+0), 08*A_PtrSize, "Ptr"), "Ptr", typeInfo, "UInt", A_Index - 1, "UInt*", implHref, "Int") ; ITypeInfo::GetRefTypeOfImplType()
					if (FAILED(hr) || implHref == -1)
					{
						throw Exception("GetRefTypeOfImplType failed.", -1, FormatError(hr))
					}

					hr := DllCall(NumGet(NumGet(typeInfo+0), 14*A_PtrSize, "Ptr"), "Ptr", typeInfo, "UInt", implHref, "Ptr*", implInfo, "Int") ; ITypeInfo::GetRefTypeInfo()
					if (FAILED(hr) || !implInfo)
					{
						throw Exception("GetRefTypeInfo failed.", -1, FormatError(hr))
					}

					hr := DllCall(NumGet(NumGet(implInfo+0), 03*A_PtrSize, "Ptr"), "Ptr", implInfo, "Ptr*", implAttr, "Int") ; ITypeInfo::GetTypeAttr()
					if (FAILED(hr) || !implAttr)
					{
						throw Exception("TYPEATTR could not be read.", -1, FormatError(hr))
					}

					VarSetCapacity(iid, 16, 00)
					Mem_Copy(implAttr, &iid, 16) ; TYPEATTR::guid
					this["internal://default-iid"] := GUID_ToString(&iid)

					DllCall(NumGet(NumGet(implInfo+0), 19*A_PtrSize, "Ptr"), "Ptr", implInfo, "Ptr", implAttr) ; ITypeInfo::ReleaseTypeAttr()
					break
				}
			}
			DllCall(NumGet(NumGet(typeInfo+0), 19*A_PtrSize, "Ptr"), "Ptr", typeInfo, "Ptr", typeAttr) ; ITypeInfo::ReleaseTypeAttr()
			; =======================================
		}
	}
}