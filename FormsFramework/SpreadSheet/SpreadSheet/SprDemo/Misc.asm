
.code

GetColor proc hWin:DWORD,dwRGB:DWORD
	LOCAL	lpcc:CHOOSECOLOR

    mov     lpcc.lStructSize,sizeof CHOOSECOLOR
    mov     eax,hWin
    mov     lpcc.hwndOwner,eax
    mov     eax,hInstance
    mov     lpcc.hInstance,eax
    mov     lpcc.lpCustColors,offset CustColors
    mov     lpcc.Flags,CC_FULLOPEN or CC_RGBINIT
    mov     lpcc.lCustData,offset CustColors
	mov		lpcc.lpfnHook,0
	mov		lpcc.lpTemplateName,0
	mov		eax,dwRGB
	mov     lpcc.rgbResult,eax
    invoke ChooseColor,addr lpcc
	.if eax
		mov     eax,lpcc.rgbResult
	.else
		mov		eax,-1
	.endif
	ret

GetColor endp

SetStyle proc dwStyle:DWORD

	invoke GetWindowLong,hSht,GWL_STYLE
	xor		eax,dwStyle
	invoke SetWindowLong,hSht,GWL_STYLE,eax
	invoke SendMessage,hSht,WM_SIZE,0,0
	ret

SetStyle endp

LoadFile proc hWin:HWND

	invoke RtlZeroMemory,offset ofn,sizeof ofn
	mov		ofn.lStructSize,sizeof ofn
	push	hWin
	pop		ofn.hwndOwner
	push	hInstance
	pop		ofn.hInstance
	mov		ofn.lpstrFilter,offset szFilter
	mov		ofn.lpstrFile,offset FileName
	mov		ofn.nMaxFile,sizeof FileName
	mov		ofn.lpstrDefExt,offset szSprExt
	mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
	invoke GetOpenFileName,offset ofn
	.if eax
		invoke SendMessage,hSht,SPRM_LOADFILE,0,offset FileName
	.endif
	ret

LoadFile endp

SaveFileAs proc hWin:HWND

    invoke RtlZeroMemory,offset ofn,sizeof ofn
	mov ofn.lStructSize,sizeof ofn
	push	hWin
	pop		ofn.hwndOwner
	push	hInstance
	pop		ofn.hInstance
	mov		ofn.lpstrFilter,offset szFilter
	mov		ofn.lpstrFile,offset AltFileName
	mov		ofn.nMaxFile,sizeof AltFileName
	mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST or OFN_OVERWRITEPROMPT
    mov		ofn.lpstrDefExt, offset szSprExt
	invoke GetSaveFileName,offset ofn
	.if eax
		invoke lstrcpy,offset FileName,offset AltFileName
		invoke SendMessage,hSht,SPRM_SAVEFILE,0,offset FileName
	.endif
	ret

SaveFileAs endp

