class TI_InterfaceWrapper extends TI_Wrapper.TI_ExecutableWrapperBaseClass
{
	__New(typeInfo, lib)
	{
		local Base
		if (this != TI_Wrapper.TI_InterfaceWrapper)
		{
			Base.__New(typeInfo, lib)
			ObjInsert(this, "__New", Func("TI_InterfaceConstructor"))
			this["internal://interface-iid"] := lib.GetGUID(typeInfo, false, true)
		}
	}
}