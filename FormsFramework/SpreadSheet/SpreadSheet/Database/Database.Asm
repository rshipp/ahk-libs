.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include Database.inc
include ODBC.asm

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
	.else
		invoke MessageBox,NULL,addr szLibName,addr szLibName,MB_OK
	.endif
	invoke	ExitProcess,0

;########################################################################

DlgProc	proc uses esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL buffer[MAX_PATH]:BYTE

	mov		eax,uMsg
	.if	eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hWnd,eax
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
		invoke GetDlgItem,hWin,IDC_SPR1
		mov		hSpr,eax
		invoke SendMessage,hSpr,SPRM_SETROWCOUNT,0,0
		invoke SendMessage,hSpr,SPRM_SETCOLCOUNT,5,0
		invoke SendMessage,hSpr,SPRM_SETCURRENTCELL,0,0
		; Setup column headers
		mov		esi,offset szColumns
		mov		edi,1
		.while dword ptr [esi]
			mov		spri.flag,SPRIF_TYPE or SPRIF_DATA or SPRIF_TEXTALIGN or SPRIF_WIDTH
			mov		spri.col,edi
			mov		spri.row,0
			mov		spri.fmt.tpe,TPE_COLHDR
			mov		spri.fmt.txtal,FMTA_LEFT
			mov		eax,[esi]
			mov		spri.wt,eax
			add		esi,4
			mov		spri.lpdta,esi
			invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
			invoke lstrlen,esi
			lea		esi,[esi+eax+1]
			inc		edi
		.endw
	.elseif	eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNCREATE
				invoke GetFileAttributes,addr szDatabase
				.if eax==INVALID_HANDLE_VALUE
					invoke ODBCCreateDatabase
				.else
					invoke MessageBox,hWin,addr szExists,addr szLibName,MB_OK
				.endif
			.elseif eax==IDC_BTNOPEN
				invoke GetFileAttributes,addr szDatabase
				.if eax==INVALID_HANDLE_VALUE
					invoke MessageBox,hWin,addr szNotExists,addr szLibName,MB_OK
				.else
					invoke ODBCDisconnect
					invoke ODBCConnect
					.if !eax
						invoke ODBCGetData
					.endif
				.endif
			.elseif eax==IDC_BTNADD
				.if hConn
					invoke ODBCAddRow
				.else
					invoke MessageBox,hWin,addr szNotOpen,addr szLibName,MB_OK
				.endif
			.elseif eax==IDC_BTNDELETE
				.if hConn
					invoke SendMessage,hSpr,SPRM_GETCURRENTCELL,0,0
					shr		eax,16
					mov		spri.col,1
					mov		spri.row,eax
					invoke SendMessage,hSpr,SPRM_GETCELLDATA,0,addr spri
					invoke ODBCDeleteRow,spri.row,spri.lpdta
				.else
					invoke MessageBox,hWin,addr szNotOpen,addr szLibName,MB_OK
				.endif
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		mov		esi,lParam
		mov		eax,[esi].NMHDR.hwndFrom
		.if eax==hSpr
			mov		eax,[esi].NMHDR.code
			.if eax==SPRN_AFTEREDIT
				;Get pointer to SPR_ITEM
				mov		edi,[esi].SPR_EDIT.lpspri
				mov		spri.col,1
				mov		eax,[edi].SPR_ITEM.row
				mov		spri.row,eax
				invoke SendMessage,hSpr,SPRM_GETCELLDATA,0,addr spri
				mov		eax,[edi].SPR_ITEM.col
				mov		edx,[edi].SPR_ITEM.lpdta
				mov		ecx,spri.lpdta
				.if eax==2
					invoke ODBCUpdate,ecx,addr szLastName,edx
				.elseif eax==3
					invoke ODBCUpdate,ecx,addr szFirstName,edx
				.elseif eax==4
					invoke ODBCUpdate,ecx,addr szAddress,edx
				.elseif eax==5
					invoke ODBCUpdate,ecx,addr szPhone,edx
				.endif
			.elseif eax==SPRN_BEFOREEDIT
				mov		edi,[esi].SPR_EDIT.lpspri
				.if [edi].SPR_ITEM.col==1
					; Column ID is not editable
					mov		[esi].SPR_EDIT.fcancel,TRUE
				.endif
			.endif
		.endif
	.elseif	eax==WM_CLOSE
		invoke ODBCDisconnect
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DlgProc endp

end start
