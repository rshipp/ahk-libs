;Messages
SPRM_SPLITTHOR			equ WM_USER+100		;Create horizontal splitt in current splitt at current row. wParam=0, lParam=0
SPRM_SPLITTVER			equ WM_USER+101		;Create vertical splitt in current splitt at current col. wParam=0, lParam=0
SPRM_SPLITTCLOSE		equ WM_USER+102		;Close the current splitt. wParam=0, lParam=0
SPRM_SPLITTSYNC			equ WM_USER+103		;Syncronizez a splitt window with it's parent. wParam=0, lParam=TRUE/FALSE
SPRM_GETSPLITTSTATE		equ WM_USER+104		;*Get splitt state. wParam=nWin(0-7), if nWin=-1 active split window, lParam=0
SPRM_GETCELLRECT		equ WM_USER+105		;Get the current cells rect in active splitt. wParam=0, lParam=pointer to RECT struct. Returns handle of active splitt window.
SPRM_GETLOCKCOL			equ WM_USER+106		;Get lock cols in active splitt. wParam=0, lParam=0
SPRM_SETLOCKCOL			equ WM_USER+107		;Lock cols in active splitt. wParam=0, lParam=cols
SPRM_GETLOCKROW			equ WM_USER+108		;Get lock rows in active splitt. wParam=0, lParam=0
SPRM_SETLOCKROW			equ WM_USER+109		;Lock rows in active splitt. wParam=0, lParam=rows
SPRM_DELETECOL			equ WM_USER+110		;Delete col. wParam=col, lParam=0
SPRM_INSERTCOL			equ WM_USER+111		;Insert col. wParam=col, lParam=0
SPRM_DELETEROW			equ WM_USER+112		;Delete row. wParam=row, lParam=0
SPRM_INSERTROW			equ WM_USER+113		;Insert row. wParam=row, lParam=0
SPRM_GETCOLCOUNT		equ WM_USER+114		;Get number of columns. wParam=0, lParam=0
SPRM_SETCOLCOUNT		equ WM_USER+115		;Set number of columns. wParam=nCols, lParam=0
SPRM_GETROWCOUNT		equ WM_USER+116		;Get number of rows. wParam=0, lParam=0
SPRM_SETROWCOUNT		equ WM_USER+117		;Set number of rows. wParam=nRows, lParam=0
SPRM_RECALC				equ WM_USER+118		;Recalculates the sheet
SPRM_BLANKCELL			equ WM_USER+119		;Blank a cell. wParam=col, lParam=row
SPRM_GETCURRENTWIN		equ WM_USER+120		;Get active splitt window. wParam=0, lParam=0
SPRM_SETCURRENTWIN		equ WM_USER+121		;Set active splitt window. wParam=0, lParam=nWin (0-7)
SPRM_GETCURRENTCELL		equ WM_USER+122		;Get current col/row in active window. wParam=0, lParam=0. Returns Hiword=row, Loword=col
SPRM_SETCURRENTCELL		equ WM_USER+123		;Set current col/row in active window. wParam=col, lParam=row
SPRM_GETCELLSTRING		equ WM_USER+124		;Get content of current cell. wParam=0, lParam=0. Returns a pointer to a null terminated string.
SPRM_SETCELLSTRING		equ WM_USER+125		;Set content of current cell. wParam=type, lParam=pointer to string.
SPRM_GETCOLWIDTH		equ WM_USER+126		;Get column width. wParam=col, lParam=0. Returns column width.
SPRM_SETCOLWIDTH		equ WM_USER+127		;Set column width. wParam=col, lParam=width.
SPRM_GETROWHEIGHT		equ WM_USER+128		;Get row height. wParam=row, lParam=0. Returns row height.
SPRM_SETROWHEIGHT		equ WM_USER+129		;Set row height. wParam=row, lParam=height.
SPRM_GETCELLDATA		equ WM_USER+130		;Get cell data. wParam=0, lParam=Pointer to SPR_ITEM struct
SPRM_SETCELLDATA		equ WM_USER+131		;Set cell data. wParam=0, lParam=Pointer to SPR_ITEM struct
SPRM_GETMULTISEL		equ WM_USER+132		;Get multiselection. wParam=0, lParam=pointer to a RECT struct. Returns handle of active split window
SPRM_SETMULTISEL		equ WM_USER+133		;Set multiselection. wParam=0, lParam=pointer to a RECT struct. Returns handle of active split window
SPRM_GETFONT			equ WM_USER+134		;Get font. wParam=index(0-15), lParam=pointer to FONT struct. Returns font handle
SPRM_SETFONT			equ WM_USER+135		;Set font. wParam=index(0-15), lParam=pointer to FONT struct. Returns font handle
SPRM_GETGLOBAL			equ WM_USER+136		;Get global. wParam=0, lParam=pointer to GLOBAL struct.
SPRM_SETGLOBAL			equ WM_USER+137		;Set global. wParam=0, lParam=pointer to GLOBAL struct.
SPRM_IMPORTLINE			equ WM_USER+138		;Import a line of data. wParam=SepChar, lParam=pointer to data line.
SPRM_LOADFILE			equ WM_USER+139		;Load a file. wParam=0, lParam=pointer to filename
SPRM_SAVEFILE			equ WM_USER+140		;Save a file. wParam=0, lParam=pointer to filename
SPRM_NEWSHEET			equ WM_USER+141		;Clears the sheet. wParam=0, lParam=0
SPRM_EXPANDCELL			equ WM_USER+142		;Expand a cell to cover more than one cell. wParam=0, lParam=pointer to RECT struct
SPRM_GETCELLTYPE		equ WM_USER+143		;Get cell data type. wParam=col, lParam=row. Returns cell type.
SPRM_ADJUSTCELLREF		equ WM_USER+144		;Adjust cell refs in formula. wParam=pointer to cell, lParam=pointer to RECT.
SPRM_CREATECOMBO		equ WM_USER+145		;Creates a ComboBox. wPatam=Height, lParam=0
SPRM_SCROLLCELL			equ WM_USER+146		;Scrolls current cell into view
SPRM_DELETECELL			equ WM_USER+147		;Deletes a cell. wParam=col, lParam=row
SPRM_GETDATEFORMAT		equ WM_USER+148		;Returns date format string. wParam=0, lParam=0
SPRM_SETDATEFORMAT		equ WM_USER+149		;Sets date format string. wParam=0, lParam=lpDateFormat (yyyy-MM-dd)

;Styles
SPS_VSCROLL				equ 0001h			;Vertical scrollbar
SPS_HSCROLL				equ 0002h			;Horizontal scrollbar
SPS_STATUS				equ 0004h			;Show status window
SPS_GRIDLINES			equ 0008h			;Show grid lines
SPS_ROWSELECT			equ 0010h			;Selection by row
SPS_CELLEDIT			equ 0020h			;Cell editing
SPS_GRIDMODE			equ 0040h			;Inserting and deleting row/col adjusts max row/col
SPS_COLSIZE				equ 0080h			;Allow col widt sizeing by mouse
SPS_ROWSIZE				equ 0100h			;Allow row height sizeing by mouse
SPS_WINSIZE				equ 0200h			;Allow splitt window sizeing by mouse
SPS_MULTISELECT			equ 0400h			;Allow multiselect

;Cell data types
TPE_EMPTY				equ 000h			;The cell contains formatting only
TPE_COLHDR				equ 001h			;Column header
TPE_ROWHDR				equ 002h			;Row header
TPE_WINHDR				equ 003h			;Window (splitt) header
TPE_TEXT				equ 004h			;Text cell
TPE_TEXTMULTILINE		equ 005h			;Text cell, text is multiline
TPE_INTEGER				equ 006h			;Double word integer
TPE_FLOAT				equ 007h			;80 bit float
TPE_FORMULA				equ 008h			;Formula
TPE_GRAPH				equ 009h			;Graph
TPE_HYPERLINK			equ 00Ah			;Hyperlink
TPE_CHECKBOX			equ 00Bh			;Checkbox
TPE_COMBOBOX			equ 00Ch			;Combobox
TPE_OWNERDRAWBLOB		equ 00Dh			;Owner drawn blob, first word is lenght of blob
TPE_OWNERDRAWINTEGER	equ 00Eh			;Owner drawn integer
TPE_EXPANDED			equ 00Fh			;Part of expanded cell, internally used

TPE_TYPEMASK			equ 00Fh			;Type mask

TPE_BUTTON				equ 010h			;Small button
TPE_WIDEBUTTON			equ 020h			;Button, covers the cell
TPE_DATE				equ 030h			;Combine with type integer
TPE_FORCETYPE			equ 040h			;Forced type
TPE_FIXEDSIZE			equ 080h			;Fixed size for CheckBox, ComboBox and Button image

;Format Alignment & Decimals
FMTA_AUTO				equ 000h			;Text left middle, numbers right middle
FMTA_LEFT				equ 010h
FMTA_CENTER				equ 020h
FMTA_RIGHT				equ 030h
FMTA_TOP				equ 000h
FMTA_MIDDLE				equ 040h
FMTA_BOTTOM				equ 080h
FMTA_GLOBAL				equ 0F0h
FMTA_MASK				equ 0F0h			;Alignment mask
FMTA_XMASK				equ 030h			;Alignment x-mask
FMTA_YMASK				equ 0C0h			;Alignment y-mask

FMTD_0					equ 00h
FMTD_1					equ 01h
FMTD_2					equ 02h
FMTD_3					equ 03h
FMTD_4					equ 04h
FMTD_5					equ 05h
FMTD_6					equ 06h
FMTD_7					equ 07h
FMTD_8					equ 08h
FMTD_9					equ 09h
FMTD_10					equ 0Ah
FMTD_11					equ 0Bh
FMTD_12					equ 0Ch
FMTD_ALL				equ 0Dh
FMTD_SCI				equ 0Eh
FMTD_GLOBAL				equ 0Fh
FMTD_MASK				equ 0Fh

FORMAT struct dword
	bckcol			dd ?					;Back color
	txtcol			dd ?					;Text color
	txtal			db ?					;Text alignment and decimals
	imgal			db ?					;Image alignment and imagelist/control index
	fnt				db ?					;Font index (0-15)
	tpe				db ?					;Cell type
FORMAT ends

GLOBAL struct dword
	colhdrbtn		dd ?
	rowhdrbtn		dd ?
	winhdrbtn		dd ?
	lockcol			dd ?					;Back color of locked cell
	hdrgrdcol		dd ?					;Header grid color
	grdcol			dd ?					;Cell grid color
	bcknfcol		dd ?					;Back color of active cell, lost focus
	txtnfcol		dd ?					;Text color of active cell, lost focus
	bckfocol		dd ?					;Back color of active cell, has focus
	txtfocol		dd ?					;Text color of active cell, has focus
	ncols			dd ?
	nrows			dd ?
	ghdrwt			dd ?
	ghdrht			dd ?
	gcellwt			dd ?
	gcellht			dd ?
	colhdr			FORMAT <?>				;Column header formatting
	rowhdr			FORMAT <?>				;Row header formatting
	winhdr			FORMAT <?>				;Window header formatting
	cell			FORMAT <?>				;Cell formatting
GLOBAL ends

FONT struct dword
	hfont			dd ?					;Font handle
	face			db LF_FACESIZE dup(?)	;Face name
	fsize			dd ?					;Point size
	ht				dd ?					;Height
	bold			db ?					;Bold
	italic			db ?					;Italics
	underline		db ?					;Underline
	strikeout		db ?					;Strikeout
FONT ends

STATE_LOCKED			equ 001h			;Cell is locked for editing
STATE_HIDDEN			equ 002h			;Cell content is not displayed
STATE_REDRAW			equ 008h
STATE_ERROR				equ 010h
STATE_DIV0				equ 020h
STATE_UNDERFLOW			equ 030h
STATE_OVERFLOW			equ 040h
STATE_RECALC			equ 080h
STATE_ERRMASK			equ 0F0h

SPRIF_BACKCOLOR			equ 00000001h		;Back color is valid
SPRIF_TEXTCOLOR			equ 00000002h		;Text color is valid
SPRIF_TEXTALIGN			equ 00000004h		;Text alignment is valid
SPRIF_IMAGEALIGN		equ 00000008h		;Image alignment is valid
SPRIF_FONT				equ 00000010h		;Font is valid
SPRIF_STATE				equ 00000020h		;State is valid
SPRIF_TYPE				equ 00000040h		;Type is valid
SPRIF_WIDTH				equ 00000080h		;Column width is valid
SPRIF_HEIGHT			equ 00000100h		;Row height is valid
SPRIF_DATA				equ 00000200h		;Data is valid
SPRIF_DOUBLE			equ 00000400h		;Converts to / from double
SPRIF_SINGLE			equ 00000800h		;Converts to / from single
SPRIF_COMPILE			equ 80000000h		;Compile the formula

SPR_ITEM struct dword
	flag			dd ?					;Combination of SPRIF_ values
	col				dd ?					;Column
	row				dd ?					;Row
	expx			db ?					;Expanded columns
	expy			db ?					;Expanded rows
	state			db ?					;Cell state
	fmt				FORMAT <?>				;Back color, fore color, text alignment, image alignment, font and cell type
	wt				dd ?					;Column width
	ht				dd ?					;Row height
	lpdta			dd ?					;Pointer to cell data
SPR_ITEM ends

;Use when creating a combobox cell
COMBOBOX_DATA struct
	ninx			dd ?					;Combobox listindex
	hcbo			HWND ?					;Combobox handle
COMBOBOX_DATA ends

;Use when creating a checkbox cell
CHECKBOX_DATA struct
	state			dd ?					;1=Checked, 0=UnChecked
	sztext			db 128 dup(?)			;Checkbox text
CHECKBOX_DATA ends

;Notification messages (WM_NOTIFY)
SPRN_SELCHANGE			equ 1				;Splitt, col or row changed.
SPRN_BEFOREEDIT			equ 2				;Before the editbox is shown
SPRN_AFTEREDIT			equ 3				;After the editbox is closed
SPRN_BEFOREUPDATE		equ 4				;Before cell is updated
SPRN_AFTERUPDATE		equ 5				;After cell is updated
SPRN_HYPERLINKENTER		equ 6				;Hyperlink entered
SPRN_HYPERLINKLEAVE		equ 7				;Hyperlink leaved
SPRN_HYPERLINKCLICK		equ 8				;Hyperlink clicked
SPRN_BUTTONCLICK		equ 9				;Button clicked

;Notification structs

;SPRN_SELCHANGE
SPR_SELCHANGE struct dword
	hdr				NMHDR <?>
	nwin			dd ?
	col				dd ?
	row				dd ?
	fcancel			dd ?
SPR_SELCHANGE ends

;SPRN_BEFOREEDIT, SPRN_AFTEREDIT, SPRN_BEFOREUPDATE and SPRN_AFTERUPDATE
SPR_EDIT struct dword
	hdr				NMHDR <?>
	lpspri			dd ?
	fcancel			dd ?
SPR_EDIT ends

;SPRN_HYPERLINKENTER, SPRN_HYPERLINKLEAVE and SPRN_HYPERLINKCLICK
SPR_HYPERLINK struct dword
	hdr				NMHDR <?>
	lpspri			dd ?
SPR_HYPERLINK ends

;SPRN_BUTTONCLICK
SPR_BUTTON struct dword
	hdr				NMHDR <?>
	lpspri			dd ?
SPR_BUTTON ends
