_("e2 d")
	goto MakeGui
return

MakeGui:
	no++

	Gui, %no%:Margin, 0, 0
	Gui, %no%:+Resize +LastFound
	hGui := WinExist(),  %hGui% := no

	Gui, %no%:Add, Edit, HWNDhe1%no% w150 h100 -tabstop, F1 - new Gui `nF2 - hide ctrl`nF3 - show ctrl`nF4 - ctrl left `nF5 - ctrl right `nESC - exit script
	Gui, %no%:Add, Picture, HWNDhe2%no% w100 x+0 h100, ..\_res\pic.png

	Gui, %no%:Add, Edit, HWNDhe3%no% w100 xm h100
	Gui, %no%:Add, Edit, HWNDhe4%no% w100 x+0 h100
	Gui, %no%:Add, Edit, HWNDhe5%no% w100 yp x+0 h100

	Pin( hGui )
	Gui, %no%:Show, Autosize
	Randomize(no)
return

Pin( hParent ) {
	WinGet, c, ControlListHWND, ahk_id %hParent%
	loop, parse, c, `n
		Attach(A_LoopField, "p r2")
}

F1::
	gosub MakeGui
return

F2::
	h := WinExist("A"), h := "he1" %h%, h := %h%
	WinHide, ahk_id %h%
	Attach(h, "-")
return

F3::
	h := WinExist("A"),	h := "he1" %h%, h := %h%
	Attach(h, "+")
	WinShow, ahk_id %h%
return

F4::
	h := WinExist("A"), n := %h%
	Win_MoveDelta(he1%n%, "", "", -50)
	Win_MoveDelta(he2%n%, -50, "", 50)
	Win_Redraw(he2%n%)
	Attach(h)   ;reset Gui with handle h, use Attach() if you have only 1 Gui
return

F5::
	h := WinExist("A"), n := %h%
	Win_MoveDelta(he1%n%, "", "", 50)
	Win_MoveDelta(he2%n%, 50, "", -50)
	Win_Redraw(he2%n%)
	Attach(h)   ;reset
return

Randomize(no){
	ifEqual, no, 1, return

	Random, w, 100, 800
	Random, h, 100, 800
	Random, x, 0, A_ScreenWidth - w - 10
	Random, y, 0, A_ScreenHeight - h - 10
	Gui, %no%:Show, x%x% y%y% w%w% h%h%, No: %no%
}

#include ..\..\inc
#include _Forms.ahk