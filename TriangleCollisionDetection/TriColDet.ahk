Triangle1X = 100
Triangle1Y = 100
Triangle2X = 300
Triangle2Y = 100
Triangle3X = 500
Triangle3Y = 400

hModule := DllCall("LoadLibrary","Str","gdiplus.dll")
VarSetCapacity(Temp1,16,0), NumPut(1,Temp1,0,"Char")
DllCall("gdiplus\GdiplusStartup","UInt*",pToken,"UInt",&Temp1,"UInt",0)
OnExit, ExitSub
Gui, -Caption +E0x80000 +LastFound +Owner
Gui, Show, w515 h515
hWnd := WinExist()
hDC := DllCall("GetDC","UInt",0)
VarSetCapacity(Temp1,40,0), NumPut(515,Temp1,4), NumPut(515,Temp1,8), NumPut(40,Temp1,0), NumPut(1,Temp1,12,"UShort"), NumPut(0,Temp1,16), NumPut(32,Temp1,14,"UShort")
hBitmap := DllCall("CreateDIBSection","UInt",hDC,"UInt",&Temp1,"UInt",0,"UInt",0,"UInt",0,"UInt",0)
DllCall("ReleaseDC","UInt",0,"UInt",hDC)
hDC := DllCall("CreateCompatibleDC","UInt",0)
DllCall("gdi32\SelectObject","UInt",hDC,"UInt",hBitmap)
DllCall("gdiplus\GdipCreateFromHDC","UInt",hDC,"UInt*",pGraphics)
DllCall("gdiplus\GdipSetSmoothingMode","UInt",pGraphics,"Int",4)
DllCall("gdiplus\GdipCreateSolidFill","Int",0xAA7777FF,"UInt*",pBrushTriangleFill)
DllCall("gdiplus\GdipCreateSolidFill","Int",0xFFCCCCFF,"UInt*",pBrushOverlay)
DllCall("gdiplus\GdipCreatePen1","Int",0xFFAAAAFF,"Float",5,"Int",2,"UInt*",pPenTriangleOutline)
DllCall("gdiplus\GdipCreatePen1","Int",0xFFCCCCFF,"Float",5,"Int",2,"UInt*",pPenOverlay)
Shape = %Triangle1X%,%Triangle1Y%|%Triangle2X%,%Triangle2Y%|%Triangle3X%,%Triangle3Y%|%Triangle1X%,%Triangle1X%
SetTimer, Moved, 100
Gosub, Moved
OnMessage(0x201,"DragWin")
Return

Moved:
MouseGetPos, PosX, PosY
Gui, +LastFound
IfWinNotActive
 Return
If (PosX = PosX1 && PosY = PosY1)
 Return
PosX1 := PosX, PosY1 := PosY
DllCall("gdiplus\GdipGraphicsClear","UInt",pGraphics,"Int",0xFFFFFF)
If PointInTriangle(Triangle1X,Triangle1Y,Triangle2X,Triangle2Y,Triangle3X,Triangle3Y,PosX,PosY)
 Gdip_FillPolygon(pGraphics,pBrushTriangleFill,Shape)
Gdip_DrawLines(pGraphics,pPenTriangleOutline,Shape)
DllCall("gdiplus\GdipDrawLine","UInt",pGraphics,"UInt",pPenOverlay,"Float",Triangle1X,"Float",Triangle1Y,"Float",PosX,"Float",PosY)
DllCall("gdiplus\GdipFillEllipse","UInt",pGraphics,"UInt",pBrushOverlay,"Float",Triangle1X - 5,"Float",Triangle1Y - 5,"Float",10,"Float",10)
DllCall("gdiplus\GdipFillEllipse","UInt",pGraphics,"UInt",pBrushOverlay,"Float",PosX - 5,"Float",PosY - 5,"Float",10,"Float",10)
DllCall("UpdateLayeredWindow","UInt",hWnd,"UInt",0,"UInt",0,"Int64*",0x20300000203,"UInt",hDC,"Int64*",0,"UInt",0,"UInt*",0x1FF0000,"UInt",2)
Return

GuiEscape:
GuiClose:
ExitApp

ExitSub:
DllCall("gdiplus\GdiplusShutdown","UInt",pToken)
DllCall("FreeLibrary","UInt",hModule)
ExitApp

DragWin()
{
 Gui, +LastFound
 PostMessage, 0xA1, 2
}

Gdip_FillPolygon(pGraphics,pBrush,Points,FillMode = 0)
{
 StringSplit, Points, Points, |
 VarSetCapacity(PointF,8 * Points0)
 Loop, %Points0%
 {
  StringSplit, Coord, Points%A_Index%, `,
  NumPut(Coord1,PointF,8 * (A_Index - 1),"Float"), NumPut(Coord2,PointF,(8 * (A_Index - 1)) + 4,"Float")
 }
 Return, DllCall("gdiplus\GdipFillPolygon","UInt",pGraphics,"UInt",pBrush,"UInt",&PointF,"Int",Points0,"Int",FillMode)
}

Gdip_DrawLines(pGraphics,pPen,Points)
{
 StringSplit, Points, Points, |
 VarSetCapacity(PointF,8 * Points0)
 Loop, %Points0%
 {
  StringSplit, Coord, Points%A_Index%, `,
  NumPut(Coord1,PointF,8 * (A_Index - 1),"Float"), NumPut(Coord2,PointF,(8 * (A_Index - 1)) + 4,"Float")
 }
 Return, DllCall("gdiplus\GdipDrawLines","UInt",pGraphics,"UInt",pPen,"UInt",&PointF,"Int",Points0)
}

PointInTriangle(Triangle1X,Triangle1Y,Triangle2X,Triangle2Y,Triangle3X,Triangle3Y,PointX,PointY)
{
 Temp1 := Triangle3X - Triangle1X, Temp2 := Triangle3Y - Triangle1Y, Temp3 := Triangle2X - Triangle1X, Temp4 := Triangle2Y - Triangle1Y, Temp5 := PointX - Triangle1X, Temp6 := PointY - Triangle1Y, Temp7 := (Temp1 ** 2) + (Temp2 ** 2), Temp8 := (Temp1 * Temp3) + (Temp2 * Temp4), Temp1 := (Temp1 * Temp5) + (Temp2 * Temp6), Temp2 := (Temp3 ** 2) + (Temp4 ** 2), Temp3 := (Temp3 * Temp5) + (Temp4 * Temp6), Temp4 := 1 / ((Temp7 * Temp2) - (Temp8 ** 2)), Temp5 := ((Temp2 * Temp1) - (Temp8 * Temp3)) * Temp4, Temp6 := ((Temp7 * Temp3) - (Temp8 * Temp1)) * Temp4
 Return, Temp5 > 0 && Temp6 > 0 && (Temp5 + Temp6) < 1
}
