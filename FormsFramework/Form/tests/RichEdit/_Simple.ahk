#SingleInstance, force
	Gui, +LastFound
	hGui := WinExist()

	;text created using WordPad

	hRichEdit := RichEdit_Add(hGui, 0, 0, 300, 200)
	RichEdit_FixKeys(hRichEdit)

	h := RichEdit_GetOleInterface(hRichEdit)

	Gui, Show, h200 w300
return

#include ..\..\inc
#include _Forms.ahk