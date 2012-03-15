class TI_EnumWrapper extends TI_Wrapper.TI_ConstantMemberWrapperBaseClass
{
	__New(typeInfo, lib)
	{
		local Base

		if (this != TI_Wrapper.TI_EnumWrapper)
		{
			Base.__New(typeInfo, lib)
			ObjInsert(this, "__New", Func("TI_AbstractClassConstructor"))
		}
	}
}