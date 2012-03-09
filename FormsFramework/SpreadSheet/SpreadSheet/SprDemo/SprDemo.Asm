.386
.model flat,stdcall
option casemap:none

include SprDemo.inc
include Misc.asm
include SprGlobalFmt.asm
include SprCellFmt.asm

.code

start:

	invoke GetModuleHandle,NULL
	mov    hInstance,eax
	invoke GetCommandLine
	invoke InitCommonControls
    invoke LoadLibrary,offset szLibName
	.if eax
		mov		hSprShtDLL,eax
		invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
		invoke FreeLibrary,hSprShtDLL
	.endif
	invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL	wc:WNDCLASSEX
	LOCAL	msg:MSG

	mov		wc.cbSize,SIZEOF WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,OFFSET WndProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,DLGWINDOWEXTRA
	push	hInstance
	pop		wc.hInstance
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,IDR_MENU
	mov		wc.lpszClassName,OFFSET ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	invoke CreateDialogParam,hInstance,IDD_DLG1,NULL,addr WndProc,NULL
	invoke ShowWindow,hWnd,SW_SHOWNORMAL
	invoke UpdateWindow,hWnd
	.while TRUE
		invoke GetMessage,addr msg,NULL,0,0
	  .BREAK .if !eax
		invoke TranslateMessage,addr msg
		invoke DispatchMessage,addr msg
	.endw
	mov		eax,msg.wParam
	ret

WinMain endp

WndProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	rect1:RECT
	LOCAL	fnt:FONT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		push	hWin
		pop		hWnd
		;Get the handle
		invoke GetDlgItem,hWin,1001
		mov		hSht,eax
;		;Put in some cell data
;		mov		spri.flag,SPRIF_BACKCOLOR or SPRIF_TEXTCOLOR or SPRIF_TYPE or SPRIF_DATA or SPRIF_WIDTH or SPRIF_HEIGHT
;		mov		spri.col,1
;		mov		spri.row,1
;		mov		spri.fmt.bckcol,0FFh
;		mov		spri.fmt.txtcol,0FF00h
;		mov		spri.fmt.tpe,TPE_TEXT
;		mov		spri.wt,120
;		mov		spri.ht,40
;		mov		spri.lpdta,offset szCellText
;		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
;
;		mov		spri.flag,SPRIF_BACKCOLOR or SPRIF_TEXTCOLOR or SPRIF_TYPE or SPRIF_DATA
;		mov		spri.col,2
;		mov		spri.fmt.bckcol,0FF00h
;		mov		spri.fmt.txtcol,0FF0000h
;		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
;
;		mov		spri.col,3
;		mov		spri.fmt.bckcol,0FF0000h
;		mov		spri.fmt.txtcol,0FFh
;		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
;
;		mov		spri.col,4
;		mov		spri.fmt.bckcol,0FFh
;		mov		spri.fmt.txtcol,0FF0000h
;		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
;
;		mov		spri.flag,SPRIF_TYPE or SPRIF_DATA
;		mov		spri.col,5
;		mov		spri.fmt.tpe,TPE_TEXTMULTILINE
;		mov		spri.lpdta,offset szCellTextMultiLine
;		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
;
;		mov		spri.flag,SPRIF_TYPE or SPRIF_DATA or SPRIF_TEXTALIGN
;		mov		spri.col,6
;		mov		spri.fmt.txtal,FMTA_CENTER or FMTA_TOP
;		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
;
;		mov		spri.flag,SPRIF_TYPE or SPRIF_DATA or SPRIF_TEXTALIGN
;		mov		spri.col,7
;		mov		spri.fmt.txtal,FMTA_RIGHT or FMTA_TOP
;		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
;
;		mov		spri.flag,SPRIF_TYPE or SPRIF_DATA or SPRIF_TEXTALIGN or SPRIF_HEIGHT
;		mov		spri.col,1
;		mov		spri.row,2
;		mov		spri.ht,30
;		mov		spri.fmt.txtal,FMTA_LEFT or FMTA_TOP
;		mov		spri.fmt.tpe,TPE_TEXT
;		mov		spri.lpdta,offset szCellTextAlign
;		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
;
;		mov		spri.row,3
;		mov		spri.ht,30
;		mov		spri.fmt.txtal,FMTA_LEFT or FMTA_MIDDLE
;		mov		spri.fmt.tpe,TPE_TEXT
;		mov		spri.lpdta,offset szCellTextAlign
;		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
;
;		mov		spri.row,4
;		mov		spri.ht,30
;		mov		spri.fmt.txtal,FMTA_LEFT or FMTA_BOTTOM
;		mov		spri.fmt.tpe,TPE_TEXT
;		mov		spri.lpdta,offset szCellTextAlign
;		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
;
;		mov		spri.flag,SPRIF_TYPE or SPRIF_DATA or SPRIF_TEXTALIGN
;		mov		spri.col,2
;		mov		spri.row,2
;		mov		spri.fmt.txtal,FMTA_CENTER or FMTA_TOP
;		mov		spri.fmt.tpe,TPE_TEXT
;		mov		spri.lpdta,offset szCellTextAlign
;		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
;
;		mov		spri.row,3
;		mov		spri.fmt.txtal,FMTA_CENTER or FMTA_MIDDLE
;		mov		spri.fmt.tpe,TPE_TEXT
;		mov		spri.lpdta,offset szCellTextAlign
;		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
;
;		mov		spri.row,4
;		mov		spri.fmt.txtal,FMTA_CENTER or FMTA_BOTTOM
;		mov		spri.fmt.tpe,TPE_TEXT
;		mov		spri.lpdta,offset szCellTextAlign
;		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
;
;		mov		spri.col,3
;		mov		spri.row,2
;		mov		spri.fmt.txtal,FMTA_RIGHT or FMTA_TOP
;		mov		spri.fmt.tpe,TPE_TEXT
;		mov		spri.lpdta,offset szCellTextAlign
;		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
;
;		mov		spri.row,3
;		mov		spri.fmt.txtal,FMTA_RIGHT or FMTA_MIDDLE
;		mov		spri.fmt.tpe,TPE_TEXT
;		mov		spri.lpdta,offset szCellTextAlign
;		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
;
;		mov		spri.row,4
;		mov		spri.fmt.txtal,FMTA_RIGHT or FMTA_BOTTOM
;		mov		spri.fmt.tpe,TPE_TEXT
;		mov		spri.lpdta,offset szCellTextAlign
;		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
;
;		mov		spri.flag,SPRIF_TYPE or SPRIF_DATA or SPRIF_HEIGHT
;		mov		spri.col,1
;		mov		spri.row,5
;		mov		spri.ht,30
;		mov		spri.fmt.tpe,TPE_TEXT
;		mov		spri.lpdta,offset szCellTextFont
;		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
;
;		invoke RtlZeroMemory,addr fnt,sizeof fnt
;		invoke lstrcpy,addr fnt.face,offset szTahoma
;		mov		fnt.fsize,15
;		mov		fnt.ht,-20
;		invoke SendMessage,hSht,SPRM_SETFONT,1,addr fnt
;
;		mov		spri.flag,SPRIF_TYPE or SPRIF_DATA or SPRIF_FONT
;		mov		spri.col,2
;		mov		spri.row,5
;		mov		spri.fmt.fnt,1
;		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
;
;		mov		fnt.fsize,19
;		mov		fnt.ht,-25
;		invoke SendMessage,hSht,SPRM_SETFONT,2,addr fnt
;
;		mov		spri.flag,SPRIF_TYPE or SPRIF_DATA or SPRIF_FONT
;		mov		spri.col,3
;		mov		spri.fmt.fnt,2
;		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
;
;		mov		spri.flag,SPRIF_TYPE or SPRIF_DATA
;		mov		spri.col,1
;		mov		spri.row,6
;		mov		spri.fmt.tpe,TPE_INTEGER
;		mov		spri.lpdta,offset ddCellInteger
;		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
;
;		mov		spri.flag,SPRIF_TYPE or SPRIF_DATA
;		mov		spri.col,1
;		mov		spri.row,7
;		mov		spri.fmt.tpe,TPE_FLOAT
;		mov		spri.lpdta,offset dtCellFloat
;		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
;
;		mov		spri.flag,SPRIF_TYPE or SPRIF_DATA or SPRIF_COMPILE
;		mov		spri.col,1
;		mov		spri.row,8
;		mov		spri.fmt.tpe,TPE_FORMULA
;		mov		spri.lpdta,offset szCellFormula1
;		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
;
		mov		spri.flag,SPRIF_TYPE or SPRIF_DATA or SPRIF_COMPILE
		mov		spri.col,1
		mov		spri.row,20
		mov		spri.fmt.tpe,TPE_TEXT or TPE_BUTTON or TPE_FIXEDSIZE
		mov		spri.lpdta,offset szCellTextFont
		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
		invoke SendMessage,hSht,SPRM_SETCURRENTCELL,1,1
		invoke SendMessage,hSht,SPRM_RECALC,0,0

		;Insert some values for the graph
		push	ebx
		push	esi
		mov		ebx,1
		mov		esi,offset dtAJ1
		.while ebx<=13
			mov		spri.flag,SPRIF_TYPE or SPRIF_DATA
			mov		spri.col,10
			mov		spri.row,ebx
			mov		spri.fmt.tpe,TPE_FLOAT
			mov		spri.lpdta,esi
			invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
			inc		ebx
			add		esi,10
		.endw
		pop		esi
		pop		ebx
		;Graph
		mov		spri.flag,SPRIF_TYPE or SPRIF_BACKCOLOR or SPRIF_DATA or SPRIF_COMPILE
		mov		spri.col,1
		mov		spri.row,1
		mov		spri.fmt.bckcol,0D0FFFFh
		mov		spri.fmt.tpe,TPE_GRAPH
		mov		spri.lpdta,offset szCellGraph
		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
		;Expand the cell containing the graph
		mov		rect.left,1
		mov		rect.right,7
		mov		rect.top,1
		mov		rect.bottom,17
		invoke SendMessage,hSht,SPRM_EXPANDCELL,0,addr rect


		push	ebx
		mov		ebx,1
		.while ebx<=255
			mov		spri.flag,SPRIF_TYPE or SPRIF_DATA or SPRIF_COMPILE
			mov		spri.col,ebx
			mov		spri.row,20
			mov		spri.fmt.tpe,TPE_FORMULA
			mov		spri.lpdta,offset szCellFormula1
			invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
			inc		ebx
		.endw
		pop		ebx
		invoke SendMessage,hSht,SPRM_RECALC,0,0

;		;Load a file
;		invoke SendMessage,hSht,SPRM_LOADFILE,0,offset szAutoLoad
		invoke SetFocus,hSht
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		and		eax,0FFFFh
		.if eax==IDM_FILE_OPEN
			invoke LoadFile,hWin
		.elseif eax==IDM_FILE_SAVE
			mov		al,FileName
			.if al
				invoke SendMessage,hSht,SPRM_SAVEFILE,0,offset FileName
			.else
				invoke SaveFileAs,hWin
			.endif
		.elseif eax==IDM_FILE_SAVE_AS
			invoke SaveFileAs,hWin
		.elseif eax==IDM_FILE_NEW
			invoke SendMessage,hSht,SPRM_NEWSHEET,0,0
		.elseif eax==IDM_FILE_EXIT
			invoke SendMessage,hWin,WM_CLOSE,0,0
		.elseif eax==IDM_EDIT_DELETE_ROW
			invoke SendMessage,hSht,SPRM_GETCURRENTCELL,0,0
			shr		eax,16
			invoke SendMessage,hSht,SPRM_DELETEROW,eax,0
			invoke SendMessage,hSht,SPRM_RECALC,0,0
		.elseif eax==IDM_EDIT_DELETE_COL
			invoke SendMessage,hSht,SPRM_GETCURRENTCELL,0,0
			and		eax,0FFFFh
			invoke SendMessage,hSht,SPRM_DELETECOL,eax,0
			invoke SendMessage,hSht,SPRM_RECALC,0,0
		.elseif eax==IDM_EDIT_INSERT_ROW
			invoke SendMessage,hSht,SPRM_GETCURRENTCELL,0,0
			shr		eax,16
			invoke SendMessage,hSht,SPRM_INSERTROW,eax,0
			invoke SendMessage,hSht,SPRM_RECALC,0,0
		.elseif eax==IDM_EDIT_INSERT_COL
			invoke SendMessage,hSht,SPRM_GETCURRENTCELL,0,0
			and		eax,0FFFFh
			invoke SendMessage,hSht,SPRM_INSERTCOL,eax,0
			invoke SendMessage,hSht,SPRM_RECALC,0,0
		.elseif eax==IDM_EDIT_COPY_CELL
			invoke SendMessage,hSht,SPRM_GETMULTISEL,0,addr rect
			mov		eax,rect.left
			.if eax>rect.right
				xchg	eax,rect.right
				mov		rect.left,eax
			.endif
			mov		eax,rect.top
			.if eax>rect.bottom
				xchg	eax,rect.bottom
				mov		rect.top,eax
			.endif
			mov		eax,rect.left
			mov		rect1.left,eax
			mov		spri.col,eax
			mov		eax,rect.top
			mov		rect1.top,eax
			mov		spri.row,eax
			mov		spri.flag,SPRIF_BACKCOLOR or SPRIF_TEXTCOLOR or SPRIF_TEXTALIGN or SPRIF_IMAGEALIGN or SPRIF_FONT or SPRIF_TYPE or SPRIF_DATA
			invoke SendMessage,hSht,SPRM_GETCELLDATA,0,offset spri
			;Make cell data local
			push	esi
			push	edi
			mov		esi,spri.lpdta
			mov		edi,offset localdata
			mov		spri.lpdta,edi
			mov		ecx,256
			rep movsb
			pop		edi
			pop		esi
			mov		eax,rect.top
			.while eax<=rect.bottom
				mov		edx,rect.left
				.while edx<=rect.right
					push	eax
					push	edx
					.if eax!=rect.top || edx!=rect.left
						mov		spri.col,edx
						mov		ecx,edx
						sub		ecx,rect1.left
						mov		rect1.right,ecx
						mov		spri.row,eax
						mov		ecx,eax
						sub		ecx,rect1.top
						mov		rect1.bottom,ecx
						invoke SendMessage,hSht,SPRM_GETCELLTYPE,edx,eax
						.if eax!=TPE_EXPANDED
							invoke SendMessage,hSht,SPRM_SETCELLDATA,0,offset spri
							mov		edx,eax
							invoke SendMessage,hSht,SPRM_ADJUSTCELLREF,edx,addr rect1
						.endif
					.endif
					pop		edx
					pop		eax
					inc		edx
				.endw
				inc		eax
			.endw
			invoke SendMessage,hSht,SPRM_RECALC,0,0
		.elseif eax==IDM_EDIT_BLANK_CELLS
			invoke SendMessage,hSht,SPRM_GETMULTISEL,0,addr rect
			mov		eax,rect.left
			.if eax>rect.right
				xchg	eax,rect.right
				mov		rect.left,eax
			.endif
			mov		eax,rect.top
			.if eax>rect.bottom
				xchg	eax,rect.bottom
				mov		rect.top,eax
			.endif
			mov		eax,rect.top
			.while eax<=rect.bottom
				mov		edx,rect.left
				.while edx<=rect.right
					push	eax
					push	edx
					invoke SendMessage,hSht,SPRM_GETCELLTYPE,edx,eax
					.if eax!=TPE_EXPANDED
						pop		edx
						pop		eax
						push	eax
						push	edx
						invoke SendMessage,hSht,SPRM_BLANKCELL,edx,eax
					.endif
					pop		edx
					pop		eax
					inc		edx
				.endw
				inc		eax
			.endw
			invoke SendMessage,hSht,SPRM_RECALC,0,0
		.elseif eax==IDM_EDIT_EXPAND_CELL
			invoke SendMessage,hSht,SPRM_GETMULTISEL,0,addr rect
			invoke SendMessage,hSht,SPRM_EXPANDCELL,0,addr rect
			invoke SendMessage,hSht,SPRM_RECALC,0,0
		.elseif eax==IDM_FORMAT_GLOBAL
			invoke DialogBoxParam,hInstance,1200,hWin,offset GlobalFmtProc,0
		.elseif eax==IDM_FORMAT_CELLS
			invoke DialogBoxParam,hInstance,1100,hWin,offset CellFmtProc,0
		.elseif eax==IDM_FORMAT_LOCK_YES
			mov		ah,0FFh
			mov		al,STATE_LOCKED
			call SetState
		.elseif eax==IDM_FORMAT_LOCK_NO
			mov		ah,0FFh xor STATE_LOCKED 
			mov		al,0
			call SetState
		.elseif eax==IDM_FORMAT_HIDE_YES
			mov		ah,0FFh
			mov		al,STATE_HIDDEN
			call SetState
		.elseif eax==IDM_FORMAT_HIDE_NO
			mov		ah,0FFh xor STATE_HIDDEN
			mov		al,0
			call SetState
		.elseif eax==IDM_WINDOW_SPLIT_HOR
			invoke SendMessage,hSht,SPRM_SPLITTHOR,0,0
		.elseif eax==IDM_WINDOW_SPLIT_VER
			invoke SendMessage,hSht,SPRM_SPLITTVER,0,0
		.elseif eax==IDM_WINDOW_CLOSE_SPLITT
			invoke SendMessage,hSht,SPRM_SPLITTCLOSE,0,0
		.elseif eax==IDM_WINDOW_SPLITT_SYNC_YES
			invoke SendMessage,hSht,SPRM_SPLITTSYNC,0,TRUE
		.elseif eax==IDM_WINDOW_SPLITT_SYNC_NO
			invoke SendMessage,hSht,SPRM_SPLITTSYNC,0,FALSE
		.elseif eax==IDM_WINDOW_LOCK_ROW_YES
			invoke SendMessage,hSht,SPRM_SETLOCKROW,0,1
		.elseif eax==IDM_WINDOW_LOCK_ROW_NO
			invoke SendMessage,hSht,SPRM_SETLOCKROW,0,0
		.elseif eax==IDM_WINDOW_LOCK_COL_YES
			invoke SendMessage,hSht,SPRM_SETLOCKCOL,0,1
		.elseif eax==IDM_WINDOW_LOCK_COL_NO
			invoke SendMessage,hSht,SPRM_SETLOCKCOL,0,0
		.elseif eax==IDM_WINDOW_HEAD_COL_YES
			invoke SendMessage,hSht,SPRM_SETROWHEIGHT,0,-1
			invoke SendMessage,hSht,WM_SIZE,0,0
		.elseif eax==IDM_WINDOW_HEAD_COL_NO
			invoke SendMessage,hSht,SPRM_SETROWHEIGHT,0,0
			invoke SendMessage,hSht,WM_SIZE,0,0
		.elseif eax==IDM_WINDOW_HEAD_ROW_YES
			invoke SendMessage,hSht,SPRM_SETCOLWIDTH,0,-1
			invoke SendMessage,hSht,WM_SIZE,0,0
		.elseif eax==IDM_WINDOW_HEAD_ROW_NO
			invoke SendMessage,hSht,SPRM_SETCOLWIDTH,0,0
			invoke SendMessage,hSht,WM_SIZE,0,0
		.elseif eax==IDM_STYLE_VSCROLL
			invoke SetStyle,SPS_VSCROLL
		.elseif eax==IDM_STYLE_HSCROLL
			invoke SetStyle,SPS_HSCROLL
		.elseif eax==IDM_STYLE_STATUS
			invoke SetStyle,SPS_STATUS
		.elseif eax==IDM_STYLE_GRID
			invoke SetStyle,SPS_GRIDLINES
		.elseif eax==IDM_STYLE_ROWSEL
			invoke SetStyle,SPS_ROWSELECT
		.elseif eax==IDM_STYLE_CELLEDIT
			invoke SetStyle,SPS_CELLEDIT
		.elseif eax==IDM_STYLE_GRIDMODE
			invoke SetStyle,SPS_GRIDMODE
		.elseif eax==IDM_STYLE_COLSIZE
			invoke SetStyle,SPS_COLSIZE
		.elseif eax==IDM_STYLE_ROWSIZE
			invoke SetStyle,SPS_ROWSIZE
		.elseif eax==IDM_STYLE_WINSIZE
			invoke SetStyle,SPS_WINSIZE
		.elseif eax==IDM_STYLE_MULTISEL
			invoke SetStyle,SPS_MULTISELECT
		.elseif eax==IDM_HELP_ABOUT
			invoke ShellAbout,hWin,addr AppName,addr AboutMsg,NULL
		.endif
	.elseif eax==WM_SETFOCUS
		invoke SetFocus,hSht
		xor		eax,eax
		ret
	.elseif eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		invoke MoveWindow,hSht,0,0,rect.right,rect.bottom,TRUE
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWin
	.elseif eax==WM_DESTROY
		invoke PostQuitMessage,NULL
	.elseif eax==WM_NOTIFY
		.if wParam==IDC_SPR1
			mov		edx,lParam
			mov		eax,[edx].NMHDR.code
			.if eax==SPRN_SELCHANGE
				;Restrict moveable area
;mov		eax,[edx].SPR_SELCHANGE.col
;PrintHex eax
;mov		eax,[edx].SPR_SELCHANGE.row
;PrintHex eax
;				.if [edx].SPR_SELCHANGE.col>5 || [edx].SPR_SELCHANGE.row>10 || [edx].SPR_SELCHANGE.nwin!=0
;					mov		[edx].SPR_SELCHANGE.fcancel,TRUE
;				.endif
			.elseif eax==SPRN_BEFOREEDIT
				;Cancel editbox showing
;				mov		[edx].SPR_EDIT.fcancel,TRUE
			.elseif eax==SPRN_AFTEREDIT
				;Cancel update
;				mov		[edx].SPR_EDIT.fcancel,TRUE
			.elseif eax==SPRN_BEFOREUPDATE
				;Cancel cell update
;				mov		[edx].SPR_EDIT.fcancel,TRUE
			.elseif eax==SPRN_AFTERUPDATE
			.endif
		.endif
		xor		eax,eax
		ret
	.endif
	invoke DefWindowProc,hWin,uMsg,wParam,lParam
	ret

SetState:
	push	ebx
	mov		ebx,eax
	invoke SendMessage,hSht,SPRM_GETMULTISEL,0,addr rect
	mov		eax,rect.left
	.if eax>rect.right
		xchg	eax,rect.right
		mov		rect.left,eax
	.endif
	mov		eax,rect.top
	.if eax>rect.bottom
		xchg	eax,rect.bottom
		mov		rect.top,eax
	.endif
	mov		eax,rect.top
	.while eax<=rect.bottom
		mov		edx,rect.left
		.while edx<=rect.right
			push	eax
			push	edx
			mov		spri.row,eax
			mov		spri.col,edx
			invoke SendMessage,hSht,SPRM_GETCELLDATA,0,offset spri
			mov		spri.flag,SPRIF_STATE
			and		spri.state,bh
			or		spri.state,bl
			invoke SendMessage,hSht,SPRM_SETCELLDATA,0,offset spri
			pop		edx
			pop		eax
			inc		edx
		.endw
		inc		eax
	.endw
	pop		ebx
	retn

WndProc endp

end start
