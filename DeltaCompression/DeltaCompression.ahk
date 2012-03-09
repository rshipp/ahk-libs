#NoEnv

/*
String1 = Bla Bla Bla Bla Blaaa
String2 = Bla Bla Bla Bla Bla Bla
MultiChar = ``
Temp1 := DeltaCompress(String1,String2,MultiChar)
MsgBox % Temp1
MsgBox % DeltaDecompress(String1,Temp1,MultiChar)
*/

DeltaCompress(String1,String2,MultiChar)
{
 Temp2 = 0
 Loop, Parse, String1
  Temp1 := SubStr(String2,A_Index,1), (Temp1 = A_LoopField) ? (Compressed .= MultiChar, Temp2 ++) : (Compressed .= Temp1, ShortList .= Temp2 . "`n", Temp2 := 0)
 Sort, ShortList, N R U
 Compressed .= SubStr(String2,StrLen(String1) + 1), VarSetCapacity(Temp1,SubStr(ShortList,1,InStr(ShortList,"`n") - 1),Asc(MultiChar)), ShortList := SubStr(ShortList,1,-1)
 Loop, Parse, ShortList, `n
  StringReplace, Compressed, Compressed, % SubStr(Temp1,1,A_LoopField), %MultiChar%%A_LoopField%%MultiChar%, All
 Return, Compressed
}

DeltaDecompress(String1,Compressed,MultiChar)
{
 While, ((Temp1 := InStr(Compressed,MultiChar) + 1) <> 1, Temp2 := SubStr(Compressed,Temp1,InStr(Compressed,MultiChar,False,Temp1) - Temp1))
  StringReplace, Compressed, Compressed, %MultiChar%%Temp2%%MultiChar%, % SubStr(String1,Temp1 - 1,Temp2)
 Return, Compressed
}
