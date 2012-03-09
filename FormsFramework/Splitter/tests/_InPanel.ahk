;_("mo! e")
#NoEnv
#SIngleInstance, force
	
	w := 500
	h := 500
	sep := 6
	;=========================

	Gui, +LastFound +Resize
	hGui := WinExist()+0
	Gui, Margin, 0, 0

	w1 := w//2 - sep//2,	h1 := h//2
	hP1 := Panel_Add(hGui, 50, 50, w, h1)
	hP2 := Panel_Add(hGUi, 50, h1+90, w, h1)
	
	gui, add, edit, HWNDhc11 w%w1% h%h1%
	hSep1 := Splitter_Add( "sunken x+0 h" h1 " w" sep )
	gui, add, MonthCal, HWNDhc12 w%w1% h%h1% x+0

	w2 := w, h2 := h1//2
	gui, add, edit, HWNDhc21 x0 y0 w%w2% h%h2%
	hSep2 := Splitter_Add( "sunken y+0 w" w2 " h" sep )
	gui, add, MonthCal, HWNDhc22 w%w2% h%h2%

	Win_SetParent(hc11, hp1), Win_SetParent(hc12, hp1),  Win_SetParent(hSep1, hp1)
	Win_SetParent(hc21, hp2), Win_SetParent(hc22, hp2) Win_SetParent(hSep2, hp2)
	
	Splitter_Set( hSep1, hc11 " | " hc12, "", 50.50), Splitter_Set( hSep2, hc21 " - " hc22 )

	Attach(hc11, "h")
	Attach(hc12, "w h")
	Attach(hSep1,"h")
	Attach(hP1, "p")

	w += 100, h+=100
	gui, show, w%w% h%h%
return

#include ..\Splitter.ahk

#include ..\..\Attach\Attach.ahk
#include ..\..\Win\Win.ahk
#include ..\..\Panel\Panel.ahk


ESC::
GuiClose:
	exitapp
return