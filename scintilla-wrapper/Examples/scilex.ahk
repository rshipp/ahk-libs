#include ../SCI.ahk
    
Gui +LastFound
hwnd:=WinExist()
hSci1:=SCI_Add(hwnd, x, y, w, h)
Gui, show, w400 h300
SCI_SetWrapMode(True)
SCI_SetText("test")
msgbox % SCI_GetText(5,myvar)
msgbox % myvar
return

GuiClose:
exitapp