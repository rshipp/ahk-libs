class TI_Wrapper
{
	static __New := Func("TI_AbstractClassConstructor")

	#include TI_WrapperBaseClass.ahk
	#Include TI_ConstantMemberWrapperBaseClass.ahk

	#include TI_CoClassWrapper.ahk
	#include TI_InterfaceWrapper.ahk
	#include TI_EnumWrapper.ahk
	#include TI_StructureWrapper.ahk
	#include TI_ModuleWrapper.ahk

	#include TI_TypeLibWrapper.ahk
}