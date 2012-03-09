.386
.model flat,stdcall
option casemap:none

include SprTab.inc

.code

start:

	invoke GetModuleHandle, NULL
	mov		hInstance, eax
	invoke InitCommonControls
    invoke LoadLibrary,offset szLibName
	.if eax
		mov		hSprShtDLL,eax
		invoke DialogBoxParam,hInstance,IDD_TABTEST,NULL,addr DlgProc,NULL
		invoke FreeLibrary,hSprShtDLL
	.endif
	invoke ExitProcess,eax 

TabProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
	.elseif eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		invoke GetDlgItem,hWin,2001
		invoke MoveWindow,eax,0,0,rect.right,rect.bottom,TRUE
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

TabProc endp

DlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ts:TC_ITEM
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		and		eax,0FFFFh
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,0,0
			.elseif eax==IDOK
				invoke SendMessage,hWin,WM_CLOSE,0,0
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		mov		eax,lParam
		mov		eax,[eax].NMHDR.code
		.if eax==TCN_SELCHANGE
			;Tab selection
			invoke SendMessage,hTab,TCM_GETCURSEL,0,0
			.if eax!=SelTab
				push	eax
				invoke ShowWindow,[hTabDlg+eax*4],SW_SHOWDEFAULT
				mov		eax,SelTab
				invoke ShowWindow,[hTabDlg+eax*4],SW_HIDE
				pop		eax
				mov		SelTab,eax
			.endif
		.endif
	.elseif eax==WM_INITDIALOG
		;Create the tabs
		invoke GetDlgItem,hWin,IDC_TAB1
		mov		hTab,eax
		mov		ts.imask,TCIF_TEXT
		mov		ts.lpReserved1,0
		mov		ts.lpReserved2,0
		mov		ts.iImage,-1
		mov		ts.lParam,0
		mov		ts.pszText,offset TabTitle1
		mov		ts.cchTextMax,sizeof TabTitle1
		invoke SendMessage,hTab,TCM_INSERTITEM,0,addr ts
		mov		ts.pszText,offset TabTitle2
		mov		ts.cchTextMax,sizeof TabTitle2
		invoke SendMessage,hTab,TCM_INSERTITEM,1,addr ts
		mov		ts.pszText,offset TabTitle3
		mov		ts.cchTextMax,sizeof TabTitle3
		invoke SendMessage,hTab,TCM_INSERTITEM,2,addr ts
		mov		ts.pszText,offset TabTitle4
		mov		ts.cchTextMax,sizeof TabTitle4
		invoke SendMessage,hTab,TCM_INSERTITEM,3,addr ts
		;Create the tab dialogs
		invoke CreateDialogParam,hInstance,IDD_TAB1,hTab,addr TabProc,0
		mov hTabDlg,eax
		invoke CreateDialogParam,hInstance,IDD_TAB1,hTab,addr TabProc,0
		mov hTabDlg[4],eax
		invoke CreateDialogParam,hInstance,IDD_TAB1,hTab,addr TabProc,0
		mov hTabDlg[8],eax
		invoke CreateDialogParam,hInstance,IDD_TAB1,hTab,addr TabProc,0
		mov hTabDlg[12],eax
		invoke ShowWindow,hTabDlg,SW_SHOWDEFAULT
	.elseif eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		sub		rect.bottom,20
		sub		rect.right,140
		invoke GetDlgItem,hWin,1
		invoke MoveWindow,eax,rect.right,rect.bottom,58,19,TRUE
		add		rect.right,70
		invoke GetDlgItem,hWin,2
		invoke MoveWindow,eax,rect.right,rect.bottom,58,19,TRUE

		invoke GetClientRect,hWin,addr rect
		sub		rect.bottom,22
		invoke MoveWindow,hTab,0,0,rect.right,rect.bottom,TRUE
		sub		rect.right,6
		sub		rect.bottom,24
		invoke MoveWindow,hTabDlg,2,22,rect.right,rect.bottom,TRUE
		invoke MoveWindow,hTabDlg[4],2,22,rect.right,rect.bottom,TRUE
		invoke MoveWindow,hTabDlg[8],2,22,rect.right,rect.bottom,TRUE
		invoke MoveWindow,hTabDlg[12],2,22,rect.right,rect.bottom,TRUE
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DlgProc endp

end start
