#NoEnv

String = 20-31,50-70,32-78,87-99
MsgBox % RangeOverlap(String) ;result should be "50-70,32-78", as these ranges overlap

RangeOverlap(NumberWindows,EntryDelim = ",",ItemDelim = "-")
{
 Loop, Parse, NumberWindows, %EntryDelim%
 {
  StringSplit, Window, A_LoopField, %ItemDelim%
  A_Index1 := A_Index, A_LoopField1 := A_LoopField
  Loop, Parse, NumberWindows, %EntryDelim%
  {
   If A_Index = %A_Index1%
    Continue
   StringSplit, Temp, A_LoopField, %ItemDelim%
   If (Temp1 > Window1 && Temp1 < Window2 && Temp2 > Window1 && Temp2 < Window2)
    Conflicts .= A_LoopField . "`n" . A_LoopField1 . "`n"
  }
 }
 Return, SubStr(Conflicts,1,-1)
}
