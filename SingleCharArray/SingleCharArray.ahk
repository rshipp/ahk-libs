#NoEnv

/*
NegativeCells = mlkjihgfedcba
PositiveCells = nopqrstuvwxyz
Loop, Parse, NegativeCells
 CellPut(A_Index - 1,A_LoopField)
DefaultCell = 0
CellPut(10,"a")
MsgBox "%NegativeCells%" "%PositiveCells%"
*/

CellGet(Index)
{
 global NegativeCells
 global PositiveCells
 global DefaultCell
 Temp1 := (Index < 0) ? SubStr(NegativeCells,Abs(Index),1) : SubStr(PositiveCells,Index + 1,1), (Temp1 = "") ? Temp1 := DefaultCell
 Return, Temp1
}

CellPut(Index,Char)
{
 global NegativeCells
 global PositiveCells
 global DefaultCell
 % (Index < 0) ? (Temp1 := Abs(Index), Temp2 := StrLen(NegativeCells), (Temp2 < Temp1) ? (VarSetCapacity(Temp2,Temp1 - Temp2,Asc(DefaultCell)), NegativeCells .= Temp2) : "", NumPut(Asc(Char),NegativeCells,Temp1 - 1,"Char")) : (Temp2 := StrLen(PositiveCells), (Index >= Temp2) ? (VarSetCapacity(Temp2,(Index - Temp2) + 1,Asc(DefaultCell)), PositiveCells .= Temp2) : "", NumPut(Asc(Char),PositiveCells,Index,"Char"))
}
