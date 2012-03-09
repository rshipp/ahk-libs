comment &
 				 ------------------------------------------------------------------------
 				|HiEdit is a copyright of Antonis Kyprianou.                             |
 				|                                                                        |
 				|You can use HiEdit for NON commercial purposes provided you             |
 				|have the following information on your application's about box:         |
 				|HiEdit control is copyright of Antonis Kyprianou (http://www.winasm.net)|
 				|                                                                        |
 				|You need my written permission to use HiEdit in commercial applications |
 				 ------------------------------------------------------------------------
&

;HiEdit Header V4.0.0.4
;----------------------

;************************************
;Needed if static linking used
InitHiEditControl		PROTO
TerminateHiEditControl	PROTO
;*************************************


;---------Syntax Highlight-------------
SetKeywordFile			PROTO	:LPSTR
;*************************************



;--------------------------------------------------------------------------------------------
;Custom Window styles
HES_TABBEDBTOP			EQU 0001h			;Tabbed Inteface (HiEdit Top)
HES_TABBEDHRZSB			EQU 0002h			;Tabbed Inteface (On the horizontal scrollbar)
HES_TABBEDBOTTOM		EQU 0004h			;Tabbed Inteface (HiEdit Bottom) 

HES_HSCROLL				EQU 0008h			;Horizontal Scrollbar
HES_VSCROLL				EQU 0010h			;Vertical Scrollbar
HES_HILIGHT				EQU 0020h			;Syntax Hilight

HES_SINGLELINE			EQU 0040h			;Single line HiEdit control

HES_FILECHANGEALERT		EQU 0080h			;File Change Alert

;--------------------------------------------------------------------------------------------

FR_NOTNULLTERMINATED	EQU 00000008h		;used in fuFlags when sending the EM_FINDTEXT and EM_FINDTEXTEX messages

ENM_CONTEXTMENU			EQU 00000020h

;Custom notifications: 
EN_TABMCLICK			EQU 1000h			;When middle button clicked on HiTab control
EN_FILECHANGE			EQU	1001h			;When file state change

HESELCHANGE STRUCT
	nmhdr				NMHDR		<?>
	chrg				CHARRANGE	<?>		;Current selection
	seltyp				WORD		 ?		;SEL_TEXT or SEL_FILETAB
	LineNr				DWORD		 ?		;Current Line
	cpLine				DWORD		 ?		;Character position of first character of current line
	TextChanged			DWORD		 ?		;TRUE if text changed
HESELCHANGE ENDS

;seltyp constants:
;----------------
;SEL_TEXT				EQU 0001h			;Standard constant
SEL_FILETAB				EQU 0010h			;Custom constant: sent when current file tab changes.


HEFILECHANGE STRUCT
	nmhdr				NMHDR		<?>
	dwFileIndex			DWORD		 ?		;File Index
	dwChangeType		DWORD		 ?		;CHG_NOTAVAILABLE or CHG_MODIFIED or CHG_FILELOADING or CHG_FILELOADED
HEFILECHANGE ENDS

;dwChangeType constants:
;----------------------
CHG_NOTAVAILABLE		EQU 1				;File renamed, moved or deleted externally
CHG_MODIFIED			EQU 2				;File modified externally
CHG_FILELOADING			EQU 4				;File background loading in progress
CHG_FILELOADED			EQU 8				;File background loading finished

HECOLORS STRUCT
	TextColor				DWORD ?			;Text Color
	BackColor				DWORD ?			;Back Color
	SelTextColor			DWORD ?			;Selected Text Color
	ActSelBackColor			DWORD ?			;Active Selection Back Color
	InSelBackColor			DWORD ?			;Inactive Selection Back Color
	LineNumberColor			DWORD ?			;Line Numbers Color
	SelBarBackColor			DWORD ?			;Selection Bar Back Color
	NonPrintableBackColor	DWORD ?			;0 - 31 special non printable chars
	NumberColor				DWORD ?			;Number Color
HECOLORS ENDS


;-----------------------------------------------------------------------------------------------------------
;UNDONAMEID Enumerated Type
;The UNDONAMEID enumeration type contains values that indicate types of HiEdit control
;actions that can be undone or redone. The EM_GETREDONAME, EM_GETUNDONAME, HEM_GETUNDODATA and HEM_GETREDODATA  messages use this enumeration type to return a value.
;Standard operations
UID_UNKNOWN				EQU 0				;The type of undo action is unknown.
UID_TYPING				EQU 1				;Typing operation.
UID_DELETE				EQU 2				;Delete operation.
UID_DRAGDROP			EQU 3				;Drag-and-drop operation.
UID_CUT					EQU 4				;Cut operation.
UID_PASTE				EQU 5				;Paste operation.

;Extended Operations
UID_SETTEXT				EQU 6				;WM_SETTEXT message was used to set the control text
UID_REPLACESEL			EQU 7				;EM_REPLACESEL message was used to insert text
UID_CLEAR				EQU 8				;Delete selected text
UID_BACKSPACE			EQU 9				;Back Space Operation
UID_INDENT				EQU 10				;Increase Indent
UID_OUTDENT				EQU 11				;Decrease Indent
UID_CODEPAGE			EQU 12				;Convert codepage
UID_CASE				EQU 13				;Convert case
;-----------------------------------------------------------------------------------------------------------


UNDODATA STRUCT
	pszUndoText 		LPSTR ?				;Pointer to a null-terminated string that Receives the Undo text
	cchUndoTextMax		DWORD ?				;Size of the buffer pointed to by the pszUndoText member
UNDODATA ENDS

REDODATA STRUCT
	pszUndoText 		LPSTR ?				;Pointer to a null-terminated string that Receives the Redo text
	cchUndoTextMax		DWORD ?				;Size of the buffer pointed to by the pszUndoText member
REDODATA ENDS

;Constants for HEM_LINENUMBERSBAR message
LNB_HIDE				EQU 0
LNB_SHOW				EQU 1
LNB_AUTOMAXSIZE			EQU 2				;V3.0.1.1
LNB_AUTOSIZE			EQU 4


;Constants for HEM_CONVERTCHARSET message
CCP_OEM					EQU 0
CCP_ANSI				EQU 1

;Constants for HEM_CONVERTCHARSET message
CC_UPPERCASE			EQU 0
CC_LOWERCASE			EQU 1
CC_TOGGLECASE			EQU 2
CC_CAPITALIZE			EQU 3


;Custom Messages supported
;--------------------------
HEM_NEWFILE						EQU WM_USER+1000		;wParam=0,										lParam=0
HEM_OPENFILE					EQU WM_USER+1001		;wParam=TRUE/FALSE,								lParam=lpszFileName							:Returns TRUE if successful/FALSE otherwise
 														;TRUE:New file is created if it doesn't exist
 														;FALSE:Function fails if the file doesn't exist
HEM_CLOSEFILE					EQU WM_USER+1002		;wParam=0,										lParam = -2 to close ALL openned files/ or -1 for current file/  or dwFileIndex
HEM_RELOADFILE					EQU WM_USER+1003		;wParam=0,										lParam = -1 for current file
HEM_SAVEFILE					EQU WM_USER+1004		;wParam=lpszFileName,							lParam = -1 for current file or dwFileIndex	:Returns TRUE if successful/FALSE otherwise
HEM_GETFILECOUNT				EQU WM_USER+1005		;wParam=0,										lParam =0
HEM_GETFILENAME					EQU WM_USER+1006		;wParam=lpszFileName,							lParam = -1 for current file or dwFileIndex	:Returns TRUE if successful/FALSE otherwise
HEM_GETFILEITEMINDEXFROMPOINT	EQU WM_USER+1007		;wParam=lppt,									lParam = 0									:Returns File Item index if successful / -1 if above arrow buttons /-2 if above space after items
HEM_GETCURRENTFILE				EQU WM_USER+1008		;wParam=0,										lParam = 0
HEM_SETCURRENTFILE				EQU WM_USER+1009		;wParam=0,										lParam = dwFileIndex
HEM_GETFILEITEMSMODIFY			EQU WM_USER+1010		;wParam=0,										lParam = 0
HEM_SETFILEITEMSMODIFY			EQU WM_USER+1011		;wParam = fModified: modification flag			lParam = 0									:Returns: previous modification flag
HEM_LINENUMBERSBAR				EQU WM_USER+1012		;wParam=LNB_HIDE/LNB_SHOW/LNB_AUTOSIZE/LNB_AUTOMAXSIZE,			lParam=HIWORD:Selection bar width , LOWWORD:Line numbers width
HEM_SETCOLORS					EQU WM_USER+1013		;wParam=lpHCCOLORS,								lParam=fRedraw:TRUE/FALSE
HEM_GETCOLORS					EQU WM_USER+1014		;wParam=0,			 							lParam=lpHCCOLORS
HEM_GETUNDODATA					EQU WM_USER+1015		;wParam=Undo level (1 based),					lParam=lpUNDODATA	:Returns type of undo (UNDONAMEID)
HEM_GETREDODATA					EQU WM_USER+1016		;wParam=Undo level (1 based),					lParam=lpREDODATA	:Returns type of redo (UNDONAMEID)
HEM_SETTABWIDTH					EQU WM_USER+1017		;wParam=nChars,									lParam=fRedraw:TRUE/FALSE
HEM_AUTOINDENT					EQU WM_USER+1018		;wParam=0,										lParam=fAutoIndent:TRUE/FALSE
HEM_SETTABSIMAGELIST			EQU WM_USER+1019		;wParam=0,										lParam=hIml
HEM_SHOWFILELIST				EQU WM_USER+1020		;wParam=X pos,									lParam=Y pos
HEM_CONVERTCODEPAGE				EQU WM_USER+1021		;wParam=CCP_OEM/CCP_ANSI,						lParam = -1									:Returns TRUE if successful/FALSE otherwise
HEM_CONVERTCASE					EQU WM_USER+1022		;wParam=CC_UPPERCASE/CC_LOWERCASE/CC_TOGGLECASE,lParam = -1									:Returns TRUE if successful/FALSE otherwise
;HEM_ENSUREVISIBLE				EQU WM_USER+1023		;wParam=0,										lParam =  -1 for current file or dwFileIndex

;HEM_SETCOLUMNMODE				EQU WM_USER+1024		;wParam=fColumnMode:TRUE/FALSE,					lParam = -1
;HEM_GETCOLUMNMODE				EQU WM_USER+1025		;wParam=0,										lParam = -1 for current file

;HEM_SETBOOKMARK					EQU WM_USER+1026		;wParam=Line,	lParam=BookmarkType
;HEM_GETBOOKMARK					EQU WM_USER+1027		;wParam=Line,	lParam=0
;HEM_CLRBOOKMARKS				EQU WM_USER+1028		;wParam=0,		lParam=BookmarkType
;HEM_NXTBOOKMARK					EQU WM_USER+1029		;wParam=Line,	lParam=BookmarkType
;HEM_PRVBOOKMARK					EQU WM_USER+1030		;wParam=Line,	lParam=BookmarkType
;
;HEM_GETCURRENTLINENR			EQU WM_USER+1031		;wParam=0,		lParam=0

Comment $
STANDARD Windows and Edit/RichEdit control messages supported
-------------------------------------------------------------

WM_SETTEXT						EQU 0Ch
;If	wParam=0,			 	lParam=lpszText
;or wParam=number of bytes,	lParam=NOT null terminated string
Returns:TRUE if the text is set, FALSE otherwise

WM_GETTEXT						EQU 0Dh
wParam = (WPARAM) cchTextMax	:Specifies the maximum number of characters to be copied, including the terminating null character
lParam = (LPARAM) lpszText		:Points to the buffer that is to receive the text 
Returns: The number of characters copied. 

WM_GETTEXTLENGTH				EQU 0Eh 
wParam = 0						:Not used-must be zero 
lParam = 0						:Not used-must be zero 
Returns: The length, in characters, of the text. 

WM_SETFONT						EQU 30h
wParam = (WPARAM) hfont			:handle of font 
lParam = MAKELPARAM(fRedraw, 0)	:redraw flag 

EM_GETSEL						EQU 0B0h
wParam = lpdwStart				:starting position-can be NULL
lParam = lpdwEnd				:ending position-can be NULL
Returns: a zero-based 32-bit value with the starting position of the selection in the low-order word and the position of the first character after the last selected character in the high-order word. If either of these values exceeds 65, 535, the return value is -1.

EM_SETSEL						EQU 0B1h
wParam = nStart					:starting character position of the selection
lParam = nEnd					:ending character position of the selection
Returns: No return value.
Remarks: If the nStart parameter is 0 and the nEnd parameter is -1, all the text in the HiEdit control is selected. If nStart is -1, any current selection is removed. The caret is placed at the end of the selection indicated by the greater of the two values nEnd and nStart.
The application should use the EM_SCROLLCARET message to scroll the caret into view.

EM_GETRECT						EQU 0B2h
wParam = 0						:Not used-must be zero 
lParam = lprc					:Points to the RECT structure that receives the formatting rectangle. 
Returns: No return value.

EM_SCROLL						EQU 0B5h
wParam = nScroll
lParam = 0
nScroll:
SB_LINEDOWN	Scrolls down one line.
SB_LINEUP	Scrolls up one line.
SB_PAGEDOWN	Scrolls down one page.
SB_PAGEUP	Scrolls up one page.
Returns: The number of lines that the command scrolls. The number returned may not be the same as the actual number of lines scrolled if the scrolling moves to the beginning or the end of the text. If the nScroll parameter specifies an invalid value, the return value is FALSE.

EM_LINESCROLL					EQU 0B6h
wParam = cxScroll				:characters to scroll horizontally 
lParam = cyScroll				:lines to scroll vertically 
Returns TRUE 
Remarks
The HiEdit control does not scroll vertically past the last line of text in
the control. If the current line plus the number of lines specified by the
cyScroll parameter exceeds the total number of lines in the HiEdit control,
the value is adjusted so that the last line of the HiEdit control is scrolled
to the top of the HiEdit control window.
The EM_LINESCROLL message can be used to scroll horizontally past the last
character of any line.

EM_SCROLLCARET					EQU 0B7h
wParam = 0						:not used now-reserved for future use-must be zero 
lParam = 0						:not used now-reserved for future use-must be zero

EM_GETMODIFY					EQU 0B8h
wParam = 0						
lParam = -1 for current file, otherwise dwFileIndex
Returns: TRUE if the content of HiEdit control has been modified, FALSE otherwise

EM_SETMODIFY					EQU 0B9h
wParam = fModified				:the new value for the modification flag
lParam = 0
Returns: No return value.

EM_GETLINECOUNT					EQU 0BAh
wParam = 0
lParam = 0
Returns an integer specifying the number of lines in the HiEdit control. If no text is in the HiEdit control, the return value is 1. 

EM_LINEINDEX					EQU 0BBh
wParam = line					:Specifies the zero-based line number. A value of -1 specifies the current line number (the line that contains the caret).  
lParam = 0 
Returns: the character index of the line specified in the line parameter, or -1 if the specified line number is greater than the number of lines

EM_GETTHUMB						EQU 0BEh
wParam = 0
lParam = 0
Returns: the position of the scroll box.

EM_LINELENGTH					EQU 0C1h
wParam=Specifies the character index of a character in the line whose length is to be retrieved when EM_LINELENGTH is sent to a HiEdit control.
lParam=0
Returns: the length, in characters, of the line.

EM_REPLACESEL					EQU 0C2h
;If	wParam=0,			 	lParam=lpszText
;or wParam=number of bytes,	lParam=NOT null terminated string
Returns: No return value.
**************************************************************************************
NOTE: Different than edit and richedit which expects: 
wParam = fCanUndo				:flag that specifies whether replacement can be undone 
lParam = lpszReplace			:pointer to replacement null-terminated text string 
**************************************************************************************


EM_CANUNDO						EQU 0C6h
wParam = 0
lParam = 0
Returns: TRUE if the control can correctly process the EM_UNDO message

EM_UNDO							EQU 0C7h
wParam = 0
lParam = 0
Returns: TRUE if the undo operation is successful, or FALSE if the undo operation fails. 


EM_LINEFROMCHAR					EQU 0C9h
wParam = ich					:the character index of the character contained in the line whose number is to be retrieved. If the ich parameter is -1, either the line number of the current line (the line containing the caret) is retrieved or, if there is a selection, the line number of the line containing the beginning of the selection is retrieved. 
lParam = 0 
Returns the zero-based line number of the line containing the character index specified by ich. 


EM_EMPTYUNDOBUFFER				EQU 0CDh
wParam = 0
lParam = 0
Returns: No return value.

EM_GETFIRSTVISIBLELINE			EQU 0CEh
wParam = 0 
lParam = 0 
Returns the zero-based index of the uppermost visible line 

EM_GETLINE						EQU	0C4h
wParam=zero-based index of the line
lParam=Points to the buffer that receives a copy of the line. The first word of the buffer specifies the maximum number of characters that can be copied to the buffer.
Returns:The return value is the number of characters copied. The return value is zero if the line number specified by the line parameter is greater than the number of lines in the HiEdit control

EM_POSFROMCHAR					EQU 0D6h
wParam = (LPPOINT) lpPoint		:address of structure receiving character position 
lParam = (LPARAM) wCharIndex	:zero-based index of character. If the wCharIndex
is greater than the index of the last character in the control, the returned coordinates
are of the position just past the last character of the control.
Returns:This message does not return a value.

EM_CHARFROMPOS					EQU 0D9h
wParam = 0
lParam = MAKELPARAM(x, y)		x=Value of the low-order word of lParam. Specifies the x-coordinate of a point in the HiEdit control's client area. The coordinate is relative to the upper-left corner of the client area.
 								y=Value of the high-order word of lParam. Specifies the y-coordinate of a point in the HiEdit control's client area. The coordinate is relative to the upper-left corner of the client area.
NO:Returns: the character index in the low-order word and the line index in the high-order word. The return value is the last character in the HiEdit control if the given point is beyond the last character in the control.
NO:The return value is -1 if the specified point is outside the client area of the control.
Returns: the character index or the last character if the given point is beyond the last character in the control.

WM_CUT							EQU 300h
wParam = 0
lParam = 0
Delete (cut) the current selection, if any, and copy the deleted text to the clipboard in CF_TEXT format.
Returns:This message does not return a value.

WM_COPY							EQU 301h
wParam = 0
lParam = 0
Copy the current selection to the clipboard in CF_TEXT format
Returns:This message does not return a value.

WM_PASTE						EQU 302h
wParam = 0
lParam = 0
Copy the current content of the clipboard to the control at the current caret position
Returns:This message does not return a value.

WM_CLEAR						EQU 303h
wParam = 0
lParam = 0
Delete (clear) the current selection, if any, from the control. 
Returns:This message does not return a value.

WM_UNDO							EQU 304h 
wParam = 0
lParam = 0
Returns: TRUE if the undo operation is successful, or FALSE if the undo operation fails. 


Note: WM_USER EQU 400h
----------------------
EM_CANPASTE						EQU WM_USER + 50
wParam = uFormat				:Value identifying the clipboard format to try, or zero to try any format currently on the clipboard.
lParam = 0 
Returns: A nonzero value if the clipboard format can be pasted or zero otherwise.

EM_EXGETSEL						EQU WM_USER + 52
wParam = 0
lParam = lpchr					:Pointer to a CHARRANGE structure that receives the selection range.
Returns: No return value.

EM_EXLINEFROMCHAR				EQU WM_USER + 54
wParam = 0 
lParam = ichCharPos				:Zero-based index of the character.
Returns: The zero-based index of the line.

EM_EXSETSEL						EQU WM_USER + 55
wParam = 0
lParam = lpchr					:Pointer to a CHARRANGE structure that specifies the selection range
Returns: the zero-based index of the line.

EM_FINDTEXT						EQU WM_USER + 56
wParam = fuFlags				:Zero or more of the FT_MATCHCASE, FT_WHOLEWORD, FR_NOTNULLTERMINATED values.
lParam = lpFindText				:Pointer to a FINDTEXT structure containing information about the find operation.
 								FINDTEXT STRUCT
 								  chrg          CHARRANGE <>	Range to search
 								  lpstrText     DWORD      ?	If FR_NOTNULLTERMINATED is used, the first 4 bytes
 								  								is the length of the string to find followed by the
 								  								actual (not null-termianated) string to find.
 								  								Otherwise, Null terminated string to find 
 								FINDTEXT ENDS

Returns: the zero-based character position of the next match, or  - 1 if there are no more matches.

Formats a range of text for a specific device.
EM_FORMATRANGE					EQU WM_USER + 57
wParam = fRender				:Value specifying whether to render the text. If this parameter is nonzero, the text is rendered. Otherwise, the text is just measured.
lParam = lpFmt					:Pointer to a FORMATRANGE structure containing information about the output device, or NULL to free information cached by the control.
Returns the index of the last character that fits in the region plus one.

EM_GETEVENTMASK					EQU WM_USER + 59
Retrieves the event mask for a HiEdit control. The event mask specifies which notification messages the control sends to its parent window.
wParam = 0
lParam = 0
Returns the event mask for the HiEdit control.

EM_GETSELTEXT					EQU WM_USER + 62
wParam = 0
lParam = lpBuf					:Pointer to a buffer that receives the selected text. The calling application must ensure that the buffer is large enough to hold the selected text.
Returns: the number of characters copied, not including the terminating null character.

EM_SETEVENTMASK					EQU WM_USER + 69
Sets the event mask for a HiEdit control. The event mask specifies which notification messages the control sends to its parent window.
wParam = 0
lParam = New event mask for the HiEdit control.
Returns the previous event mask.
Remarks
The default event mask (before any is set) is not ENM_NONE (as for RichEdit) but ENM_SELCHANGE

ENM_KEYEVENTS To receive notifications for keyboard events.
ENM_MOUSEEVENTS To receive notifications for mouse events.
ENM_SCROLLEVENTS To receive notifications for a mouse wheel event.
ENM_SELCHANGE Sends EN_SELCHANGE notifications


EM_GETTEXTRANGE					EQU WM_USER + 75
wParam = 0
lParam = lpRange				:Pointer to a TEXTRANGE structure that specifies the range of characters to retrieve and a buffer to copy the characters to
Returns: The number of characters copied, not including the terminating null character.

EM_FINDTEXTEX					EQU WM_USER + 79
wParam = fuFlags				:Zero or more of the FT_MATCHCASE, FT_WHOLEWORD, FR_NOTNULLTERMINATED values.
lParam = lpFindText				:Address of a FINDTEXTEX structure containing information about the find operation.
 								FINDTEXTEX STRUCT
 								  chrg          CHARRANGE <>	Range to search
 								  lpstrText     DWORD      ?	If FR_NOTNULLTERMINATED is used, the first 4 bytes
 								  								is the length of the string to find followed by the
 								  								actual (not null-termianated) string to find.
 								  								Otherwise, Null terminated string to find 
 								  chrgText      CHARRANGE <>	Range in which text is found
 								FINDTEXTEX ENDS
Returns the zero-based character position of the next match or  - 1 if there are no more matches.

EM_REDO							EQU WM_USER + 84
wParam = 0
lParam = 0
Returns TRUE if the Redo operation succeeds, FALSE otherwise
Remarks
To determine whether there are any actions in the control's redo queue, send the EM_CANREDO message.

EM_CANREDO							EQU WM_USER + 85 
wParam = 0
lParam = 0
Return Value
Returns a nonzero value if there are actions in the control redo queue, zero otherwise

EM_GETUNDONAME						EQU WM_USER + 86
Retrieves the type of the next undo action, if any.
wParam = 0
lParam = 0
Return Value
If there is an undo action, the value returned is an UNDONAMEID enumeration value that indicates the type of the next action in the control's undo queue.
If there are no actions that can be undone or the type of the next undo action is unknown, the return value is zero.
Remarks
The types of actions that can be undone or redone include typing, delete, drag, drop, cut, and paste operations. This information can be useful for applications that provide an extended user interface for undo and redo operations, such as a drop-down list box of actions that can be undone. 

EM_GETREDONAME						EQU WM_USER + 87
Retrieves the type of the next action, if any, in the control's redo queue. 
wParam = 0
lParam = 0
Return Value
If the redo queue for the control is not empty, the value returned is an UNDONAMEID enumeration value that indicates the type of the next action in the control's redo queue.
If there are no redoable actions or the type of the next redoable action is unknown, the return value is zero.
Remarks
The types of actions that can be undone or redone include typing, delete, drag-drop, cut, and paste operations. This information can be useful for applications that provide an extended user interface for undo and redo operations, such as a drop-down list box of redoable actions. 


$
