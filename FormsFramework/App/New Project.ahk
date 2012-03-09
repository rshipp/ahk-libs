$("My Application", "1.0")


App_Show() {
	global App_Name, App_Ver, App_Hwnd

	n := App_GetNextGui()
	Gui, %n%:+LastFound +LabelApp_
	App_Hwnd := WInExist()

    Gui, %n%:Show, x%gX% y%gY% w%gW% h%gH%, %App_Name% %App_Ver%
}