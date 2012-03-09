#include %A_ScriptDir%
;~ #include Structn.ahk
#include <_Struct>
SUCCESS(SUCCESS,TEXT){
	Return (SUCCESS?"SUCCESS":"FAIL") "`t`t" TEXT "`n"
}
MyStructure:="UInt a, Uint b" ;used below

/*-------------- GET + SET VALUE/POINTER/STRUCTURE -------------
	GET VALUE
		Uint v			struct.v					
		*Uint v			NumGet(Struct.v[])
		*MyStruct v		struct.v.item
	GET POINTER
		Uint v			struct.v[""]
		*Uint v			struct.v[]
		MyStruct v		struct[]
		*MyStruct v		struct.v[]
	SET VALUE
		Uint v			struct.v := value
		*Uint v			NumPut(value struct.v[],...)
		MyStruct v		struct.v.item := value
		*MyStruct v		struct.v.item := value
	SET POINTER
		Uint v			struct[] := pointer
		*Uint v			struct.v[] := pointer
		*MyStruct v		struct.v[] := pointer
*/ ;----------------------------------------------

; GENERAL USAGE
	; DEFAULT TYPES
		; CREATE STRUCTURE
			struct := new _Struct("INT64")
		; SET VALUE
			NumPut(1000,struct[""],0,"INT64")
		; GET VALUE
			RESULT .= SUCCESS(NumGet(struct[""],0,"INT64")=1000,"INT64")
	; SIMPLE STRUCTURE USAGE
		; CREATE STRUCTURE
			struct := new _Struct("int x,int y")
		; SET VALUE
			struct.x := 100 , struct.y := 200
		; GET VALUE
			RESULT .= SUCCESS(struct.x=100 && struct.y=200,"Int x,Int y")
	; PREDEFINED STRUCTURES
		; DEFINE STRUCTURE
			MyStruct:="int x,int y"
		; CREATE STRUCTURE
			struct := new _Struct(MyStruct) ; can be new _Struct("MyStruct") to be able to call from non global functions
		; SET VALUE
			struct.x := 300 , struct.y := 400
		; GET VALUE
			RESULT .= SUCCESS(struct.x=300 && struct.y = 400,"MyStruct : int x,int y")
; POINTER USAGE
	; DEFAULT TYPE POINTER
		; CREATE STRUCTURE
			struct := new _Struct("INT64*")
		; SET MEMORY TO WHICH IT WILL POINT
			VarSetCapacity(mem,8)
		; SET MAIN POINTER (NOTE, HERE [] INSTEAD OF [""] MUST BE USED !!! FOR ITEMS OF STRUCTURES USE [""] ALWAYS !!!)
			struct[]:=&mem
		; SET VALUE
			NumPut(600,struct[""],0,"INT64")
		; GET VALUE
			RESULT .= SUCCESS(NumGet(struct[""],0,"INT64")=600 && struct[""] = &mem,"INT64*")
	; DEFAULT TYPE POINTER USING AN ITEM IN STRUCTURE
		; CREATE STRUCTURE
			struct := new _Struct("INT64* i")
		; SET MEMORY TO WHICH IT WILL POINT
			VarSetCapacity(mem,8)
		; SET ITEM POINTER (NOTE, HERE [""] INSTEAD OF [] MUST BE USED !!! TO SET POINTER FOR MAIN STRUCTURE USE [] !!!)
			struct.i[""]:=&mem
		; SET VALUE
			NumPut(600,struct.i[""],0,"INT64")
		; GET VALUE
			RESULT .= SUCCESS(NumGet(struct.i[""],0,"INT64")=600 && struct.i[""] = &mem, "INT64* i")
	; POINTER TO USER DEFINED STRUCTURE
		; DEFINE STRUCTURE
			MyStruct:="int x,int y"
		; SET MEMORY TO WHICH IT WILL POINT
			VarSetCapacity(mem,8)
		; CREATE STRUCTURE
			struct := new _Struct("MyStruct*")
		; SET POINTER (NUMPUT NEEDS TO BE USED BECAUSE THERE ARE NO ITEMS TO ACCESS THE POINTER
			NumPut(&mem,struct[""],0,"PTR")
		; SET VALUE
			struct.x := 100 , struct.y := 200
		; GET VALUE
			RESULT .= SUCCESS(struct.x=100 && struct.y = 200,"MyStruct*")
	; POINTER TO USER DEFINED STRUCTURE USING AN ITEM IN STRUCTURE
		; DEFINE STRUCTURE
			MyStruct:="int x,int y"
		; SET MEMORY TO WHICH IT WILL POINT
			VarSetCapacity(mem,8)
		; CREATE STRUCTURE
			struct := new _Struct("MyStruct* m")
		; SET POINTER (HERE NO NUMPUT IS REQUIRED)
			struct.m[""] := &mem
		; SET VALUE
			struct.m.x := 300 , struct.m.y := 400
		; GET VALUE
			RESULT .= SUCCESS(struct.m.x = 300 && struct.m.y = 400,"MyStruct* m")
; POINTER TO POINTER USAGE
	; DEFAULT TYPE POINTER
		; CREATE STRUCTURE
			struct := new _Struct("INT64**")
		; SET MEMORY TO WHICH A POINTER IT WILL POINT, OUR STRUCTURE WILL POINT TO THAT POINTER
			VarSetCapacity(mem,8),NumPut(100,mem),VarSetCapacity(ptr,A_PtrSize),NumPut(&mem,ptr,0,"ptr")
		; SET MAIN POINTER (NOTE, HERE [] INSTEAD OF [""] MUST BE USED !!! FOR ITEMS OF STRUCTURES USE [""] ALWAYS !!!)
			struct[]:=&ptr
		; SET VALUE
			NumPut(600,NumGet(struct[""],0,"Ptr"),0,"INT64")
		; GET VALUE
			RESULT .= SUCCESS(struct[""]=&ptr && NumGet(struct[""],0,"INT64") = &mem && NumGet(NumGet(Struct[""],0,"ptr"))=600,"INT64**")
	; DEFAULT TYPE POINTER USING AN ITEM IN STRUCTURE
		; CREATE STRUCTURE
			struct := new _Struct("INT64** i")
		; SET MEMORY TO WHICH IT WILL POINT
			VarSetCapacity(mem,8)
		; SET ITEM POINTER (NOTE, HERE [""] INSTEAD OF [] MUST BE USED !!! TO SET POINTER FOR MAIN STRUCTURE USE [] !!!)
			struct.i[""]:=&mem
		; SET VALUE
			NumPut(600,struct.i[""],0,"INT64")
		; GET VALUE
			RESULT .= SUCCESS(NumGet(struct.i[""],0,"INT64")=600 && struct.i[""] = &mem,"INT64** i")
	; POINTER TO USER DEFINED STRUCTURE
		; DEFINE STRUCTURE
			MyStruct:="int x,int y"
		; SET MEMORY TO WHICH IT WILL POINT
			VarSetCapacity(mem,8)
		; CREATE STRUCTURE
			struct := new _Struct("MyStruct*")
		; SET POINTER (NUMPUT NEEDS TO BE USED BECAUSE THERE ARE NO ITEMS TO ACCESS THE POINTER
			;~ NumPut(&mem,struct[""],0,"PTR")
			struct[] := &ptr ;mem
		; SET VALUE
			struct.x := 100 , struct.y := 200
		; GET VALUE
			RESULT .= SUCCESS(struct.x=100 && struct.y=200,"MyStruct**")
	; POINTER TO USER DEFINED STRUCTURE USING AN ITEM IN STRUCTURE
		; DEFINE STRUCTURE
			MyStruct:="int x,int y"
		; SET MEMORY TO WHICH IT WILL POINT
			VarSetCapacity(mem,8)
		; CREATE STRUCTURE
			struct := new _Struct("MyStruct* m")
		; SET POINTER (HERE NO NUMPUT IS REQUIRED)
			struct.m[""] := &mem
		; SET VALUE
			struct.m.x := 300 , struct.m.y := 400
		; GET VALUE
			RESULT .= SUCCESS(struct.m.x=300 && struct.m.y=400,"MyStruct* m")
; SIMPLE UINT STRUCTURE
	; CREATE STRUCTURE
		S:=new _Struct("Uint i")
	; SET VALUE
		S.i:=1
	; GET VALUE
		RESULT .= SUCCESS(s.i=1 && s.i[""]=s[""], "Uint i")
	; SET POINTER (not available)
; POINTER TO UINT STRUCTURE
	; CREATE STRUCTURE
		S:=new _struct("UInt *i")
	; SET VALUE	(here internal memory will be used for value and pointer saved in structure)
		s.i:=100
	; GET VALUE
		RESULT .= SUCCESS(NumGet(s.i[""])=100 && s.i[""]=NumGet(s[""]), "Uint *i")
	; SET POINTER
		VarSetCapacity(v,4),NumPut(10,&v)
		s.i[""]:=&v
	; GET VALUE
		RESULT .= SUCCESS(NumGet(s.i[""])=10 && s.i[""]=NumGet(s[""]), "Uint *i new pointer")
; POINTER TO CUSTOM STRUCTURE
	; CREATE STRUCTURE
		MyStruct:="TCHAR i",S:=new _struct("MyStruct *v")
	; SET AND FILL MEMORY
		VarSetCapacity(mem,sizeof(MyStruct)*2),StrPut("AB",&mem)
	; SET POINTER
		s.v[""]:=&mem
	; SET VALUE
		s.v.2.i:="C"
	; GET VALUE
		RESULT .= SUCCESS(s.v.1.i="A" && s.v.2.i="C" && s.v[""]=&mem, "MyStruct *v")
; ANOTHER CUSTOM STRUCTURE
	; CREATE STRUCTURE
		Structure:="UInt a,UInt b",s:=new _Struct("Structure * s")
	; SET AND FILL MEMORY
		VarSetCapacity(v,16),NumPut(1,v),NumPut(2,v,4),NumPut(3,v,8),NumPut(4,v,12)
	; SET POINTER
		s.s[""]:=&v
	; GET VALUE
		RESULT .= SUCCESS(s.s.a=1 && s.s.2.b=4 && s.s[""]=&v, "Structure * s")
	; SET VALUE
		s.s.1.a:=10,s.s.b:=20,s.s.2.a:=30,s.s.2.b:=40
	; GET VALUE
		RESULT .= SUCCESS(s.s.a=10 && s.s.1.b=20 && s.s.2.a=30 && s.s.2.b=40, "Structure * s")

; ARRAYS OF POINTER
	; CREATE STRUCTURE
		struct:=new _Struct("MyStructure**")
	; SET AND FILL MEMORY
		VarSetCapacity(ptr,4*A_PtrSize) ;Pointers array
		VarSetCapacity(ptrptr,A_PtrSize) ;Pointer to Pointers
		NumPut(&ptr,ptrptr,0,"Ptr")
		Loop 4 ;build Structures and set pointers
			VarSetCapacity(ptr%A_Index%,8),NumPut(A_Index,ptr%A_Index%),NumPut(A_Index+1,ptr%A_Index%,4) ;,NumPut(3,v%A_Index%,8),NumPut(4,v%A_Index%,12)
			,NumPut(&ptr%A_Index%,ptr,(A_Index-1)*A_PtrSize,"ptr")
	; SET POINTER
		;~ NumPut(&ptr,struct[],0,"ptr")
		struct[] := &ptrptr ;assign pointer to structure
	; SET + GET VALUE
		struct.a:=9
		struct.2.b:=5
		RESULT .= SUCCESS(struct.a=9 && struct.2.b=5 && struct.2.a=2 && struct.a[""]=&ptr1, "MyStructure **")
; ARRAYS OF POINTER IN ITEM	
	; CREATE STRUCTURE
		struct:=new _Struct("MyStructure** s")	
	; SET POINTER
		struct.s[""]:=&ptr
	; SET + GET VALUE
		struct.s.2.b:=6
		RESULT .= SUCCESS(struct.s.a=9 && struct.s.2.b=6 && struct.s.2.a=2 && struct.s[""]=&ptr && struct.s.a[""]=&ptr1, "MyStructure ** s")
MsgBox % Result






