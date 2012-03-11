/**************************************
	base classes
***************************************
*/

null := 0	; for better readability


/*
	Check for same (base) Type
*/
is(obj, type){
	
	if(IsObject(type))
		type := typeof(type)
	
	while(IsObject(obj)){
		
		if(obj.__Class == type){
			return true
		}
		obj := obj.base
	}
	return false
}

typeof(obj){
	if(IsObject(obj)){
		cls := obj.__Class
		
		if(cls != "")
			return cls
		
		while(IsObject(obj)){
			if(obj.__Class != ""){
				return obj.__Class
			}
			obj := obj.base
		}
		return "Object"
	}
	return "NonObject"
}

IsObjectMember(obj, memberStr){
	if(IsObject(obj)){
		return ObjHasKey(obj, memberStr) || IsMetaProperty(memberStr)
	}
}


IsMetaProperty(str){
	static metaProps := "__New,__Get,__Set,__Class"
	if str in %metaProps%
		return true
	else
		return false
}


/**
* Provides some common used Exception Templates
*
*/
class Exceptions
{
	NotImplemented(){
		return Exception("A not implemented Method was called.",-1)
	}
	
	MustOverride(){
		return Exception("This Method must be overriden",-1)
	}
	
	ArgumentException(furtherInfo=""){
		return Exception("A wrong Argument has been passed to this Method`n" furtherInfo,-1)
	}
}




;Base
{
	"".base.__Call := "Default__Warn"
	"".base.__Set  := "Default__Warn"
	"".base.__Get  := "Default__Warn"

	Default__Warn(nonobj, p1="", p2="", p3="", p4="")
	{
		ListLines
		MsgBox A non-object value was improperly invoked.`n`nSpecifically: %nonobj%
	}
}