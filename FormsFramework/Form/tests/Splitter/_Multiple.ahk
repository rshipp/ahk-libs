;_("mo!")
#SingleInstance, force

	;=========== SETUP ========
		w := 800
		h := 600
		sep := 8
	;==========================

	w1 := w//3, w2 := w-w1 , h1 := h // 2, h2 := h // 3
	gui, margin, 0, 0
	Gui, +Resize

	gui, add, edit, HWNDc11 w%w1% h%h1%
	hSepH := Splitter_Add( "x5 y5 w" w1 " h" sep )
	h1-=10
	gui, add, edit, HWNDc12 w%w1% h%h1%, F1 toggle ver splitter off, F2 toggle on


	hSepV := Splitter_Add( "x+0 y0 h" h " w" sep )
	gui, add, monthcal, HWNDc21 w%w2% h%h2% x+0
	gui, add, ListView, HWNDc22 w%w2% h%h2%, c1|c2|c3
	gui, add, ListBox, HWNDc23 w%w2% h%h2% , 1|2|3

	sdef = %c11% %hSepH% %c12% | %c21% %c22% %c23%
	Splitter_Set( hSepV, sdef )

	sdef2 = %c11% - %c12%
	Splitter_Set( hSepH, sdef2 )

	Attach(c11,  "h.5")
	Attach(hSepH,"y.5")
	Attach(c12,  "y.5 h.5")
	Attach(hSepV,"h")
	Attach(c21,  "w h.5")
	Attach(c22,  "y.5 h.5 w")
	Attach(c23,  "y w")

	gui, show, w%w% h%h%
		
return


F1::
	Splitter_Set(hSepV, "off")
return

F2::
	Splitter_Set(hSepV, "on")
return

GuiEscape: 
GuiClose:
	ExitApp
return

#include ..\..\inc
#include _Forms.ahk