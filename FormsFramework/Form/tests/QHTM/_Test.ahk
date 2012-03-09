#SingleInstance force
	Gui, +LastFound
	hGui := WinExist()
	w := 800,  h := 700

	hQhtm := QHTM_Add( hGui, 0, 0, w, h, "", "", "OnLink", "..\..\inc\qhtm.dll")
    QHTM_LoadFromFile(hQhtm, "Res\Welcome.html")
	QHTM_FormSetSubmitCallback(hQhtm, "OnForm")
	
	Gui, show, w%w% h%h%
return


OnForm(FormName, Method, FieldCount, Fields){
	Fields := "<table border=1>" RegExReplace(Fields, "`nm)^(\w+\b)(.+)$", "<tr><td>$1</td><td>$2</td></tr>") "</table>"
	qhtm_msgbox( Fields )
}


OnLink(Hwnd, Link, Id) {
	if InStr(Link, "http://")
		return 1

	if !InStr(Link, "Command")
		QHTM_LoadFromFile(Hwnd, "Res\" Link)

	if Link = COMMAND:ABOUT
	{
		FileRead, about, Res\about.html
		QHTM_MsgBox(about, "", "ICONEXCLAMATION")
	}
	
	If Link = COMMAND:MSGBOX
		QHTM_MsgBox("<b><font size=4>Remove flux capacitor?</font></b><p>Removing the flux capacitor during flight might lead to <b>overheating</b>,<br> <font color=""red"">toxi gas</font> exhaust, and some really unhappy passengers<p><b>Are you sure you wish to remove flux capacitor?</b><p>","", "YESNOCANCEL ICONEXCLAMATION" )
	
	if Link = COMMAND:TOOLTIP
	{
		Tooltip, <table> <tr> <td><img src="Res\Monkey.jpg"> </td><td> <b>Nice</b> tooltip! </td></tr></table>
		SetTimer, DisableTooltip, -2000
	}

	if Link = COMMAND:CONTROLS
		Controls()

	if Link = COMMAND:DIRWALK
		DirWalk()

	if Link = COMMAND:PROCESS
		Process()
}

Process()	{
	global hProc, cfatal
	static init

	if !init
	{
		Gui, 4:+LastFound +ToolWindow +AlwaysOnTop	
		Gui, 4:Color, FFFFFF
		Gui, 4:Add, Text, x5 y325, Find Fatal Error:
		Gui, 4:Add, Button, 0x8000 gprocBtn x+5 y320, First
		Gui, 4:Add, Button, 0x8000 gprocBtn x+15 y320, Prev 
		Gui, 4:Add, Button, 0x8000 gprocBtn x+0  y320, Next
		Gui, 4:Add, Text, x+70 y325, Proces:
		Gui, 4:Add, Button, 0x8000 gprocBtn x+5 y320, Stop
		Gui, 4:Add, Button, 0x8000 gprocBtn x+5 y320, Start

		hGui := WinExist()
		hProc := QHTM_Add( hGui, 0,0, 400, 300, "<h2>Log file:</h2>", "transparent")
		init := true, 	cfatal := 1
	}
	gui, 4:Show, w400 h350, %A_ThisFunc%
	SetTimer, OnProcess, 50
}

ProcBtn:
	if A_GuiControl = Stop
		SetTimer, OnProcess, off

	if A_GuiControl = Start
		SetTimer, OnProcess, 50

	if A_GuiControl = First
		QHTM_GotoLink(hProc, "Fatal1"), cfatal := 1

	if A_GuiControl = Prev
	{
		if cfatal > 1
			cfatal--
		QHTM_GotoLink(hProc, "Fatal" cfatal)
	}
	
	if A_GuiControl = Next
	{
		if (cfatal < idFatal)
			cFatal++
		QHTM_GotoLink(hProc, "Fatal" cfatal)
	}
return

OnProcess:
	Random, r, 1, 20

	time = %A_HOUR%:%A_MIN%:%A_SEC%


	if r = 1
		html = <br><font size=2 color=red> error messsage at %time%</font>
	else if r = 2
	{
		idFatal++
		html = <br><font size=3><b>Fatal application error %idFatal% at %time%.</font> <a name="Fatal%idFatal%" href="Details">Details</a></b>
	}
	else if r in 3, 5
		html = <BR> %time% Normal message 
	else if r = 4
		html = <BR><table><tr><td>Break time at %time%</td><td width=300><img align=right width=40 height=40 src="Res\Monkey.jpg"></td></tr></table> <HR>
	else return

	QHTM_AddHtml(hProc, html, 1)
return

Controls(){
	static init

	if !init
	{
		Gui, 3:+LastFound 
		Gui, 3:Add, Button, 0x8000 gOnBtn x0 w200 hwndhb1, <table> <tr> <td><img src="Res\Monkey.jpg"> </td><td> Click to try <b>HTML</b> ListBox! </td></tr></table>
		Gui, 3:Add, Button,  w130 h10 hwndhb2 x+5,  <table align=center> <tr> <td><img src='RES\a.gif' transparent-color='black'></td></tr><tr><td><font size=2><b>Animated Button</b></td></tr></table>
		QHTM_SetHTMLButton(hb1, true), QHTM_SetHTMLButton(hb2, true)
		init := true
	}
	gui, 3:Show, w350 h300, %A_ThisFunc%
}

OnBtn:
	Gui, 3:Add, ListBox, x0 w200 y100 h100 0x20 hwndhl,<i>italic</i>|<b>bold</b>|<u>underline</u>
	QHTM_SetHTMLListbox(hl)
return



DirWalk(){
	static init

	if !init
	{
		Gui, 2:+LastFound
		hGui := WinExist() + 0
		hQ := QHTM_Add( hGui, 0,0, 600, 500, DWHTML(), "", "OnDirWalk")
		init := true
	}
	gui, 2:Show, w600 h500, %A_ThisFunc%
}

DWHTML(dir=""){
	cmd = cmd.exe /c dir /OG "%dir%" > Res\out.txt
	RunWait, %cmd%, , hide
	FileRead, dir, Res\out.txt
	dir := RegExReplace( dir, "`am)^.+[ ]\.$" )
	return "<pre>" RegExReplace( dir, "\<DIR\>(\s*)(.+)", "[DIR]$1<a href=""$2"">$2</a><BR>") "</pre>"
}

OnDirWalk(Hwnd, Link, Id){
	static c_dir
	c_dir .= Link "\", 	h := DWHTML(c_dir)
	ControlSetText, , %h%, ahk_id %Hwnd%
}

DisableTooltip:
	Tooltip
return

GuiClose: 
	ExitApp, 
return

#include ..\..\inc
#include _Forms.ahk