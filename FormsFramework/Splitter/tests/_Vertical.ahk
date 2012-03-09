;_("mo")
#SingleInstance, force

	;=========== SETUP ========
		w := 500
		h := 600
		sep := 20
	;==========================

	w1 := w//3, w2 := w-w1
	gui, margin, 0, 0
	Gui, +Resize

	gui, add, edit, HWNDhc1 w%w1% h%h%
	hSep := Splitter_Add( "blackframe x+0 h" h " w" sep)

	gui, add, monthcal, HWNDhc2 w%w2% h%h% x+0

	Splitter_Set( hSep, hc1 " | " hc2 )


	Attach(hc1, "h w")
	Attach(hc2, "x h")
	Attach(hSep,"x h")

	gui, show, w%w% h%h%
		
return

Esc:: 
GuiClose:
	ExitApp
return

#include ..\Splitter.ahk
#include ..\..\Attach\Attach.ahk
#include ..\..\Win\Win.ahk