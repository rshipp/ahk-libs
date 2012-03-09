.386
.model flat,stdcall
option casemap:none

include GrdDemo.inc

.code

start:

	invoke GetModuleHandle,NULL
	mov    hInstance,eax
	invoke GetCommandLine
	invoke InitCommonControls
	;Load the grid dll
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

	;Setup a class for the window
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
	;Register the class
	invoke RegisterClassEx,addr wc
	;Create the window
	invoke CreateDialogParam,hInstance,IDD_DLG1,NULL,addr WndProc,NULL
	invoke ShowWindow,hWnd,SW_SHOWNORMAL
	invoke UpdateWindow,hWnd
	;Message loop
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
	LOCAL	spri:SPR_ITEM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		;Save window handle
		push	hWin
		pop		hWnd
		;Get grid handle
		invoke GetDlgItem,hWin,IDC_SPR1
		mov		hSpr,eax
		;Empty the grid
		invoke SendMessage,hSpr,SPRM_SETROWCOUNT,0,0
		invoke SendMessage,hSpr,SPRM_SETCOLCOUNT,5,0
		;Setup headers
		mov		spri.flag,SPRIF_TEXTALIGN or SPRIF_DATA
		mov		spri.col,1
		mov		spri.row,0
		mov		spri.fmt.txtal,FMTA_LEFT or FMTA_MIDDLE
		mov		spri.lpdta,offset szCol1
		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
		mov		spri.col,4
		mov		spri.lpdta,offset szCol4
		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
		mov		spri.col,5
		mov		spri.lpdta,offset szCol5
		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
		mov		spri.col,2
		mov		spri.fmt.txtal,FMTA_RIGHT or FMTA_MIDDLE
		mov		spri.lpdta,offset szCol2
		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
		mov		spri.col,3
		mov		spri.lpdta,offset szCol3
		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri

		;Import some rows
		mov		spri.flag,SPRIF_TYPE or SPRIF_DATA
		mov		spri.col,2
		mov		spri.row,1
		mov		spri.fmt.tpe,TPE_INTEGER
		lea		eax,spri.row
		mov		spri.lpdta,eax
		mov		ecx,MAXROWS
		.while ecx
			push	ecx
			invoke SendMessage,hSpr,SPRM_IMPORTLINE,';',offset szDataLine
			invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
			inc		spri.row
			pop		ecx
			dec		ecx
		.endw
		;Set current cell
		invoke SendMessage,hSpr,SPRM_SETCURRENTCELL,1,1
		;Give the grid focus
		invoke SetFocus,hSpr
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		and		eax,0FFFFh
		.if eax==IDM_FILE_EXIT
			invoke SendMessage,hWin,WM_CLOSE,0,0
		.endif
	.elseif eax==WM_SETFOCUS
		invoke SetFocus,hSpr
		xor		eax,eax
		ret
	.elseif eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		invoke MoveWindow,hSpr,0,0,rect.right,rect.bottom,TRUE
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWin
	.elseif eax==WM_DESTROY
		invoke PostQuitMessage,NULL
	.endif
	invoke DefWindowProc,hWin,uMsg,wParam,lParam
	ret

WndProc endp

end start
