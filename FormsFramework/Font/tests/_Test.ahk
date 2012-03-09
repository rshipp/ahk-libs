#SingleInstance, force

	;============================
	text := "Some dummy text"
	font := "s32, Courier New"
	;============================

	Gui, Add, Edit, HWNDh, %text%
	hFont := Font(h, font)									;create font, store its handle in hFont and apply it to control h.
	
	size := Font_DrawText(text, "", hFont, "CALCRECT")		;measure the text, use already created font
	StringSplit, size, size, .
	width := size1 + 8,	height := size2 + 8  				;include control border

	Gui, Add, Edit, HWNDh y+50 w%width% h%height% -wrap -vscroll,%text%
	Font(h, hFont)											;set already existing font.

	Gui, Add, Edit, HWNDh y+50 h%height% -vscroll,%text%
	Font(h, hFont)											

	Gui, Show, autosize
return

GuiClose:
GuiEscape:
  ExitApp
return

#include ..\Font.ahk