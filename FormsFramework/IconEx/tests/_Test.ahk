#Singleinstance, force
	cnt = 1
	Gui, Add, Picture, gOnColor y+20 x+10 w32 h32 vMyPic, %A_WinDir%\system32\shell32.dll
	Gui, Show, w400 h100, Click picture
return

OnColor:
	 res := IconEx("", "", "settings.ini")
	 j := InStr(res, ":", 0, 0), idx := 1
	 if j > 2
		idx := SubStr( res, j+1)+1, res := SubStr(res, 1, j-1)
	 ifEqual, res, , return

	 cnt++
  	 Gui, Add, Picture, gOnColor x+5  w32 h32 vMyPic%cnt% Icon%idx%, %res%
return


#Include ..\IconEx.ahk