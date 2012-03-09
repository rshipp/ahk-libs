#SingleInstance, off
SetBatchLines -1
SetWinDelay -1
SetControlDelay -1

	WM_MM_GETPORT  := 0x8001

	Gui, +LastFound
	hwnd := WinExist()

	Gui, Font, s12
	Gui, Add, Edit,  vMyEdit w300	, This message will be sent
	Gui, Font, s10
	Gui, Add, Button, x+0 w10	gOnSend		, Send
	Gui, Add, Button, xm		gOnMassive	, Massive Send
	Gui, Add, Button, x+80		gOnFind		, Find Host

	Gui, Show, w400 h80	, Client

	OnMessage(WM_MM_GETPORT, "OnPort")		;monitor Host response
return


;Send one message
OnSend:
 	Gui, Submit, NoHide
	ControlSetText, , %MyEdit%, ahk_id %port%
return

;Spam with messages to see if host drops some message
OnMassive:
	loop, 100
		ControlSetText, , %A_Index%, ahk_id %port%
return


;send GETPORT message to host. 
;Host responds with the same message passing port in wparam.
OnFind:
	port = 0										;reset port to 0 as 0 is invalid port
	PostMessage, WM_MM_GETPORT,hwnd,0,, Form1		;must be PostMessage, C# doesn't catch SendMessage here... ?
	Sleep 50	;wait a bit for response

	if port=0
		 Msgbox No host detected
	else msgbox Host detected. Now you can send messages.
	
return

; monitor for host response, just saves port to global variable
OnPort(wparam, lparam, msg, hwnd) {
	global port
	port := wparam
}