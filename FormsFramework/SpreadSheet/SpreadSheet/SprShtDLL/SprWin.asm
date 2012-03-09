.code

DrawCurPos proc uses ebx esi,lpSheet:DWORD,lpWin:DWORD,hDC:HDC,lpRect:DWORD
	LOCAL	buffer[16]:BYTE

	mov		ebx,lpSheet
	mov		esi,lpWin
	mov		edx,[esi].WIN.ccol
	mov		ecx,[esi].WIN.crow
	mov		buffer,0
	.if edx!=[esi].WIN.mcol || ecx!=[esi].WIN.mrow
		invoke FindCell,ebx,[esi].WIN.mcol,0
		lea		eax,[eax].COLDTA.fmt.tpe[3]
		invoke StrCpy,addr buffer,eax
		invoke StrLen,addr buffer
		invoke DwToAscii,[esi].WIN.mrow,addr buffer[eax]
		invoke StrLen,addr buffer
		mov		word ptr buffer[eax],':'
	.endif
	invoke FindCell,ebx,[esi].WIN.ccol,0
	lea		eax,[eax].COLDTA.fmt.tpe[3]
	invoke lstrcat,addr buffer,eax
	invoke StrLen,addr buffer
	invoke DwToAscii,[esi].WIN.crow,addr buffer[eax]
	invoke DrawText,hDC,addr buffer,-1,lpRect,DT_LEFT or DT_SINGLELINE
	ret

DrawCurPos endp

DrawCellText proc uses ebx esi edi,lpSheet:DWORD,lpWin:DWORD,hDC:HDC,lpRect:DWORD
	LOCAL	buffer[512]:BYTE

	mov		ebx,lpSheet
	mov		esi,lpWin
	invoke FindCell,ebx,[esi].WIN.ccol,[esi].WIN.crow
	.if eax
		mov		edi,eax
		mov		al,[edi].COLDTA.fmt.tpe
		mov		dl,al
		and		dl,0F0h
		and		al,TPE_TYPEMASK
		.if al==TPE_TEXT || al==TPE_TEXTMULTILINE || al==TPE_HYPERLINK; || al==TPE_BUTTON or TPE_TEXT || al==TPE_WIDEBUTTON or TPE_TEXT
			invoke DrawText,hDC,addr [edi].COLDTA.fmt.tpe[1],-1,lpRect,DT_LEFT or DT_BOTTOM or DT_SINGLELINE
		.elseif al==TPE_INTEGER && dl==TPE_DATE
			mov		edx,dword ptr [edi].COLDTA.fmt.tpe[1]
			invoke DateToString,ebx,edx,addr buffer,sizeof buffer
			invoke DrawText,hDC,addr buffer,-1,lpRect,DT_LEFT or DT_BOTTOM or DT_SINGLELINE
		.elseif al==TPE_INTEGER || al==TPE_CHECKBOX || al==TPE_COMBOBOX || al==TPE_OWNERDRAWINTEGER
			invoke DwToAscii,dword ptr [edi].COLDTA.fmt.tpe[1],addr buffer
			invoke DrawText,hDC,addr buffer,-1,lpRect,DT_LEFT or DT_BOTTOM or DT_SINGLELINE
		.elseif al==TPE_FLOAT
			invoke FpToAscii,addr [edi].COLDTA.fmt.tpe[1],addr buffer,FALSE
			invoke DrawText,hDC,addr buffer,-1,lpRect,DT_LEFT or DT_BOTTOM or DT_SINGLELINE
		.elseif al==TPE_FORMULA
			invoke DecompFormula,addr [edi].COLDTA.fmt.tpe[1+10],addr buffer
			invoke DrawText,hDC,addr buffer,-1,lpRect,DT_LEFT or DT_BOTTOM or DT_SINGLELINE
		.elseif al==TPE_GRAPH
			invoke DecompFormula,addr [edi].COLDTA.fmt.tpe[1+4],addr buffer
			invoke DrawText,hDC,addr buffer,-1,lpRect,DT_LEFT or DT_BOTTOM or DT_SINGLELINE
		.elseif al==TPE_OWNERDRAWBLOB
			movzx	eax,word ptr [edi].COLDTA.fmt.tpe[1]
			invoke wsprintf,addr buffer,addr szBlob,eax
			invoke DrawText,hDC,addr buffer,-1,lpRect,DT_LEFT or DT_BOTTOM or DT_SINGLELINE
		.endif
	.endif
	ret

DrawCellText endp

DrawInput proc uses ebx esi,lpSheet:DWORD,lpWin:DWORD
	LOCAL	rect:RECT
	LOCAL	hDC:HDC
	LOCAL	mDC:HDC

	mov		ebx,lpSheet
	mov		eax,[ebx].SHEET.winst
	and		eax,SPS_STATUS
	.if eax
		mov		esi,lpWin
		invoke GetDC,[ebx].SHEET.hwnd
		mov		hDC,eax
		invoke GetClientRect,[ebx].SHEET.hwnd,addr rect
		mov		eax,STATUSHT
		test	[ebx].SHEET.winst,SPS_GRIDMODE
		je		@f
		shr		eax,1
	  @@:
		.if [ebx].SHEET.fedt
			sub		eax,INPHT
		.endif
		mov		rect.bottom,eax
		invoke CreateCompatibleDC,hDC
		mov		mDC,eax
		invoke CreateCompatibleBitmap,hDC,rect.right,rect.bottom
		push	eax
		invoke SelectObject,mDC,eax
		push	eax
		invoke SelectObject,mDC,[ebx].SHEET.ofont.hfont
		push	eax
		invoke SetBkMode,mDC,TRANSPARENT
	
		invoke GetStockObject,LTGRAY_BRUSH
		invoke FillRect,mDC,addr rect,eax
		invoke SetTextColor,mDC,0
		invoke MoveToEx,mDC,0,rect.top,NULL
		invoke LineTo,mDC,rect.right,rect.top
		inc		rect.left
		inc		rect.top
		dec		rect.bottom
		test	[ebx].SHEET.winst,SPS_GRIDMODE
		jne		@f
		invoke DrawCurPos,ebx,esi,mDC,addr rect
	  @@:
		.if ![ebx].SHEET.fedt
			invoke DrawCellText,ebx,esi,mDC,addr rect
		.endif
		invoke GetClientRect,[ebx].SHEET.hwnd,addr rect
		mov		eax,STATUSHT
		test	[ebx].SHEET.winst,SPS_GRIDMODE
		je		@f
		shr		eax,1
	  @@:
		mov		edx,rect.bottom
		sub		edx,eax
		.if [ebx].SHEET.fedt
			sub		eax,INPHT
		.endif
		mov		rect.bottom,eax
		invoke BitBlt,hDC,0,edx,rect.right,rect.bottom,mDC,0,0,SRCCOPY
		;Font
		pop		eax
		invoke SelectObject,mDC,eax
		;Bitmap
		pop		eax
		invoke SelectObject,mDC,eax
		;Bitmap
		pop		eax
		invoke DeleteObject,eax
		invoke DeleteDC,mDC
		invoke ReleaseDC,[ebx].SHEET.hwnd,hDC
	.endif
	ret

DrawInput endp

DrawWin proc uses ebx esi,lpSheet:DWORD,lpWin:DWORD
	LOCAL	rect:RECT
	LOCAL	rect1:RECT
	LOCAL	rect2:RECT

	mov		ebx,lpSheet
	xor		ecx,ecx
	.while ecx<=[ebx].SHEET.gfmt.nrows
		push	ecx
		mov		esi,[ebx].SHEET.lprowmem
		lea		esi,[esi+ecx*4]
		mov		esi,[esi]
		.if esi
			mov		eax,[esi].ROWDTA.len
			.if eax
				add		esi,sizeof ROWDTA-4
			  Nx2:
				movzx	eax,[esi].COLDTA.len
				.if eax
					.if [esi].COLDTA.expx || [esi].COLDTA.expy
						or		[esi].COLDTA.state,STATE_REDRAW
					.endif
					add		esi,eax
					jmp		Nx2
				.endif
			.endif
		.endif
		pop		ecx
		inc		ecx
	.endw
	mov		esi,lpWin
	mov		[ebx].SHEET.ty,0
	invoke GetCellRect,ebx,esi,[esi].WIN.lcol,[esi].WIN.lrow,addr rect
	invoke GetCellRect,ebx,esi,[esi].WIN.tcol,[esi].WIN.trow,addr rect1
	mov		eax,[esi].WIN.trow
	mov		[ebx].SHEET.tr,eax
	mov		eax,rect1.top
	mov		[ebx].SHEET.ty,eax
	mov		eax,rect.right
	sub		rect1.left,eax
	sub		rect1.right,eax
	mov		eax,rect.bottom
	sub		rect1.top,eax
	sub		rect1.bottom,eax
	;Draw scroll area
	mov		edx,[esi].WIN.trow
	.while TRUE
		mov		ecx,[esi].WIN.tcol
		.while TRUE
			push	ecx
			push	edx
			;Cell Rect
			push	ecx
			push	edx
			invoke GetCellRect,ebx,esi,ecx,edx,addr rect2
			mov		eax,rect1.left
			sub		rect2.left,eax
			sub		rect2.right,eax
			mov		eax,rect1.top
			sub		rect2.top,eax
			sub		rect2.bottom,eax
			pop		edx
			pop		ecx
			invoke DrawCell,ebx,esi,ecx,edx,addr rect2
			pop		edx
			pop		ecx
		  .break .if eax
			inc		ecx
		.endw
	  .break .if eax>=8
		inc		edx
	.endw
	;Draw locked area
	mov		edx,0
	.while edx<=[esi].WIN.lrow
		mov		ecx,0
		.while ecx<=[esi].WIN.lcol
			push	ecx
			push	edx
			;Cell Rect
			push	ecx
			push	edx
			invoke GetCellRect,ebx,esi,ecx,edx,addr rect
			pop		edx
			pop		ecx
			invoke DrawCell,ebx,esi,ecx,edx,addr rect
			pop		edx
			pop		ecx
		  .break .if eax
			inc		ecx
		.endw
	  .break .if eax>=8
		inc		edx
	.endw
	;Draw locked rows area
	mov		edx,0
	.while edx<=[esi].WIN.lrow
		mov		ecx,[esi].WIN.tcol
		.while TRUE
			push	ecx
			push	edx
			;Cell Rect
			push	ecx
			push	edx
			invoke GetCellRect,ebx,esi,ecx,edx,addr rect2
			mov		eax,rect1.left
			sub		rect2.left,eax
			sub		rect2.right,eax
			pop		edx
			pop		ecx
			invoke DrawCell,ebx,esi,ecx,edx,addr rect2
			pop		edx
			pop		ecx
		  .break .if eax
			inc		ecx
		.endw
	  .break .if eax>=8
		inc		edx
	.endw
	;Draw locked cols area
	mov		edx,[esi].WIN.trow
	.while TRUE
		mov		ecx,0
		.while ecx<=[esi].WIN.lcol
			push	ecx
			push	edx
			;Cell Rect
			push	ecx
			push	edx
			invoke GetCellRect,ebx,esi,ecx,edx,addr rect2
			mov		eax,rect1.top
			sub		rect2.top,eax
			sub		rect2.bottom,eax
			pop		edx
			pop		ecx
			invoke DrawCell,ebx,esi,ecx,edx,addr rect2
			pop		edx
			pop		ecx
		  .break .if eax
			inc		ecx
		.endw
	  .break .if eax>=8
		inc		edx
	.endw
	ret

DrawWin endp

CreateWin proc uses ebx esi,lpSheet:DWORD,lpWin:DWORD

	mov		ebx,lpSheet
	mov		esi,lpWin
	mov		eax,[ebx].SHEET.winst
	mov		edx,WS_CHILD or WS_VISIBLE or WS_CLIPSIBLINGS
	test	eax,SPS_VSCROLL
	je		@f
	or		edx,WS_VSCROLL
  @@:
	test	eax,SPS_HSCROLL
	je		@f
	or		edx,WS_HSCROLL
  @@:
	invoke CreateWindowEx,NULL,offset szClassNameSheetWin,NULL,edx,0,0,0,0,[ebx].SHEET.hwnd,[esi].WIN.nwin,hInstance,0
	mov		[esi].WIN.hwin,eax
	push	eax
	invoke SetFocus,eax
	pop		eax
	ret

CreateWin endp

CreateVSplit proc uses ebx esi,lpSheet:DWORD,lpWin:DWORD
	LOCAL	rect:RECT
	LOCAL	sbs:DWORD

	mov		ebx,lpSheet
	mov		esi,lpWin
	mov		sbs,0
	mov		eax,[ebx].SHEET.winst
	test	eax,SPS_VSCROLL
	je		@f
	mov		sbs,SBSIZE
  @@:
	mov		eax,[esi].WIN.nwin
	mov		edx,[esi+sizeof WIN].WIN.act
	.if eax<WINMAX-1
		mov		eax,[esi].WIN.ccol
		.if eax>[esi].WIN.tcol && edx==-1
			invoke GetRealCellRect,ebx,esi,addr rect
			mov		edx,esi
			add		edx,sizeof WIN

			mov		eax,rect.left
			add		eax,sbs
			add		eax,[esi].WIN.rect.left
			mov		[edx].WIN.rect.left,eax
			mov		eax,[esi].WIN.rect.top
			mov		[edx].WIN.rect.top,eax

			mov		eax,[esi].WIN.ccol
			mov		[edx].WIN.ccol,eax
			mov		[edx].WIN.mcol,eax
			mov		[edx].WIN.tcol,eax
			mov		eax,[esi].WIN.crow
			mov		[edx].WIN.crow,eax
			mov		[edx].WIN.mrow,eax
			mov		eax,[esi].WIN.trow
			mov		[edx].WIN.trow,eax
			mov		eax,[esi].WIN.lrow
			mov		[edx].WIN.lrow,eax
			mov		[esi].WIN.act,0
			mov		[edx].WIN.act,1
			mov		[edx].WIN.sync,0
			or		[esi].WIN.sync,1
			mov		esi,edx
			inc		[ebx].SHEET.nwin
			invoke CreateWin,ebx,esi
			invoke SendMessage,[ebx].SHEET.hwnd,WM_SIZE,0,0
			invoke SetFocus,[esi].WIN.hwin
		.endif
	.endif
	ret

CreateVSplit endp

CreateHSplit proc uses ebx esi,lpSheet:DWORD,lpWin:DWORD
	LOCAL	rect:RECT
	LOCAL	sbs:DWORD

	mov		ebx,lpSheet
	mov		esi,lpWin
	mov		sbs,0
	mov		eax,[ebx].SHEET.winst
	test	eax,SPS_HSCROLL
	je		@f
	mov		sbs,SBSIZE
  @@:
	mov		eax,[esi].WIN.nwin
	mov		edx,[esi+sizeof WIN].WIN.act
	.if eax<WINMAX-1 && edx==-1
		mov		eax,[esi].WIN.crow
		.if eax>[esi].WIN.trow
			invoke GetRealCellRect,ebx,esi,addr rect
			mov		edx,esi
			add		edx,sizeof WIN

			mov		eax,rect.top
			add		eax,sbs
			add		eax,[esi].WIN.rect.top
			mov		[edx].WIN.rect.top,eax
			mov		eax,[esi].WIN.rect.left
			mov		[edx].WIN.rect.left,eax

			mov		eax,[esi].WIN.crow
			mov		[edx].WIN.crow,eax
			mov		[edx].WIN.mrow,eax
			mov		[edx].WIN.trow,eax
			mov		eax,[esi].WIN.ccol
			mov		[edx].WIN.ccol,eax
			mov		[edx].WIN.mcol,eax
			mov		eax,[esi].WIN.tcol
			mov		[edx].WIN.tcol,eax
			mov		eax,[esi].WIN.lcol
			mov		[edx].WIN.lcol,eax
			mov		[esi].WIN.act,0
			mov		[edx].WIN.act,1
			mov		[edx].WIN.sync,0
			or		[esi].WIN.sync,2
			mov		esi,edx
			inc		[ebx].SHEET.nwin
			invoke CreateWin,ebx,esi
			invoke SendMessage,[ebx].SHEET.hwnd,WM_SIZE,0,0
			invoke SetFocus,[esi].WIN.hwin
		.endif
	.endif
	ret

CreateHSplit endp

CloseSplit proc uses ebx esi,lpSheet:DWORD,lpWin:DWORD
	LOCAL	nWin:DWORD

	mov		ebx,lpSheet
	mov		esi,lpWin
	mov		eax,[ebx].SHEET.nwin
	.if eax
		mov		eax,esi
		add		eax,sizeof WIN
		mov		eax,[eax].WIN.act
		.if eax==-1
			mov		edx,esi
			sub		edx,sizeof WIN
			mov		[edx].WIN.sync,0
			invoke DestroyWindow,[esi].WIN.hwin
			dec		[ebx].SHEET.nwin
			mov		[esi].WIN.act,-1
			xor		eax,eax
			mov		[esi].WIN.tcol,eax
			mov		[esi].WIN.trow,eax
			mov		[esi].WIN.ccol,eax
			mov		[esi].WIN.crow,eax
			mov		[esi].WIN.mcol,eax
			mov		[esi].WIN.mrow,eax
			mov		[esi].WIN.lcol,eax
			mov		[esi].WIN.lrow,eax
			mov		edx,esi
			sub		edx,sizeof WIN
			invoke SetFocus,[edx].WIN.hwin
			invoke SendMessage,[ebx].SHEET.hwnd,WM_SIZE,0,0
		.endif
	.endif
	ret

CloseSplit endp

SyncSplitt proc uses ebx esi,lpSheet:DWORD,lpWin:DWORD,fSplitt:DWORD

	mov		eax,[ebx].SHEET.nwin
	.if eax
		mov		edx,esi
		sub		edx,sizeof WIN
		.if fSplitt
			mov		eax,[esi].WIN.rect.top
			.if eax==[edx].WIN.rect.top
				or		[edx].WIN.sync,1
			.else
				or		[edx].WIN.sync,2
			.endif
		.else
			mov		eax,[esi].WIN.rect.top
			.if eax==[edx].WIN.rect.top
				and		[edx].WIN.sync,-1 xor 1
			.else
				and		[edx].WIN.sync,-1 xor 2
			.endif
		.endif
	.endif
	ret

SyncSplitt endp
