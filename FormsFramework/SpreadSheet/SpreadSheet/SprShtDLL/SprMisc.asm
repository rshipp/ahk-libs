.code

StrLen proc lpSrc:DWORD

	mov		edx,lpSrc
	dec		edx
	xor		al,al
  @@:
	inc		edx
	cmp		al,[edx]
	jne		@b
	mov		eax,edx
	sub		eax,lpSrc
	ret

StrLen endp

StrCpy proc uses esi edi,lpDst:DWORD,lpSrc:DWORD

	mov		esi,lpSrc
	mov		edi,lpDst
  @@:
	mov		al,[esi]
	mov		[edi],al
	inc		esi
	inc		edi
	or		al,al
	jne		@b
	ret

StrCpy endp

MemMove proc uses ebx esi edi,lpSheet:DWORD,lpWhere:DWORD,nLen:DWORD

	mov		ebx,lpSheet
	mov		eax,nLen
	or		eax,eax
	je		Ex
	js		@f
	;Grow
	mov		esi,[ebx].SHEET.lprow
	add		eax,[esi].ROWDTA.len
	add		eax,32
	.if eax>[esi].ROWDTA.maxlen
		shr		eax,12
		inc		eax
		shl		eax,12
		mov		[esi].ROWDTA.maxlen,eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
		push	eax
		mov		edi,eax
		mov		ecx,[esi].ROWDTA.len
		rep movsb
		pop		esi
		mov		eax,esi
		sub		eax,[ebx].SHEET.lprow
		add		lpWhere,eax
		.if [ebx].SHEET.lpcol
			add		[ebx].SHEET.lpcol,eax
		.endif
		invoke GlobalFree,[ebx].SHEET.lprow
		movzx	ecx,[esi].ROWDTA.rown
		mov		eax,[ebx].SHEET.lprowmem
		lea		eax,[eax+ecx*4]
		mov		[eax],esi
		mov		[ebx].SHEET.lprow,esi
	.endif
	mov		eax,nLen
	add		esi,[esi].ROWDTA.len
	mov		edi,esi
	add		edi,eax
	mov		ecx,esi
	sub		ecx,lpWhere
	inc		ecx
	mov		eax,3
	std
	.if ecx>eax
		push	ecx
		shr		ecx,2
		sub		esi,eax
		sub		edi,eax
		rep movsd
		add		edi,eax
		add		esi,eax
		pop		ecx
	.endif
	and		ecx,eax
	.if ecx
		rep movsb
	.endif
	cld
	jmp		Ex
  @@:
	;Shrink
	mov		edi,lpWhere
	mov		esi,edi
	sub		esi,eax
	mov		ecx,[ebx].SHEET.lprow
	add		ecx,[ecx]

	sub		ecx,edi
	mov		eax,3
	.if ecx>eax
		push	ecx
		shr		ecx,2
		rep movsd
		pop		ecx
	.endif
	and		ecx,eax
	.if ecx
		rep movsb
	.endif
  Ex:
	mov		eax,nLen
	mov		edx,[ebx].SHEET.lprow
	.if edx
		add		[edx].ROWDTA.len,eax
	.endif
	mov		edx,[ebx].SHEET.lpcol
	.if edx
		add		[edx].COLDTA.len,ax
	.endif
	mov		eax,lpWhere
	ret

MemMove endp

