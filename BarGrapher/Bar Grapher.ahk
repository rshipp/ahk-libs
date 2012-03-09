#NoEnv

/*
DataSet = %Clipboard% ;newline delimited list
StringReplace, DataSet, DataSet, `r,, All
*/
Loop, 40
{
 Random, Temp1, 1, 60
 DataSet .= Temp1 . "`n"
}
StringTrimRight, DataSet, DataSet, 1

Plot(DataSet)
Gui, Show, w1000 h410
Return

Plot(ByRef DataSet,PosX = 0,PosY = 0)
{
 If RegExMatch(DataSet,"S)[^\n\d\.]")
  Return
 MaxMin(DataSet,Max,Min)
 MaxScale := RoundToNearest(Max,2,"Ceil")
 MinScale := RoundToNearest(Min,2,"Floor")

 Gui, Font, s14 Bold, Arial
 Gui, Add, Text, x%PosX% y%PosY% w1000 h30 Center, Integer Distribution

 StringReplace, DataSet, DataSet, `n, `n, UseErrorLevel
 FontSize := 9 - StrLen(Max)
 Gui, Font, s%FontSize% Norm

 AddBarGraph(1,45 + PosX,40 + PosY,950,300,MaxScale,MinScale)
 Index := 0, NumberRange := Max - Min
 Loop, Parse, DataSet, `n
 {
  If A_LoopField Is Not Number
   Continue
  SetFormat, IntegerFast, Hex
  Red := Round(((A_LoopField - Min) / NumberRange) * 0xFF)
  Blue := 0xFF - Red
  BarColor := SubStr("0" . SubStr(Red,3),-1) . "00" . SubStr("0" . SubStr(Blue,3),-1)
  SetFormat, IntegerFast, D
  Index ++, AddBar(1,A_LoopField,Index,BarColor)
 }
 RefreshBarSizes(1)
 AddVerticalScales(1)

 Variation := Round((NumberRange * 100) / (Min + (NumberRange / 2)),2)
 Gui, Font, s10 Bold
 Gui, Add, Text, % "x" . PosX . " y" . 380 + PosY . " w1000 h20 Center", Minimum: %Min%    Maximum: %Max%    Range: %NumberRange%    Variation: %Variation%`%
}

GuiClose:
ExitApp

MaxMin(ByRef NumberList,ByRef Max = "",ByRef Min = "",Delim = "`n")
{
 Max := SubStr(NumberList,1,InStr(NumberList,Delim) - 1), Min := Max
 Loop, Parse, NumberList, %Delim%
 {
  If A_LoopField Is Not Number
   Continue
  If A_LoopField > %Max%
   Max = %A_LoopField%
  If A_LoopField < %Min%
   Min = %A_LoopField%
 }
}

RoundToNearest(Num,RoundTo,Mode = "Floor") ;Floor, Round, Ceil
{
 Temp1 := Mod(Num,RoundTo), Temp2 := Num - Temp1, (Mode = "Round" && (Temp1 >= (RoundTo / 2))) ? Temp2 += RoundTo : ((Mode = "Ceil" && Temp1 <> 0) ? Temp2 += RoundTo)
 Return, Temp2
}

AddBarGraph(GuiNum,PosX,PosY,Width,Height,MaxScale = 100,MinScale = 0,BackgroundColor = "White")
{
 global
 BarGraphX := PosX, BarGraphY := PosY, BarGraphW := Width, BarGraphH := Height, BarGraphBorderSize := BorderSize, BarGraphBackgroundColor := BackgroundColor, BarGraphCount := 0, BarGraphMaxScale := MaxScale, BarGraphMinScale := MinScale
}

AddBar(GuiNum,BarLevel,BarLabel = "",BarColor = "Red")
{
 global
 BarGraphCount ++
 Gui, %GuiNum%:Add, Progress, Vertical Background%BarGraphBackgroundColor% c%BarColor% vBarGraphBar%BarGraphCount% Range%BarGraphMinScale%-%BarGraphMaxScale%, %BarLevel%
 Gui, %GuiNum%:Add, Text, Center vBarGraphLabel%BarGraphCount%, |`n%BarLabel%
}

RefreshBarSizes(GuiNum)
{
 global BarGraphX
 global BarGraphY
 global BarGraphW
 global BarGraphH
 global BarGraphCount
 BarWidth := BarGraphW / BarGraphCount
 Temp1 := BarGraphY + BarGraphH
 Loop, % BarGraphCount
 {
  Temp2 := BarGraphX + (BarWidth * (A_Index - 1))
  Temp3 := BarWidth + 2
  GuiControl, %GuiNum%:Move, BarGraphBar%A_Index%, x%Temp2% y%BarGraphY% w%Temp3% h%BarGraphH%
  Temp2 := (BarWidth * (A_Index - 1)) + BarGraphX
  GuiControl, %GuiNum%:Move, BarGraphLabel%A_Index%, x%Temp2% y%Temp1% w%BarWidth% h30
 }
 Gui, %GuiNum%:+LastFound
 WinSet, Redraw
}

AddVerticalScales(GuiNum,Interval = 20,Precision = 1)
{
 global BarGraphX
 global BarGraphY
 global BarGraphH
 global BarGraphMaxScale
 global BarGraphMinScale
 Temp1 := BarGraphH / Interval
 Temp2 := (BarGraphMaxScale - BarGraphMinScale) / Interval
 Loop, % Interval + 1
  Gui, Add, Text, % "x" . BarGraphX - 50 . " y" . (BarGraphY + (Temp1 * (A_Index - 1))) - 10 . " w45 h" . Temp1 . " Right", % Round(((Interval - (A_Index - 1)) * Temp2) + BarGraphMinScale,Precision) . " -"
}