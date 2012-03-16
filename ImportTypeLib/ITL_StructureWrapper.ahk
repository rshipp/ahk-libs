class ITL_StructureWrapper extends ITL_Wrapper.ITL_WrapperBaseClass
{
	__New(typeInfo)
	{
		local Base
		if (this != ITL_Wrapper.ITL_StructureWrapper)
		{
			Base.__New(typeInfo)
			ObjInsert(this, "__New", Func("ITL_StructureConstructor"))
		}
	}

	__Get(field)
	{
		; ...
	}

	__Set(field, value)
	{
		; ...
	}
}