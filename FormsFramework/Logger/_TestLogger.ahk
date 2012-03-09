#SingleInstance force

	Gui, +LastFound
	hGui := WinExist()
	w := 500,  h := 400

	Gui, Add, Button, gOnButton w130, Random
	Gui, Add, Button, gOnButton w130 x+2, Clear
	Gui, Add, Button, gOnButton w130 x+2, Browser
	Log_Add( hGui, 0, 40, w, h-40, "Log_onLink")

	Gui, show, w%w% h%h%

	Log_Info("Test Application Started")
	Log_Auto("Error in application")
	Log_Auto("Warning in application")
	Log_Auto("Some shit", "", "http://www.google.com/search?&q=someshit&btnG=Search")
	;Log_SetSaveFile("ouput.html")
return


F1::Test()

OnButton:
	if A_GuiControl = Random 
		 Test()
	if A_GuiControl = Clear
		Log_Clear()
	if A_GuiControl = Browser
		Log_OpenInBrowser()

return

ESC:: ExitApp

Log_onLink(Type, Id) {
	msgbox Properties for %type% %id%
}

Test(){
	static no=0
	loop 3
	{
		s =
		random, out, 1, 9
		random, lines, 1, 5

		no++

		loop, %lines%
			s .= RandomLen() A_Index  "`n2"
		s := SubStr(s, 1, -1)

		if out=1
			Log_Error(s)
		else if out=2
			Log_Warning(s)
		else Log_Info(s)
	}
}

RandomLen(){
	random, len, 1, 50
	loop, %len%
		l .= "Test "
	
	return l
}

#include ..
#include Logger.ahk