#SingleInstance, off	;allow multiple instances

	target := "Script2"

	Gui, +LastFound	  +AlwaysOnTop
	hScript := WinExist()

	Gui, Font, s10
	Gui, Add, Edit,		 vMyMsg  w200		, AHK message to C#
	Gui, Add, Edit,  x+0 vMyPort w50, 100

	Gui, Font, s8
	Gui, Add, Button, x+5		gOnSend		, Send
	Gui, Add, Button, x+5		gOnMassive	, Massive

	Gui, Add, ListBox,xm	w350 h300 vMyLB,

	Gui, Show,	AutoSize

	IPC_OnMessage("OnMessage")
return

OnMessage:
	  GuiControl, , MyLB, %IPC_Port% : %IPC_Message%
return


OnSend:
	Gui, Submit, NoHide
	res := IPC_Send( WinExist( target ), MyMsg, MyPort)
	if res = FAIL
		MsgBox Sending failed
return

OnMassive:
	Gui, Submit, NoHide
	h := WinExist( target )
	if h = 0
		MsgBox Host doesn't exist

	loop, 100
	   IPC_Send(h, MyMsg " : " A_Index, MyPort)
return

#include ..\ipc\IPC.ahk