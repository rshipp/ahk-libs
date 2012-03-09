#SingleInstance force
#NoEnv
   Gui, +LastFound
   hGui := WinExist() +0

   HLink_Add(hGui, 10,  10,  250, 20, "OnLink", "Click 'here':www.Google.com to go to Google" )
   HLink_Add(hGui, 10,  40,  250, 20, "OnLink", "Click 'this link':www.Yahoo.com to go to Yahoo")
   HLink_Add(hGui, 10,  170, 100, 20, "OnLink", "'About HLink':About")
   HLink_Add(hGui, 110, 170, 100, 20, "OnLink", "'Forum':http://www.autohotkey.com/forum/topic19508.html")
   HLink_Add(hGui, 10,	60,  100, 20 , "", "'Google':http://www.Google.com")
   Gui, Show, w300 h200
return

OnLink(hCtrl, Text, Link){
	if Link = About
		msgbox Hlink control`nby majkinetor
	else return 1

}

GuiEscape:
GuiClose:
	ExitApp
return

#include ..\..\inc
#include _Forms.ahk