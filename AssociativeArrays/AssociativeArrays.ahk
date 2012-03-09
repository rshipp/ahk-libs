#NoEnv

ArrayPut(ByRef Array,Key,ByRef Data,DataLength)
{
 InStr("`n" . Array,"`n" . Key . "|") ? ArrayDelete(Array,Key)
 pDataCopy := DllCall("LocalAlloc","UInt",0,"UInt",DataLength)
 If Not pDataCopy
  Return, 1
 DllCall("RtlMoveMemory","UInt",pDataCopy,"UInt",&Data,"UInt",DataLength), Array .= Key . "|" . pDataCopy . "|" . DataLength . "`n"
}

ArrayGet(ByRef Array,Key,ByRef OutputVar,ByRef OutputVarLength = "")
{
 VarSetCapacity(OutputVar,64), VarSetCapacity(OutputVar,0), Temp1 := InStr("`n" . Array,"`n" . Key . "|")
 If Not Temp1
  Return, 1
 Temp1 += StrLen(Key) + 1, Temp2 := InStr(Array,"|",False,Temp1) + 1, OutputVarLength := SubStr(Array,Temp2,InStr(Array,"`n",False,Temp2) - Temp2), VarSetCapacity(OutputVar,OutputVarLength,13), DllCall("RtlMoveMemory","UInt",&OutputVar,"UInt",SubStr(Array,Temp1,(Temp2 - 1) - Temp1),"UInt",OutputVarLength)
}

ArrayDelete(ByRef Array,Key)
{
 Temp1 := InStr("`n" . Array,"`n" . Key . "|")
 If Not Temp1
  Return, 1
 Temp1 += StrLen(Key) + 1, Temp1 := SubStr(Array,Temp1,InStr(Array,"`n",False,Temp1) - Temp1), DllCall("LocalFree","UInt",SubStr(Temp1,1,InStr(Temp1,"|") - 1))
 StringReplace, Array, Array, %Key%|%Temp1%`n
}

ArrayClear(ByRef Array)
{
 If Not Array
  Return, 1
 StringTrimRight, Array, Array, 1
 Loop, Parse, Array, `n
  Temp1 := InStr(A_LoopField,"|") + 1, DllCall("LocalFree","UInt",SubStr(A_LoopField,Temp1,InStr(A_LoopField,"|",False,Temp1) - Temp1))
 Array = 
}
