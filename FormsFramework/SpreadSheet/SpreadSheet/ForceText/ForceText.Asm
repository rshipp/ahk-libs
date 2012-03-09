.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include ForceText.inc

.code

start:

	invoke GetModuleHandle,NULL
	mov		hInstance,eax

    invoke InitCommonControls
	;Must call a function in the dll to have it loaded.
	invoke GetDef,0
	invoke DialogBoxParam,hInstance,IDD_DIALOG1,NULL,addr DlgProc,NULL
	invoke ExitProcess,0

;########################################################################

DlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	spri:SPR_ITEM
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		;Get spread sheet window handle
		invoke GetDlgItem,hWin,IDC_SPR1
		mov		hSpr,eax
		;Set up an item struct
		;flag specify valid struct items
		mov		spri.flag,SPRIF_DATA or SPRIF_TYPE or SPRIF_WIDTH or SPRIF_IMAGEALIGN or SPRIF_TEXTALIGN
		mov		spri.fmt.imgal,FMTA_LEFT
		mov		spri.fmt.txtal,FMTA_LEFT
		;Plain text
		mov		spri.fmt.tpe,TPE_TEXT
		;Col 1
		mov		spri.col,1
		;Row 1
		mov		spri.row,1
		;And a pointer to text
		mov		spri.lpdta,offset szSomeText1
		;Width
		mov		spri.wt,200
		;Insert the item
		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,0
	.elseif eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		invoke MoveWindow,hSpr,0,0,rect.right,rect.bottom,TRUE
	.elseif eax==WM_NOTIFY
		mov		edx,lParam
		mov		eax,[edx].NMHDR.hwndFrom
		.if eax==hSpr
			mov		eax,[edx].NMHDR.code
			.if eax==SPRN_AFTEREDIT
				;Get pointer to SPR_ITEM
				mov		ecx,[edx].SPR_EDIT.lpspri
				;Set the flag
				mov		[ecx].SPR_ITEM.flag,SPRIF_DATA or SPRIF_TYPE
				;Set the cell type
				mov		[ecx].SPR_ITEM.fmt.tpe,TPE_TEXT
				invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,ecx
				;Cancel the edit operation
				mov		edx,lParam
				mov		[edx].SPR_EDIT.fcancel,TRUE
			.endif
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DlgProc endp

end start
