.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include SprTest3.inc

.code

start:
	invoke	GetModuleHandle,NULL
	mov	hInstance,eax
	invoke	InitCommonControls
    invoke LoadLibrary,offset szLibName
	.if eax
		mov		hSprShtDLL,eax
		invoke	DialogBoxParam,hInstance,IDD_MAIN,NULL,addr DlgProc,NULL
		invoke FreeLibrary,hSprShtDLL
	.endif
	invoke	ExitProcess,0

;########################################################################

DlgProc	proc	hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	buffer[MAX_PATH]:BYTE

	mov	eax,uMsg
	.if	eax==WM_INITDIALOG
		;initialization here
		invoke GetDlgItem,hWin,1001
		mov		hSht,eax
		invoke GetModuleFileName,hInstance,addr buffer,sizeof buffer
		invoke lstrlen,addr buffer
		.while eax
			dec		eax
			.if byte ptr buffer[eax]=='\'
				mov		byte ptr buffer[eax],0
				.break
			.endif
		.endw
		invoke SetCurrentDirectory,addr buffer

;		mov		rect.left,2
;		mov		rect.top,2
;		mov		rect.right,4
;		mov		rect.bottom,4
;		invoke SendMessage,hSht,SPRM_EXPANDCELL,0,addr rect
;		push	esi
;		push	edi
;		mov		esi,offset szData
;		mov		edi,5
;		.while byte ptr [esi]
;			mov		spri.flag,SPRIF_TYPE or SPRIF_DATA
;			mov		spri.col,2
;			mov		spri.row,edi
;			mov		spri.fmt.tpe,TPE_TEXT
;			mov		spri.lpdta,esi
;			invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
;			invoke lstrlen,esi
;			lea		esi,[esi+eax+1]
;			inc		edi
;		.endw
;		pop		edi
;		pop		esi
;		invoke SendMessage,hSht,SPRM_SETCOLWIDTH,0,40
		mov	eax,FALSE
		ret
	.elseif	eax==WM_COMMAND
		mov edx,wParam
		movzx eax,dx
		shr edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke SendMessage,hSht,SPRM_GETCELLSTRING,0,0
				.if eax
					invoke MessageBox,hWin,eax,eax,MB_OK
				.else
					invoke MessageBox,hWin,addr szNotExist,addr szLibName,MB_OK
				.endif
			.elseif eax==IDCANCEL
				invoke	SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==1002
				invoke SendMessage,hSht,SPRM_SAVEFILE,0,addr szFile
			.elseif eax==1003
				invoke SendMessage,hSht,SPRM_LOADFILE,0,addr szFile
			.elseif eax==1004
				invoke SendMessage,hSht,SPRM_GETCURRENTCELL,0,0
				mov		ecx,eax
				shr		ecx,16
				movzx	eax,ax
;				invoke SendMessage,hSht,SPRM_BLANKCELL,eax,ecx
				invoke SendMessage,hSht,SPRM_DELETECELL,eax,ecx
			.elseif eax==1005
				invoke SendMessage,hSht,SPRM_GETCELLSTRING,0,0
				PrintHex eax
				.if eax
					PrintStringByAddr eax
				.endif
			.endif
		.endif
	.elseif	eax==WM_CLOSE
		invoke	EndDialog,hWin,0
	.else
		mov	eax,FALSE
		ret
	.endif
	mov	eax,TRUE
	ret
DlgProc endp

end start
