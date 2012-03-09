
#SingleInstance, force
	Gui, +LastFound
	hwnd := WinExist()
	GroupAdd, RichEditGrp, ahk_id %hwnd% 

	Gui, Font, s11 bold  , Tahoma
	Gui, Add, Text       , x10 y10 w300 HWNDhText
	Gui, Font, s10 Normal, Tahoma
	Gui, Add, Text       , x10 y30 w300 h40 HWNDhDesc
	Gui, Font, s8        , Tahoma
	Gui, Add, Edit       , x10 y80 w330 h110 HWNDhExample ReadOnly
	Gui, Font, s8        , Tahoma
	Gui, Add, Listview   , x5   y200 w180 h290 gOnLV AltSubmit, API|Desc
	Gui, Add, Text       , x195 y205 w150 h290 HWNDhNotifications, -- Notifications --`n`n

	apiPopulate()

	text = 
	(Ltrim
		http://www.google.com
		www.google.com

		meh...
	)
	hRichEdit := RichEdit_Add( hwnd, 355, 5, 445, 490, "")

	Gui, Show, w805 h500

	RichEdit_SetText(hRichEdit, "Document.rtf", "FROMFILE")
	RichEdit_SetEvents(hRichEdit, "Handler", "DRAGDROPDONE DROPFILES KEYEVENTS MOUSEEVENTS SCROLLEVENTS PROTECTED REQUESTRESIZE")
return


F1::

return

Handler(hCtrl, Event, p1, p2, p3 ) {
  global hNotifications
  
  If (Event = "DROPFILES")  {
    MsgBox, % "Dropped files: " P1 "`n----`n" P2 "`n----`nChar position: " P3
    return
  }

  ControlSetText,, -- Notifications --`n`nEvent = %Event% `np1 = %p1% `np2 = %p2% `np3 = %p3% `n%L%, ahk_id %hNotifications%
  IfEqual, Event, PROTECTED, return TRUE
}

^1::reload

OnLV:
  LV_GetText( api, LV_GetNext() ), LV_GetText( desc, LV_GetNext(), 2 )
  api=%api%   ; trim whitespace

  ; On select
  If ( A_GuiEvent = "I" ) {
  ControlSetText, , RichEdit_%api%(), ahk_id %hText%
  ControlSetText, , %desc%, ahk_id %hDesc%

  example := RegExReplace( demo, "miU`r)^.*\n" api ":(.*)?\n(.*\nreturn).*$", "$2" )
  StringReplace, example, example, `n,`r`n,All
  ControlSetText, , % example , ahk_id %hExample%
  }

  ; On doublclick
  If ( A_GuiEvent = "A" ) && ( api != "add" )  {
    GoSub, % api
    ControlFocus, , ahk_id %hRichEdit%
  }
return

apiPopulate()  {
  global demo

  FileRead, demo, % A_ScriptFullPath
  StringReplace, demo, demo, `r,,A
  StringReplace, demo, demo, MsgBox`,262144`,`,,MsgBox`,,A

  hImageList := IL_Create(1), LV_SetImageList(hImageList), IL_Add(hImageList, "shell32.dll", 132)
  pos = 1800
  Loop  {
    If pos := RegExMatch( demo, "Umi)\R(?P<Api>[\w]+):.*`;.*(?P<Desc>[\w].*)\R.*", m, pos )
		ifEqual, mDesc,, continue
		else LV_Add("Icon" (mDesc ? 0 : 1)," " mApi, (mDesc ? mDesc : "(not wrapped yet)") ),  pos+=StrLen(mApi)
    else break
  }
  LV_ModifyCol(1), LV_ModifyCol(2, 0), LV_Modify(1, "select")
}

;//////////////////////////////////////////////////////////////////





  Find:

  return


  OnFind(Event, Flags, FindWhat, ReplaceWith)
  {
    MsgBox, % Event "`n2-" Flags "`n3-" FindWhat "`n4-" ReplaceWith

  }

  EM_SETWORDBREAKPROC:    ; WIP!
    EM_SETWORDBREAKPROC( hRichEdit )
  return
  ;---





Add:   ; Add rich edit control to an AHK gui.
  Gui, +LastFound
  hwnd := WinExist()
  hRichEdit := RichEdit_Add(hwnd, 5, 5, 200, 300)
  Gui, Show, w210 h310
return
;---
AutoUrlDetect:  ; Enable disable or toggle automatic detection of URLs by a rich edit control.
  state := RichEdit_AutoUrlDetect( hRichEdit )
  MsgBox,262144,, % "url detect = " state
  
  state := RichEdit_AutoUrlDetect( hRichEdit, "^" )
  MsgBox,262144,, % "url detect = " state
return
;---
CANPASTE:
;   RichEdit_CANPASTE( hRichEdit )
return
;---
DISPLAYBAND:
;   RichEdit_DISPLAYBAND( hRichEdit )
  EM_DISPLAYBAND( hRichEdit )
return
;---
FINDTEXT:
;   RichEdit_FINDTEXT( hRichEdit )
return
;---
FINDTEXTEX:
;   RichEdit_FINDTEXTEX( hRichEdit )
return
;---
FINDTEXTEXW:
;   RichEdit_FINDTEXTEXW( hRichEdit )
return
;---
FINDTEXTW:
;   RichEdit_FINDTEXTW( hRichEdit )
return
;---
FINDWORDBREAK:
;   RichEdit_FINDWORDBREAK( hRichEdit )
return
;---
FORMATRANGE:
;   RichEdit_FORMATRANGE( hRichEdit )
  EM_FORMATRANGE( hRichEdit )
return
;---
GETAUTOURLDETECT:
;   RichEdit_GETAUTOURLDETECT( hRichEdit )
return
;---
GETBIDIOPTIONS:
;   RichEdit_GETBIDIOPTIONS( hRichEdit )
  EM_GETBIDIOPTIONS( hRichEdit )
return
;---
GetCharFormat:  ; Get or set the current text mode of a rich edit control.
  RichEdit_GetCharFormat(hRichEdit, face, style, color)
  MsgBox, Face = %Face% `nstyle = %style%  `ncolor = %color%
return
;---
GETCTFMODEBIAS:
;   RichEdit_GETCTFMODEBIAS( hRichEdit )
  EM_GETCTFMODEBIAS( hRichEdit )
return
;---
GETCTFOPENSTATUS:
;   RichEdit_GETCTFOPENSTATUS( hRichEdit )
  EM_GETCTFOPENSTATUS( hRichEdit )
return
;---
GETEDITSTYLE:
;   RichEdit_GETEDITSTYLE( hRichEdit )
  EM_GETEDITSTYLE( hRichEdit )
return
;---
GETEVENTMASK:
;   RichEdit_GETEVENTMASK( hRichEdit )
  EM_GETEVENTMASK( hRichEdit )
return
;---
GETHYPHENATEINFO:
;   RichEdit_GETHYPHENATEINFO( hRichEdit )
  EM_GETHYPHENATEINFO( hRichEdit )
return
;---
GETIMECOLOR:
;   RichEdit_GETIMECOLOR( hRichEdit )
return
;---
GETIMECOMPMODE:
;   RichEdit_GETIMECOMPMODE( hRichEdit )
  EM_GETIMECOMPMODE( hRichEdit )
return
;---
GETIMECOMPTEXT:
;   RichEdit_GETIMECOMPTEXT( hRichEdit )
return
;---
GETIMEMODEBIAS:
;   RichEdit_GETIMEMODEBIAS( hRichEdit )
  EM_GETIMEMODEBIAS( hRichEdit )
return
;---
GETIMEOPTIONS:
;   RichEdit_GETIMEOPTIONS( hRichEdit )
return
;---
GETIMEPROPERTY:
;   RichEdit_GETIMEPROPERTY( hRichEdit )
return
;---
GETLANGOPTIONS:
;   RichEdit_GETLANGOPTIONS( hRichEdit )
return
;---
GETOPTIONS:
;   RichEdit_GETOPTIONS( hRichEdit )
  EM_GETOPTIONS( hRichEdit )
return
;---
GETPAGEROTATE:
;   RichEdit_GETPAGEROTATE( hRichEdit )
  EM_GETPAGEROTATE( hRichEdit )
return
;---
GETPARAFORMAT:
;   RichEdit_GETPARAFORMAT( hRichEdit )
  EM_GETPARAFORMAT( hRichEdit )
return
;---
GETPUNCTUATION:
;   RichEdit_GETPUNCTUATION( hRichEdit )
  em_GETPUNCTUATION( hRichEdit )
return
;---
GetRedo:  ; Determine whether there are any actions in the control redo queue && optionally retrieve the type.
  If RichEdit_GetRedo( hRichEdit, type )
    MsgBox,262144,, The next redo is a %type% operation
  Else
    MsgBox,262144,, Nothing left to redo.
return
;---
GetSel:   ; Retrieve start/end character positions of selection, && return the total count of selection.
  If !RichEdit_GetSel( hRichEdit ) {
    MsgBox,262144,, No characters selected.
    return
  }
  count := RichEdit_GetSel( hRichEdit, min, max )
  MsgBox,,%count%, %min%-%max%
return
;---
GetTextLength:  ; Calculates text length in various ways.
  MsgBox, % RichEdit_GetTextLength( hRichEdit )

  MsgBox, % RichEdit_GetTextLength( hRichEdit, "close" )
return
;---
GetText: ; Retrieves a specified range of characters from a rich edit control.
  MsgBox,262144,, % RichEdit_GetText( hRichEdit ) ; get selection

  MsgBox,262144,, % RichEdit_GetText( hRichEdit, 4, 10 ) ; get range

  MsgBox,262144,, % RichEdit_GetText( hRichEdit, 0, -1 ) ; get all
return
;---
GETTYPOGRAPHYOPTIONS:
;   RichEdit_GETTYPOGRAPHYOPTIONS( hRichEdit )
return
;---
GetUndo:  ; Determine whether there are any actions in the control undo queue && optionally retrieve the type.
  If RichEdit_GetUndo( hRichEdit, type )
    MsgBox,262144,, The next undo is a %type% operation
  Else
    MsgBox,262144,, Nothing left to undo.
return
;---
GETWORDBREAKPROCEX:
;   RichEdit_GETWORDBREAKPROCEX( hRichEdit )
return
;---
HIDESELECTION:
;   RichEdit_HIDESELECTION( hRichEdit )

EM_HIDESELECTION(hRichEdit, true)
; EM_HIDESELECTION(hRichEdit, false)
return
;---
ISIME:
;   RichEdit_ISIME( hRichEdit )
return
;---
LimitText:  ; Sets an upper limit to the amount of text the user can type or paste into a rich edit control.
  RichEdit_LimitText( hRichEdit, 10 )
return
;---
LineFromChar:   ; Determines which line contains the specified character in a rich edit control.
  MsgBox,262144,, % RichEdit_LineFromChar( hRichEdit, 10 )
  
  RichEdit_GetSel( hRichEdit, min )
  MsgBox,262144,, % "you are on line "
                  . RichEdit_LineFromChar( hRichEdit, min )+1
return
;---
OleInterface:   ; !!WIP!! Mixture of EM_GETOLEINTERFACE && EM_SETOLECALLBACK to access COM functionality.
  ; not yet...
return
;---
PASTESPECIAL:
;   RichEdit_PASTESPECIAL( hRichEdit )
return
;---
RECONVERSION:
;   RichEdit_RECONVERSION( hRichEdit )
  EM_RECONVERSION( hRichEdit )
return
;---
Redo:   ; Send message to rich edit control to redo the next action in the control's redo queue.
  RichEdit_Redo( hRichEdit )
return
;---
REQUESTRESIZE:
;   RichEdit_REQUESTRESIZE( hRichEdit )
return
;---
ScrollPos:  ; Obtain the current scroll position, or tell the rich edit control to scroll to a particular point.
  MsgBox,262144,, % "pos = " RichEdit_ScrollPos( hRichEdit )

  RichEdit_ScrollPos( hRichEdit , "7/22" )
return
;---
SELECTIONTYPE:
;   RichEdit_SELECTIONTYPE( hRichEdit )
return
;---
SETBIDIOPTIONS:
;   RichEdit_SETBIDIOPTIONS( hRichEdit )
  EM_SETBIDIOPTIONS( hRichEdit )
return
;---
SetBkgndColor:  ; Sets the background color for a rich edit control.
  Dlg_Color( color, hRichEdit )
  RichEdit_SetBgColor( hRichEdit, color )
return
;---
SetCharFormat:  ; Set character formatting in a rich edit control.
  RichEdit_GetCharFormat(hRichEdit, face, style, color)
  If Dlg_Font(face, style, color, true, hwnd)
    RichEdit_SetCharFormat(hRichEdit, face, style, color)

;   Face  = Tahoma
;   style = bold italic underline s11 protected
;   color = 0x800000
;   RichEdit_SetCharFormat(hRichEdit, face, style, color)
return
;---
SETCTFMODEBIAS:
;   RichEdit_SETCTFMODEBIAS( hRichEdit )
return
;---
SETCTFOPENSTATUS:
;   RichEdit_SETCTFOPENSTATUS( hRichEdit )
  EM_SETCTFOPENSTATUS( hRichEdit )
return
;---
SETEDITSTYLE:
;   RichEdit_SETEDITSTYLE( hRichEdit )
return
;---
SetEvents: ; Set notification events.
  RichEdit_SetEvents(hRichEdit, "Handler", "SelChange")
return
;---
SETFONTSIZE:
;   RichEdit_SETFONTSIZE( hRichEdit )
return
;---
SETHYPHENATEINFO:
;   RichEdit_SETHYPHENATEINFO( hRichEdit )
return
;---
SETIMECOLOR:
;   RichEdit_SETIMECOLOR( hRichEdit )
return
;---
SETIMEMODEBIAS:
;   RichEdit_SETIMEMODEBIAS( hRichEdit )
return
;---
SETIMEOPTIONS:
;   RichEdit_SETIMEOPTIONS( hRichEdit )
return
;---
SETLANGOPTIONS:
;   RichEdit_SETLANGOPTIONS( hRichEdit )
return
;---
SETOPTIONS:
;   RichEdit_SETOPTIONS( hRichEdit )
return
;---
SETPAGEROTATE:
;   RichEdit_SETPAGEROTATE( hRichEdit )
return
;---
SETPALETTE:
;   RichEdit_SETPALETTE( hRichEdit )
return
;---
SETPARAFORMAT:
;   RichEdit_SETPARAFORMAT( hRichEdit )
return
;---
SETPUNCTUATION:
;   RichEdit_SETPUNCTUATION( hRichEdit )
  EM_SETPUNCTUATION( hRichEdit )
return
;---
SetSel:   ; Selects a range of characters or Component Object Model (COM) objects in a Rich Edit control.
  RichEdit_SetSel( hRichEdit, 4, 10 )

  Sleep, 3000
  RichEdit_SetSel( hRichEdit, 2 )
return
;---
SETTARGETDEVICE:
;   RichEdit_SETTARGETDEVICE( hRichEdit, 4 )
  EM_SETTARGETDEVICE( hRichEdit, 4 )
return
;---
SetText:   ; Set text from string or file in rich edit control using either rich text or plain text.
; FileSelectFile, file,,, Select file, RTF(*.rtf; *.txt)
; RichEdit_SetText(hRichEdit, file, "FROMFILE")

  RichEdit_SetText(hRichEdit, "insert..", "SELECTION" )
  Sleep, 3000

  RichEdit_SetText(hRichEdit, "replace..", "KEEPUNDO")
return
;---
SETTYPOGRAPHYOPTIONS:
;   RichEdit_SETTYPOGRAPHYOPTIONS( hRichEdit )
  em_SETTYPOGRAPHYOPTIONS( hRichEdit )
return
;---
SetUndoLimit:   ; Set the maximum number of actions that can stored in the undo queue. Default = 100
  MsgBox,262144,, % RichEdit_SetUndoLimit( hRichEdit, 5 )
return
;---
SETWORDBREAKPROCEX:
;   RichEdit_SETWORDBREAKPROCEX( hRichEdit )
return
;---
ShowScrollBar:    ; Shows or hides scroll bars for rich edit control.
  RichEdit_ShowScrollBar( hRichEdit, "VH", false )
  Sleep, 3000

  RichEdit_ShowScrollBar( hRichEdit, "V", true )
return
;---
STOPGROUPTYPING:
;   RichEdit_STOPGROUPTYPING( hRichEdit )
return
;---
STREAMIN:
;   RichEdit_STREAMIN( hRichEdit )
  EM_STREAMIn( hRichEdit )
return
;---
STREAMOUT:
;   RichEdit_STREAMOUT( hRichEdit )
  EM_STREAMOUT( hRichEdit, buffer )
  msgbox, % buffer
return
;---
TextMode:   ; Get or set the current text mode of a rich edit control.
  MsgBox,262144,, % "mode= " RichEdit_TextMode(hRichEdit)

; RichEdit_SetText(hRichEdit) ; empty control 1st

  If !RichEdit_TextMode( hRichEdit, "PLAINTEXT" )
    MsgBox,262144,, %errorlevel%
  Else
    MsgBox,262144,, % "new = " RichEdit_TextMode(hRichEdit)
return
;---
Undo:   ; Send message to rich edit control to undo the next action in the control's undo queue.
  RichEdit_Undo( hRichEdit )
;  RichEdit_Undo( hRichEdit, true ) ; reset undo queue
return
;---
Zoom:   ; Sets the zoom ratio anywhere between 1/64 and 64.
; msgbox, % "zoom ratio: " RichEdit_Zoom( hRichEdit )

  #MaxHotkeysPerInterval 200
  #IfWinActive ahk_group RichEditGrp
  ^WheelUp:: RichEdit_Zoom( hRichEdit, +1 )
  ^WheelDown:: RichEdit_Zoom( hRichEdit, -1 )
  #IfWinActive
return
;---



#Include ..\RichEdit.ahk
#Include ..\Todo.ahk
#include ..\..\Dlg\Dlg.ahk
