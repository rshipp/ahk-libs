
.code

GetExp proc uses edi,lpStr:DWORD,lpExp:DWORD

	mov		edi,lpStr
	mov		ecx,lpExp
	mov		byte ptr [ecx],0
	dec		edx
  @@:
	inc		edi
	mov		al,[edi]
	.if al=='e'
		invoke StrCpy,lpExp,edi
		mov		byte ptr [edi],0
	.elseif al
		jmp		@b
	.endif
	ret

GetExp endp

FormatNum proc uses edi,lpStr:DWORD,nType:DWORD,nDecimal:DWORD
	LOCAL	buffer[64]:BYTE
	LOCAL	ebuffer[32]:BYTE

	mov		edi,lpStr
	mov		eax,nDecimal
	.if eax!=FMTD_ALL
		.if eax==FMTD_SCI
			mov		nDecimal,9
		.endif
		.if nType==TPE_INTEGER
			.if eax
				invoke StrLen,edi
				add		edi,eax
				mov		byte ptr [edi],'.'
				inc		edi
				mov		ecx,nDecimal
				mov		al,'0'
				rep stosb
				mov		byte ptr [edi],0
			.endif
		.else
			invoke GetExp,edi,addr ebuffer
			dec		edi
		  @@:
			inc		edi
			mov		al,[edi]
			or		al,al
			je		NoDecimal
			cmp		al,'.'
			jne		@b
			mov		ecx,nDecimal
			.if ecx
			  @@:
				inc		edi
				mov		al,[edi]
				.if al
					dec		ecx
					jne		@b
					inc		edi
					mov		al,[edi]
					.if al>='5'
						call Increment
						xor		ecx,ecx
					.endif
				.endif
				mov		al,'0'
				rep stosb
			.else
				mov		al,[edi]
				.if al
					inc		edi
					mov		al,[edi]
					.if al>='5'
						call Increment
					.endif
				.endif
				dec		edi
			.endif
			mov		byte ptr [edi],0
			invoke lstrcat,lpStr,addr ebuffer
		.endif
	.endif
	ret
  NoDecimal:
  	.if nDecimal
		mov		byte ptr [edi],'.'
		inc		edi
		mov		ecx,nDecimal
		mov		al,'0'
		rep stosb
  	.endif
	mov		byte ptr [edi],0
	invoke lstrcat,lpStr,addr ebuffer
	ret

Increment:
	push	edi
	xor		ecx,ecx
  @@:
	dec		edi
	mov		al,[edi]
	cmp		al,'.'
	je		@b
	cmp		al,'9'
	jne		@f
	mov		byte ptr [edi],'0'
	.if edi!=lpStr
		cmp		byte ptr [edi-1],'-'
		jne		@b
	.endif
	invoke StrCpy,addr buffer,edi
	inc		edi
	invoke StrCpy,edi,addr buffer
	dec		edi
	xor		ecx,ecx
	inc		ecx
  @@:
	inc		byte ptr [edi]
	pop		edi
	add		edi,ecx
	retn

FormatNum endp

Rotate proc uses esi edi,hBmpDest:DWORD,hBmpSrc:DWORD,x:DWORD,y:DWORD,nRotate:DWORD
	LOCAL	bmd:BITMAP
	LOCAL	nbitsd:DWORD
	LOCAL	hmemd:DWORD
	LOCAL	bms:BITMAP
	LOCAL	nbitss:DWORD
	LOCAL	hmems:DWORD

	;Get info on destination bitmap
	invoke GetObject,hBmpDest,sizeof BITMAP,addr bmd
	mov		eax,bmd.bmWidthBytes
	mov		edx,bmd.bmHeight
	mul		edx
	mov		nbitsd,eax
	;Allocate memory for destination bitmap bits
	invoke GlobalAlloc,GMEM_FIXED,nbitsd
	mov		hmemd,eax
	;Get the destination bitmap bits
	invoke GetBitmapBits,hBmpDest,nbitsd,hmemd
	;Get info on source bitmap
	invoke GetObject,hBmpSrc,sizeof BITMAP,addr bms
	mov		eax,bms.bmWidthBytes
	mov		edx,bms.bmHeight
	mul		edx
	mov		nbitss,eax
	;Allocate memory for source bitmap bits
	invoke GlobalAlloc,GMEM_FIXED,nbitss
	mov		hmems,eax
	;Get the source bitmap bits
	invoke GetBitmapBits,hBmpSrc,nbitss,hmems
	;Copy the pixels one by one
	xor		edx,edx
	.while edx<bms.bmHeight
		xor		ecx,ecx
		.while ecx<bms.bmWidth
			call	CopyPix
			inc		ecx
		.endw
		inc		edx
	.endw
	;Copy back the destination bitmap bits
	invoke SetBitmapBits,hBmpDest,nbitsd,hmemd
	;Free allocated memory
	invoke GlobalFree,hmems
	invoke GlobalFree,hmemd
	ret

CopyPix:
	push	ecx
	push	edx
	mov		esi,hmems
	push	edx
	mov		eax,bms.bmWidthBytes
	mul		edx
	add		esi,eax
	movzx	eax,bms.bmBitsPixel
	shr		eax,3
	mul		ecx
	add		esi,eax
	pop		edx
	mov		eax,nRotate
	.if eax==1
		;Rotate 90 degrees
		sub		edx,bms.bmHeight
		neg		edx
		xchg	ecx,edx
	.elseif eax==2
		;Rotate 180 degrees
		sub		edx,bms.bmHeight
		neg		edx
		sub		ecx,bms.bmWidth
		neg		ecx
	.elseif eax==3
		;Rotate 270 degrees
		sub		ecx,bms.bmWidth
		neg		ecx
		xchg	ecx,edx
	.endif
	;Add the destination offsets
	add		ecx,x
	add		edx,y
	.if  ecx<bmd.bmWidth && edx<bmd.bmHeight
		;Calculate destination adress
		mov		edi,hmemd
		mov		eax,bmd.bmWidthBytes
		mul		edx
		add		edi,eax
		movzx	eax,bmd.bmBitsPixel
		shr		eax,3
		xchg	eax,ecx
		mul		ecx
		add		edi,eax
		;And copy the byte(s)
		rep movsb
	.endif
	pop		edx
	pop		ecx
	retn

Rotate endp

DrawGraph proc uses ebx esi edi,lpSheet:DWORD,lpCell:DWORD,hDC:HDC,mDC:HDC,lpRect:DWORD
	LOCAL	cfnt:DWORD
	LOCAL	tDC:HDC
	LOCAL	hbr:DWORD
	LOCAL	hbmd:DWORD
	LOCAL	hbm:DWORD
	LOCAL	grp:GRAPH
	LOCAL	rect:RECT
	LOCAL	dwval:DWORD
	LOCAL	fpval:TBYTE

	LOCAL	lpgtxt:DWORD
	LOCAL	gtxt[17]:GTEXT
	LOCAL	lpggx:DWORD
	LOCAL	ggx[16]:GGX
	LOCAL	lpgfx:DWORD
	LOCAL	gfx[16]:GFX

	LOCAL	nCol:DWORD
	LOCAL	nRow:DWORD
	LOCAL	xval:DWORD
	LOCAL	fx:DWORD
	LOCAL	fy:DWORD
	LOCAL	buffer[32]:BYTE
	LOCAL	txtrect:RECT

	lea		eax,gtxt+sizeof GTEXT
	mov		lpgtxt,eax
	invoke RtlZeroMemory,addr gtxt,sizeof gtxt
	lea		eax,ggx
	mov		lpggx,eax
	invoke RtlZeroMemory,addr ggx,sizeof ggx
	lea		eax,gfx
	mov		lpgfx,eax
	invoke RtlZeroMemory,addr gfx,sizeof gfx
	xor		eax,eax
	mov		dword ptr funx,eax
	mov		dword ptr funx+4,eax
	mov		word ptr funx+8,ax
	mov		ebx,lpSheet
	mov		edi,lpCell
	mov		esi,lpRect
	movzx	eax,[edi].COLDTA.fmt.fnt
	.if al==-1
		mov		al,[ebx].SHEET.gfmt.cell.fnt
	.endif
	mov		cfnt,eax
	mov		grp.rc.left,0
	mov		grp.grc.left,20
	mov		grp.rc.top,0
	mov		grp.grc.top,10
	mov		eax,[esi].RECT.right
	sub		eax,[esi].RECT.left
	mov		grp.rc.right,eax
	mov		grp.grc.right,eax
	sub		grp.grc.right,10
	mov		edx,[esi].RECT.bottom
	sub		edx,[esi].RECT.top
	mov		grp.rc.bottom,edx
	mov		grp.grc.bottom,edx
	sub		grp.grc.bottom,20
	invoke CreateCompatibleBitmap,hDC,eax,edx
	mov		hbmd,eax
	mov		dword ptr [edi].COLDTA.fmt.tpe[1],eax
	invoke SelectObject,mDC,eax
	push	eax
	mov		eax,[edi].COLDTA.fmt.bckcol
	.if eax==-1
		mov		eax,[ebx].SHEET.gfmt.cell.bckcol
	.endif
	invoke CreateSolidBrush,eax
	mov		hbr,eax
	invoke FillRect,mDC,addr grp.rc,eax
	dec		grp.rc.bottom
	dec		grp.rc.right
	mov		eax,[ebx].SHEET.winst
	and		eax,SPS_GRIDLINES
	.if eax
		invoke CreatePen,PS_SOLID,1,[ebx].SHEET.gfmt.grdcol
		invoke SelectObject,mDC,eax
		push	eax
		invoke MoveToEx,mDC,grp.rc.left,grp.rc.bottom,NULL
		dec		grp.rc.top
		invoke LineTo,mDC,grp.rc.right,grp.rc.bottom
		invoke LineTo,mDC,grp.rc.right,grp.rc.top
		inc		grp.rc.top
		pop		eax
		invoke SelectObject,mDC,eax
		invoke DeleteObject,eax
	.endif
	movzx	eax,[edi].COLDTA.state
	and		eax,STATE_HIDDEN
	.if !eax
		lea		esi,[edi].COLDTA.fmt.tpe[1+4+1]
	  @@:
		mov		al,[esi]
		.if al==TPE_GRPTFUNCTION
			call	GetT
			inc		esi			;Skip ','
			jmp		@b
		.elseif al==TPE_GRPXFUNCTION
			push	edi
			lea		edi,grp.x
			call	GetXY
			pop		edi
			mov		gtxt.x,-10
			mov		gtxt.y,-2
			mov		gtxt.rotate,0
			mov		eax,grp.x.fnt
			mov		gtxt.fnt,eax
			mov		eax,grp.x.color
			mov		gtxt.color,eax
			mov		eax,grp.x.lpcap
			mov		gtxt.lpcap,eax
			call	DrawCellTxt
			inc		esi				;Skip ','
			jmp		@b
		.elseif al==TPE_GRPYFUNCTION
			push	edi
			lea		edi,grp.y
			call	GetXY
			pop		edi
			mov		gtxt.x,0
			mov		eax,grp.grc.top
			mov		gtxt.y,eax
			mov		gtxt.rotate,3
			mov		eax,grp.y.fnt
			mov		gtxt.fnt,eax
			mov		eax,grp.y.color
			mov		gtxt.color,eax
			mov		eax,grp.y.lpcap
			mov		gtxt.lpcap,eax
			call	DrawCellTxt
			add		grp.grc.left,eax
			inc		esi				;Skip ','
			jmp		@b
		.elseif al==TPE_GRPGXFUNCTION
			call	GetGX
			inc		esi				;Skip ','
			jmp		@b
		.elseif al==TPE_GRPFXFUNCTION
			call	GetFX
			inc		esi				;Skip ','
			jmp		@b
		.endif

		;xfactor
		mov		eax,grp.grc.right
		sub		eax,grp.grc.left
		mov		dwval,eax
		fld		grp.x.max
		fld		grp.x.min
		fsubp	st(1),st(0)
		fild	dwval
		fdivrp	st(1),st(0)
		fstp	grp.x.factor
		;pxOrigo
		fld		grp.x.max
		fld		grp.x.origo
		fsubp	st(1),st(0)
		fld		grp.x.factor
		fmulp	st(1),st(0)
		fistp	dwval
		mov		eax,grp.grc.right
		sub		eax,dwval
		mov		grp.x.porigo,eax

		;yfactor
		mov		eax,grp.grc.bottom
		sub		eax,grp.grc.top
		mov		dwval,eax
		fld		grp.y.max
		fld		grp.y.min
		fsubp	st(1),st(0)
		fild	dwval
		fdivrp	st(1),st(0)
		fstp	grp.y.factor
		;pyOrigo
		fld		grp.y.max
		fld		grp.y.origo
		fsubp	st(1),st(0)
		fld		grp.y.factor
		fmulp	st(1),st(0)
		fistp	dwval
		mov		eax,grp.grc.top
		add		eax,dwval
		mov		grp.y.porigo,eax
		;Y-axis
		invoke SetTextColor,mDC,grp.y.color
		invoke CreatePen,PS_SOLID,1,grp.y.color
		invoke SelectObject,mDC,eax
		push	eax
		invoke MoveToEx,mDC,grp.x.porigo,grp.grc.top,NULL
		invoke LineTo,mDC,grp.x.porigo,grp.grc.bottom
		fld		grp.y.min
		fld		grp.y.tick
		fdivp	st(1),st(0)
		fistp	dwval
		fild	dwval
		fld		grp.y.tick
		fmulp	st(1),st(0)
		fstp	fpval
		.while TRUE
			fld		fpval
			call	CalcY
			mov		eax,grp.grc.top
			.break .if sdword ptr eax>dwval
			mov		edx,grp.x.porigo
			dec		edx
			invoke MoveToEx,mDC,edx,dwval,NULL
			mov		edx,grp.x.porigo
			inc		edx
			inc		edx
			invoke LineTo,mDC,edx,dwval
			mov		eax,grp.y.porigo
			.if eax!=dwval && grp.y.ftickval!=-1
				invoke FpToAscii,addr fpval,addr buffer,FALSE
				invoke FormatNum,addr buffer,TPE_FLOAT,grp.y.ftickval
				mov		eax,gtxt.fnt
				mov		edx,sizeof FONT
				mul		edx
				mov		eax,[ebx].SHEET.ofont.hfont[eax]
				invoke SelectObject,mDC,eax
				push	eax
				mov		txtrect.left,0
				mov		txtrect.top,0
				invoke DrawText,mDC,addr buffer,-1,addr txtrect,DT_SINGLELINE or DT_CALCRECT
				mov		eax,txtrect.bottom
				shr		eax,1
				sub		dwval,eax
				invoke lstrlen,addr buffer
				mov		edx,grp.x.porigo
				sub		edx,txtrect.right
				sub		edx,3
				invoke TextOut,mDC,edx,dwval,addr buffer,eax
				pop		eax
				invoke SelectObject,mDC,eax
			.endif
			fld		fpval
			fld		grp.y.tick
			faddp	st(1),st(0)
			fstp	fpval
		.endw
		pop		eax
		invoke SelectObject,mDC,eax
		invoke DeleteObject,eax
		;X-axis
		invoke SetTextColor,mDC,grp.x.color
		invoke CreatePen,PS_SOLID,1,grp.x.color
		invoke SelectObject,mDC,eax
		push	eax
		invoke MoveToEx,mDC,grp.grc.left,grp.y.porigo,NULL
		invoke LineTo,mDC,grp.grc.right,grp.y.porigo
		fld		grp.x.min
		fld		grp.x.tick
		fdivp	st(1),st(0)
		fistp	dwval
		fild	dwval
		fld		grp.x.tick
		fmulp	st(1),st(0)
		fstp	fpval
		.while TRUE
			fld		fpval
			call	CalcX
			mov		eax,grp.grc.right
			.break .if sdword ptr eax<dwval
			mov		edx,grp.y.porigo
			dec		edx
			invoke MoveToEx,mDC,dwval,edx,NULL
			mov		edx,grp.y.porigo
			inc		edx
			inc		edx
			invoke LineTo,mDC,dwval,edx
			mov		eax,grp.x.porigo
			.if eax!=dwval && grp.x.ftickval!=-1
				invoke FpToAscii,addr fpval,addr buffer,FALSE
				invoke FormatNum,addr buffer,TPE_FLOAT,grp.x.ftickval
				mov		eax,gtxt.fnt
				mov		edx,sizeof FONT
				mul		edx
				mov		eax,[ebx].SHEET.ofont.hfont[eax]
				invoke SelectObject,mDC,eax
				push	eax
				mov		txtrect.left,0
				mov		txtrect.top,0
				invoke DrawText,mDC,addr buffer,-1,addr txtrect,DT_SINGLELINE or DT_CALCRECT
				mov		eax,txtrect.right
				shr		eax,1
				sub		dwval,eax
				invoke lstrlen,addr buffer
				mov		edx,grp.y.porigo
				add		edx,3
				invoke TextOut,mDC,dwval,edx,addr buffer,eax
				pop		eax
				invoke SelectObject,mDC,eax
			.endif
			fld		fpval
			fld		grp.x.tick
			faddp	st(1),st(0)
			fstp	fpval
		.endw
		pop		eax
		invoke SelectObject,mDC,eax
		invoke DeleteObject,eax
		;Create a rgn
		invoke CreateRectRgn,grp.grc.left,grp.grc.top,grp.grc.right,grp.grc.bottom
		invoke SelectObject,mDC,eax
		push	eax
		mov		eax,grp.grc.left
		mov		gtxt.x,eax

		;gx(
		push	edi
		lea		edi,ggx
		.while [edi].GGX.fcol
			invoke CreatePen,PS_SOLID,1,[edi].GGX.color
			invoke SelectObject,mDC,eax
			push	eax
			mov		xval,0
			mov		fy,0
			mov		eax,[edi].GGX.frow
			mov		nRow,eax
		  NxRow:
			mov		eax,[edi].GGX.fcol
			mov		nCol,eax
		  NxCol:
			invoke FindCell,ebx,nCol,nRow
			.if eax
				mov		esi,eax
				mov		al,[esi].COLDTA.fmt.tpe
				.if al==TPE_FLOAT
					lea		ecx,[esi].COLDTA.fmt.tpe[1]
					fld		tbyte ptr [ecx]
					call	CalcY
					mov		fy,eax
				.elseif al==TPE_INTEGER
					lea		ecx,[esi].COLDTA.fmt.tpe[1]
					fild	dword ptr [ecx]
					call	CalcY
					mov		fy,eax
				.elseif al==TPE_FORMULA
					mov		al,[esi].COLDTA.state
					and		al,STATE_ERRMASK
					.if !al
						lea		ecx,[esi].COLDTA.fmt.tpe[1]
						fld		tbyte ptr [ecx]
						call	CalcY
						mov		fy,eax
					.endif
				.endif
			.endif
			fild	xval
			call	CalcX
			mov		fx,eax
			.if xval
				invoke LineTo,mDC,fx,fy
			.else
				invoke MoveToEx,mDC,fx,fy,NULL
			.endif
			inc		xval
			inc		nCol
			mov		eax,[edi].GGX.tcol
			cmp		eax,nCol
			jnb		NxCol
			inc		nRow
			mov		eax,[edi].GGX.trow
			cmp		eax,nRow
			jnb		NxRow
			pop		eax
			invoke SelectObject,mDC,eax
			invoke DeleteObject,eax
			mov		eax,[edi].GGX.lpcap
			mov		gtxt.lpcap,eax
			mov		eax,[edi].GGX.fnt
			mov		gtxt.fnt,eax
			mov		eax,[edi].GGX.color
			mov		gtxt.color,eax
			mov		gtxt.rotate,0
			mov		gtxt.y,-2
			call	DrawCellTxt
			add		edx,20
			add		gtxt.x,edx
			add		edi,sizeof GGX
		.endw
		pop		edi

		;fx(
		push	edi
		lea		edi,gfx
		.while [edi].GFX.lpfun
			invoke CreatePen,PS_SOLID,1,[edi].GFX.color
			invoke SelectObject,mDC,eax
			push	eax
			fld		grp.x.min
			fstp	funx
			mov		esi,[edi].GFX.lpfun
			invoke CalculateCell,ebx,0,offset acmltr0
			fld		funx
			call	CalcX
			mov		fx,eax
			fld		acmltr0
			call	CalcY
			mov		fy,eax
			invoke MoveToEx,mDC,fx,fy,NULL
			.while TRUE
				fld		funx
				fld		[edi].GFX.step
				faddp	st(1),st(0)
				fstp	funx
				fld		funx
				call	CalcX
				mov		fx,eax
				mov		esi,[edi].GFX.lpfun
				invoke CalculateCell,ebx,0,offset acmltr0
				fld		acmltr0
				call	CalcY
				mov		fy,eax
				.if sdword ptr fy>-10000 && sdword ptr fy<10000
					invoke LineTo,mDC,fx,fy
				.endif
				mov		eax,fx
				.break .if eax>grp.grc.right
			.endw
			pop		eax
			invoke SelectObject,mDC,eax
			invoke DeleteObject,eax
			mov		eax,[edi].GFX.lpcap
			mov		gtxt.lpcap,eax
			mov		eax,[edi].GFX.fnt
			mov		gtxt.fnt,eax
			mov		eax,[edi].GFX.color
			mov		gtxt.color,eax
			mov		gtxt.rotate,0
			mov		gtxt.y,-2
			call	DrawCellTxt
			add		edx,20
			add		gtxt.x,edx
			add		edi,sizeof GFX
		.endw
		pop		edi

		;Select old rgn
		pop		eax
		invoke SelectObject,mDC,eax
		invoke DeleteObject,eax
		invoke DeleteObject,hbr

	.endif
	pop		eax
	ret

;           pxMax-pxMin
; xfactor = -----------
;            xMax-xMin
;
; pxOrigo = pxMax - xfactor * (xMax-xOrigo)
;
; px = pxOrigo + xfactor * (xval-xOrigo)

CalcX:
	;xval in st(0)
	fld		grp.x.origo
	fsubp	st(1),st(0)
	fld		grp.x.factor
	fmulp	st(1),st(0)
	fistp	dwval
	mov		eax,grp.x.porigo
	add		eax,dwval
	mov		dwval,eax
	retn

;           pyMax-pyMin
; yfactor = -----------
;            yMax-yMin
;
; pyOrigo = pyMin + yfactor * (yMax-yOrigo)
;
; py = pyOrigo - yfactor * (yval-yOrigo)

CalcY:
	;yval in st(0)
	fld		grp.y.origo
	fsubp	st(1),st(0)
	fld		grp.y.factor
	fmulp	st(1),st(0)
	fistp	dwval
	mov		eax,grp.y.porigo
	sub		eax,dwval
	mov		dwval,eax
	retn

GetT:
	push	edi
	mov		edi,lpgtxt
	inc		esi		;Sktp 'T('
	;X
	invoke CalculateCell,ebx,0,offset acmltr0
	fld		acmltr0
	fistp	[edi].GTEXT.x
	inc		esi		;Skip ','
	;Y
	invoke CalculateCell,ebx,0,offset acmltr0
	fld		acmltr0
	fistp	[edi].GTEXT.y
	inc		esi		;Skip ','
	;Rotate
	invoke CalculateCell,ebx,0,offset acmltr0
	inc		esi		;Skip ','
	fld		acmltr0
	fistp	[edi].GTEXT.rotate
	;Font
	mov		eax,cfnt
	mov		[edi].GTEXT.fnt,eax
	;Color
	invoke CalculateCell,ebx,0,offset acmltr0
	inc		esi		;Skip ','
	fld		acmltr0
	fistp	[edi].GTEXT.color

	mov		al,[esi]
	.if al==TPE_STRING
		inc		esi
		mov		eax,esi
		inc		eax
		mov		[edi].GTEXT.lpcap,eax
		movzx	eax,byte ptr [esi]
		add		esi,eax
		mov		eax,[edi].GTEXT.x
		mov		gtxt.x,eax
		mov		eax,[edi].GTEXT.y
		mov		gtxt.y,eax
		mov		eax,[edi].GTEXT.rotate
		mov		gtxt.rotate,eax
		mov		eax,[edi].GTEXT.fnt
		mov		gtxt.fnt,eax
		mov		eax,[edi].GTEXT.color
		mov		gtxt.color,eax
		mov		eax,[edi].GTEXT.lpcap
		mov		gtxt.lpcap,eax
		call	DrawCellTxt
	.else
		mov		[edi].GTEXT.lpcap,0
	.endif
	inc		esi		;Skip ')'
	add		edi,sizeof GTEXT
	mov		lpgtxt,edi
	pop		edi
	retn

GetXY:
	inc		esi				;Skip 'X(' or 'Y('
	;Min
	invoke CalculateCell,ebx,0,addr [edi].GAXIS.min
	inc		esi		;Skip ','
	;Max
	invoke CalculateCell,ebx,0,addr [edi].GAXIS.max
	inc		esi		;Skip ','
	;Origo
	invoke CalculateCell,ebx,0,addr [edi].GAXIS.origo
	inc		esi		;Skip ','
	;Tick
	invoke CalculateCell,ebx,0,addr [edi].GAXIS.tick
	inc		esi		;Skip ','
	;Font
	mov		eax,cfnt
	mov		[edi].GAXIS.fnt,eax
	;Color
	invoke CalculateCell,ebx,0,offset acmltr0
	fld		acmltr0
	fistp	[edi].GAXIS.color
	inc		esi		;Skip ','
	mov		[edi].GAXIS.ftickval,-1
	mov		al,[esi]
	.if al!=TPE_STRING
		;TickVal
		invoke CalculateCell,ebx,0,offset acmltr0
		fld		acmltr0
		fistp	[edi].GAXIS.ftickval
		inc		esi		;Skip ','
	.endif
	mov		al,[esi]
	.if al==TPE_STRING
		inc		esi
		mov		eax,esi
		inc		eax
		mov		[edi].GAXIS.lpcap,eax
		movzx	eax,byte ptr [esi]
		add		esi,eax
	.else
		mov		[edi].GAXIS.lpcap,0
	.endif
	inc		esi		;Skip ')'
	retn

GetGX:
	push	edi
	mov		edi,lpggx
	inc		esi				;Skip 'gx('
	inc		esi
	movzx	eax,word ptr [esi+1]
	mov		[edi].GGX.fcol,eax
	movzx	eax,word ptr [esi+3]
	mov		[edi].GGX.frow,eax
	movzx	eax,word ptr [esi+6]
	mov		[edi].GGX.tcol,eax
	movzx	eax,word ptr [esi+8]
	mov		[edi].GGX.trow,eax
	add		esi,10
	inc		esi				;Skip ','
	;Font
	mov		eax,cfnt
	mov		[edi].GGX.fnt,eax
	;Color
	invoke CalculateCell,ebx,0,offset acmltr0
	fld		acmltr0
	fistp	[edi].GGX.color
	inc		esi				;Skip ','
	mov		al,[esi]
	.if al==TPE_STRING
		inc		esi
		mov		eax,esi
		inc		eax
		mov		[edi].GGX.lpcap,eax
		movzx	eax,byte ptr [esi]
		add		esi,eax
	.else
		mov		[edi].GGX.lpcap,0
	.endif
	inc		esi		;Skip ')'
	add		edi,sizeof GGX
	mov		lpggx,edi
	pop		edi
	retn

GetFX:
	push	edi
	mov		edi,lpgfx
	inc		esi				;Skip 'fx('
	mov		[edi].GFX.lpfun,esi
	;Function
	invoke CalculateCell,ebx,0,offset acmltr0
	inc		esi				;Skip ','
	;Step
	invoke CalculateCell,ebx,0,addr [edi].GFX.step
	inc		esi				;Skip ','
	;Font
	mov		eax,cfnt
	mov		[edi].GFX.fnt,eax
	;Color
	invoke CalculateCell,ebx,0,offset acmltr0
	fld		acmltr0
	fistp	[edi].GFX.color
	inc		esi				;Skip ','
	mov		al,[esi]
	.if al==TPE_STRING
		inc		esi
		mov		eax,esi
		inc		eax
		mov		[edi].GFX.lpcap,eax
		movzx	eax,byte ptr [esi]
		add		esi,eax
	.else
		mov		[edi].GFX.lpcap,0
	.endif
	inc		esi		;Skip ')'
	add		edi,sizeof GFX
	mov		lpgfx,edi
	pop		edi
	retn

DrawCellTxt:
	mov		rect.left,0
	mov		rect.top,0
	mov		rect.right,0
	mov		rect.bottom,0
	mov		eax,gtxt.lpcap
	.if byte ptr [eax]
		invoke CreateCompatibleDC,hDC
		mov		tDC,eax
		mov		eax,gtxt.fnt
		mov		edx,sizeof FONT
		mul		edx
		mov		eax,[ebx].SHEET.ofont.hfont[eax]
		invoke SelectObject,tDC,eax
		push	eax
		invoke DrawText,tDC,gtxt.lpcap,-1,addr rect,DT_SINGLELINE or DT_LEFT or DT_TOP or DT_CALCRECT
		invoke CreateCompatibleBitmap,hDC,rect.right,rect.bottom
		mov		hbm,eax
		invoke SelectObject,tDC,eax
		push	eax
		invoke FillRect,tDC,addr rect,hbr
		invoke SetTextColor,tDC,gtxt.color
		invoke SetBkMode,tDC,TRANSPARENT
		invoke DrawText,tDC,gtxt.lpcap,-1,addr rect,DT_SINGLELINE or DT_LEFT or DT_TOP
		mov		eax,gtxt.x
		.if eax==-1
			mov		eax,grp.rc.right
			.if gtxt.rotate
				sub		eax,rect.bottom
			.else
				sub		eax,rect.right
			.endif
			shr		eax,1
		.elseif sdword ptr eax<0
			add		eax,grp.rc.right
			.if gtxt.rotate==1 || gtxt.rotate==3
				sub		eax,rect.bottom
			.else
				sub		eax,rect.right
			.endif
		.endif
		mov		gtxt.x,eax
		mov		eax,gtxt.y
		.if eax==-1
			mov		eax,grp.rc.bottom
			.if gtxt.rotate==1 || gtxt.rotate==3
				sub		eax,rect.right
			.else
				sub		eax,rect.bottom
			.endif
			shr		eax,1
		.elseif sdword ptr eax<0
			add		eax,grp.rc.bottom
			.if gtxt.rotate==1 || gtxt.rotate==3
				sub		eax,rect.right
			.else
				sub		eax,rect.bottom
			.endif
		.endif
		mov		gtxt.y,eax
		invoke Rotate,hbmd,hbm,gtxt.x,gtxt.y,gtxt.rotate
		pop		eax
		invoke SelectObject,tDC,eax
		invoke DeleteObject,eax
		pop		eax
		invoke SelectObject,tDC,eax
		invoke DeleteDC,tDC
	.endif
	mov		eax,rect.bottom
	mov		edx,rect.right
	retn

DrawGraph endp

DrawCell proc uses ebx esi edi,lpSheet:DWORD,lpWin:DWORD,nCol:DWORD,nRow:DWORD,lpRect:DWORD
	LOCAL	hDC:HDC
	LOCAL	mDC:HDC
	LOCAL	rect:RECT
	LOCAL	irect:RECT
	LOCAL	erect:RECT
	LOCAL	hBmp:DWORD
	LOCAL	hBr:DWORD
	LOCAL	hPen:DWORD
	LOCAL	buffer[1024]:BYTE

	LOCAL	sbsv:DWORD
	LOCAL	sbsh:DWORD
	LOCAL	fGrd:DWORD
	LOCAL	fRowSel:DWORD
	LOCAL	lpText:DWORD
	LOCAL	bckcol:DWORD
	LOCAL	txtcol:DWORD
	LOCAL	fmt:DWORD
	LOCAL	fnt:DWORD
	LOCAL	tpe:DWORD
	LOCAL	flpval:TBYTE
	LOCAL	state:DWORD
	LOCAL	bmp:BITMAP
	LOCAL	hctl:DWORD
	LOCAL	ctlval:DWORD
	LOCAL	dis:DRAWITEMSTRUCT
	LOCAL	spri:SPR_ITEM

	invoke TestCellRect,lpWin,lpRect
	.if eax>=4
		ret
	.endif
	mov		edx,lpRect
	mov		eax,[edx].RECT.bottom
	sub		eax,[edx].RECT.top
	je		@f
	mov		eax,[edx].RECT.right
	sub		eax,[edx].RECT.left
	je		@f
	call	DrawCell1
	xor		eax,eax
  @@:
	ret

DrawCell1:
	mov		esi,lpWin
	mov		ebx,lpSheet
	invoke CopyRect,addr rect,lpRect
	invoke CopyRect,addr irect,lpRect
	dec		irect.right
	dec		irect.bottom
	;Get DC
	mov		eax,[esi].WIN.mdc
	mov		hDC,eax
	;Styles
	mov		sbsv,0
	mov		sbsh,0
	mov		fGrd,FALSE
	mov		fRowSel,FALSE
	mov		eax,[ebx].SHEET.winst
	test	eax,SPS_VSCROLL
	je		@f
	mov		sbsv,SBSIZE
  @@:
	test	eax,SPS_HSCROLL
	je		@f
	mov		sbsh,SBSIZE
  @@:
	test	eax,SPS_GRIDLINES
	je		@f
	mov		fGrd,TRUE
  @@:
	test	eax,SPS_ROWSELECT
	je		@f
	mov		fRowSel,TRUE
  @@:
	invoke FindCell,ebx,nCol,nRow
	.if eax
		mov		edi,eax
		movzx	eax,[edi].COLDTA.state
		mov		state,eax
		movzx	ecx,[edi].COLDTA.expx
		movzx	edx,[edi].COLDTA.expy
		.if ecx || edx
			test	al,STATE_REDRAW
			je		Ex
			and		al,-1 xor STATE_REDRAW
			mov		[edi].COLDTA.state,al
			add		ecx,nCol
			add		edx,nRow
			invoke GetCellRect,ebx,esi,ecx,edx,addr erect
			push	erect.right
			push	erect.bottom
			invoke GetCellRect,ebx,esi,nCol,nRow,addr erect
			pop		eax
			sub		eax,erect.top
			add		eax,rect.top
			mov		rect.bottom,eax
			mov		irect.bottom,eax
			pop		eax
			sub		eax,erect.left
			add		eax,rect.left
			mov		rect.right,eax
			mov		irect.right,eax
		.endif
		invoke CreateRectRgn,rect.left,rect.top,rect.right,rect.bottom
		push	eax
		invoke SelectObject,hDC,eax
		pop		eax
		invoke DeleteObject,eax
		movzx	eax,[edi].COLDTA.fmt.tpe
		mov		tpe,eax
		mov		edx,eax
		and		eax,TPE_TYPEMASK
		and		edx,0F0h
		.if eax==TPE_COLHDR
			lea		eax,[edi].COLDTA.fmt.tpe[3]
			mov		lpText,eax
			lea		esi,[ebx].SHEET.gfmt.colhdr
			call	DrawCellFmt
			.if [ebx].SHEET.gfmt.colhdrbtn
				mov		al,TPE_WIDEBUTTON
			.else
				mov		al,0
			.endif
			call	DrawCellBack
			add		rect.top,1
			call	DrawCellTxt
		.elseif eax==TPE_ROWHDR
			lea		eax,[edi].COLDTA.fmt.tpe[1]
			mov		lpText,eax
			lea		esi,[ebx].SHEET.gfmt.rowhdr
			call	DrawCellFmt
			.if [ebx].SHEET.gfmt.rowhdrbtn
				mov		al,TPE_WIDEBUTTON
			.else
				mov		al,0
			.endif
			call	DrawCellBack
			call	DrawCellTxt
		.elseif eax==TPE_WINHDR
			lea		eax,buffer
			mov		lpText,eax
			test	[ebx].SHEET.winst,SPS_GRIDMODE
			.if ZERO?
				mov		buffer,'#'
				mov		eax,[esi].WIN.nwin
				inc		eax
				mov		edx,eax
				invoke DwToAscii,edx,addr buffer[1]
			.else
				mov		buffer,0
			.endif
			lea		esi,[ebx].SHEET.gfmt.winhdr
			call	DrawCellFmt
			.if [ebx].SHEET.gfmt.winhdrbtn
				mov		al,TPE_WIDEBUTTON
			.else
				mov		al,0
			.endif
			call	DrawCellBack
			call	DrawCellTxt
		.elseif eax==TPE_TEXT || eax==TPE_TEXTMULTILINE || eax==TPE_HYPERLINK
			lea		eax,[edi].COLDTA.fmt.tpe[1]
			mov		lpText,eax
			lea		esi,[ebx].SHEET.gfmt.cell
			call	DrawCellFmt
			mov		eax,fmt
			and		al,FMTA_XMASK
			.if al==FMTA_AUTO
				mov		eax,fmt
				and		al,-1 xor FMTA_XMASK
				or		al,FMTA_LEFT
				mov		fmt,eax
			.endif
			mov		al,[edi].COLDTA.fmt.tpe
			call	DrawCellBack
			call	DrawCellTxt
		.elseif eax==TPE_CHECKBOX
			mov		eax,dword ptr [edi].COLDTA.fmt.tpe[1]
			mov		ctlval,eax
			lea		eax,[edi].COLDTA.fmt.tpe[1+4]
			mov		lpText,eax
			lea		esi,[ebx].SHEET.gfmt.cell
			call	DrawCellFmt
			mov		eax,fmt
			and		al,FMTA_XMASK
			.if al==FMTA_AUTO
				mov		eax,fmt
				and		al,-1 xor FMTA_XMASK
				or		al,FMTA_LEFT
				mov		fmt,eax
			.endif
			mov		al,[edi].COLDTA.fmt.tpe
			call	DrawCellBack
			call	DrawCellTxt
		.elseif eax==TPE_COMBOBOX
			mov		eax,dword ptr [edi].COLDTA.fmt.tpe[1]
			mov		ctlval,eax
			mov		eax,dword ptr [edi].COLDTA.fmt.tpe[5]
			mov		hctl,eax
			mov		dword ptr buffer,'rrE'
			invoke SendMessage,hctl,LB_GETTEXT,ctlval,addr buffer
			lea		eax,buffer
			mov		lpText,eax
			lea		esi,[ebx].SHEET.gfmt.cell
			call	DrawCellFmt
			mov		eax,fmt
			and		al,FMTA_XMASK
			.if al==FMTA_AUTO
				mov		eax,fmt
				and		al,-1 xor FMTA_XMASK
				or		al,FMTA_LEFT
				mov		fmt,eax
			.endif
			mov		al,[edi].COLDTA.fmt.tpe
			call	DrawCellBack
			call	DrawCellTxt
		.elseif eax==TPE_INTEGER
			.if edx==TPE_DATE
				;Days since 01.01.1601
				mov		edx,dword ptr [edi].COLDTA.fmt.tpe[1]
				invoke DateToString,ebx,edx,addr buffer,sizeof buffer
				lea		eax,buffer
				mov		lpText,eax
				lea		esi,[ebx].SHEET.gfmt.cell
				call	DrawCellFmt
			.else
				movzx	eax,[edi].COLDTA.fmt.txtal
				and		eax,FMTD_MASK
				.if eax==FMTD_GLOBAL
					movzx	eax,[ebx].SHEET.gfmt.cell.txtal
					and		eax,FMTD_MASK
				.endif
				.if eax==FMTD_SCI
					fild	dword ptr [edi].COLDTA.fmt.tpe[1]
					fstp	flpval
					invoke FpToAscii,addr flpval,addr buffer,TRUE
					invoke FormatNum,addr buffer,TPE_FLOAT,FMTD_SCI
				.else
					push	eax
					mov		edx,dword ptr [edi].COLDTA.fmt.tpe[1]
					invoke DwToAscii,edx,addr buffer
					pop		eax
					invoke FormatNum,addr buffer,TPE_INTEGER,eax
				.endif
				lea		eax,buffer
				mov		lpText,eax
				lea		esi,[ebx].SHEET.gfmt.cell
				call	DrawCellFmt
				mov		eax,fmt
				and		al,FMTA_XMASK
				.if al==FMTA_AUTO
					mov		eax,fmt
					and		al,-1 xor FMTA_XMASK
					or		al,FMTA_RIGHT
					mov		fmt,eax
				.endif
			.endif
			mov		al,[edi].COLDTA.fmt.tpe
			call	DrawCellBack
			call	DrawCellTxt
		.elseif eax==TPE_FLOAT
			movzx	eax,[edi].COLDTA.fmt.txtal
			and		eax,FMTD_MASK
			.if eax==FMTD_GLOBAL
				movzx	eax,[ebx].SHEET.gfmt.cell.txtal
				and		eax,FMTD_MASK
			.endif
			push	eax
			.if eax!=FMTD_SCI
				xor		eax,eax
			.endif
			invoke FpToAscii,addr [edi].COLDTA.fmt.tpe[1],addr buffer,eax
			pop		eax
			invoke FormatNum,addr buffer,TPE_FLOAT,eax
			lea		eax,buffer
			mov		lpText,eax
			lea		esi,[ebx].SHEET.gfmt.cell
			call	DrawCellFmt
			mov		eax,fmt
			and		al,FMTA_XMASK
			.if al==FMTA_AUTO
				mov		eax,fmt
				and		al,-1 xor FMTA_XMASK
				or		al,FMTA_RIGHT
				mov		fmt,eax
			.endif
			mov		al,[edi].COLDTA.fmt.tpe
			call	DrawCellBack
			call	DrawCellTxt
		.elseif eax==TPE_FORMULA
			mov		al,[edi].COLDTA.state
			and		al,STATE_ERRMASK
			.if !al
				movzx	eax,[edi].COLDTA.fmt.txtal
				and		eax,FMTD_MASK
				.if eax==FMTD_GLOBAL
					movzx	eax,[ebx].SHEET.gfmt.cell.txtal
					and		eax,FMTD_MASK
				.endif
				push	eax
				.if eax!=FMTD_SCI
					xor		eax,eax
				.endif
				invoke FpToAscii,addr [edi].COLDTA.fmt.tpe[1],addr buffer,eax
				pop		eax
				invoke FormatNum,addr buffer,TPE_FLOAT,eax
				lea		eax,buffer
				mov		lpText,eax
				lea		esi,[ebx].SHEET.gfmt.cell
				call	DrawCellFmt
				mov		eax,fmt
				and		al,FMTA_XMASK
				.if al==FMTA_AUTO
					mov		eax,fmt
					and		al,-1 xor FMTA_XMASK
					or		al,FMTA_RIGHT
					mov		fmt,eax
				.endif
				mov		al,[edi].COLDTA.fmt.tpe
				call	DrawCellBack
				call	DrawCellTxt
			.else
				mov		dword ptr buffer,'####'
				.if al==STATE_DIV0
					mov		eax,'viD'
				.elseif al==STATE_UNDERFLOW
					mov		eax,'fnU'
				.elseif al==STATE_OVERFLOW
					mov		eax,'fvO'
				.elseif al==STATE_ERROR
					mov		eax,'rrE'
				.else
					mov		eax,'feR'
				.endif
				mov		dword ptr buffer[4],eax
				lea		eax,buffer
				mov		lpText,eax
				lea		esi,[ebx].SHEET.gfmt.cell
				call	DrawCellFmt
				mov		eax,fmt
				and		al,FMTA_XMASK
				.if al==FMTA_AUTO
					mov		eax,fmt
					and		al,-1 xor FMTA_XMASK
					or		al,FMTA_RIGHT
					mov		fmt,eax
				.endif
				mov		al,[edi].COLDTA.fmt.tpe
				call	DrawCellBack
				mov		txtcol,0FFh
				call	DrawCellTxt
			.endif
		.elseif eax==TPE_GRAPH
			invoke CreateCompatibleDC,hDC
			mov		mDC,eax
			invoke SetBkMode,mDC,TRANSPARENT
			mov		eax,dword ptr [edi].COLDTA.fmt.tpe[1]
			.if !eax
				invoke DrawGraph,ebx,edi,hDC,mDC,addr rect
			.else
				mov		edx,eax
				invoke GetObject,edx,sizeof BITMAP,addr bmp
				mov		eax,rect.right
				sub		eax,rect.left
				mov		edx,rect.bottom
				sub		edx,rect.top
				mov		ecx,dword ptr [edi].COLDTA.fmt.tpe[1]
				.if eax==bmp.bmWidth && edx==bmp.bmHeight
					invoke SelectObject,mDC,ecx
				.else
					invoke DeleteObject,ecx
					invoke DrawGraph,ebx,edi,hDC,mDC,addr rect
				.endif
			.endif
			push	eax
			mov		eax,rect.right
			sub		eax,rect.left
			mov		edx,rect.bottom
			sub		edx,rect.top
			invoke BitBlt,hDC,rect.left,rect.top,eax,edx,mDC,0,0,SRCCOPY
			pop		eax
			invoke SelectObject,mDC,eax
			invoke DeleteDC,mDC
		.elseif eax==TPE_EXPANDED
			;Don't draw anything
			mov		esi,lpWin
			push	[esi].WIN.ccol
			push	[esi].WIN.crow
			mov		eax,[edi].COLDTA.fmt.txtcol
			and		eax,0FFFFh
			mov		[esi].WIN.ccol,eax
			mov		nCol,eax
			mov		eax,[edi].COLDTA.fmt.txtcol
			shr		eax,16
			mov		[esi].WIN.crow,eax
			mov		nRow,eax
			invoke GetRealCellRect,ebx,esi,lpRect
			pop		[esi].WIN.crow
			pop		[esi].WIN.ccol
			call	DrawCell1
		.elseif eax==TPE_OWNERDRAWBLOB || eax==TPE_OWNERDRAWINTEGER
			mov		dis.CtlType,ODT_STATIC
			mov		eax,[ebx].SHEET.nid
			mov		dis.CtlID,eax
			mov		dis.itemID,0
			mov		dis.itemAction,ODA_DRAWENTIRE
			mov		dis.itemState,0
			mov		eax,[ebx].SHEET.hwnd
			mov		dis.hwndItem,eax
			mov		eax,hDC
			mov		dis.hdc,eax
			invoke CopyRect,addr dis.rcItem,addr rect
			mov		spri.flag,0
			mov		eax,nCol
			mov		spri.col,eax
			mov		eax,nRow
			mov		spri.row,eax
			invoke GetCellData,ebx,lpWin,addr spri
			lea		eax,spri
			mov		dis.itemData,eax
			lea		esi,[ebx].SHEET.gfmt.cell
			call	DrawCellFmt
			call	DrawCellBackColor
			invoke SetTextColor,hDC,txtcol
;			invoke CreateRectRgn,rect.left,rect.top,rect.right,rect.bottom
;			push	eax
;			invoke SelectObject,hDC,eax
;			pop		eax
;			invoke DeleteObject,eax
			invoke SendMessage,[ebx].SHEET.howner,WM_DRAWITEM,[ebx].SHEET.nid,addr dis
;			invoke CreateRectRgn,0,0,4096,4096
;			push	eax
;			invoke SelectObject,hDC,eax
;			pop		eax
;			invoke DeleteObject,eax
		.else
			lea		esi,[ebx].SHEET.gfmt.cell
			call	DrawCellFmt
			mov		eax,TPE_EMPTY
			call	DrawCellBack
		.endif
	.else
		invoke CreateRectRgn,rect.left,rect.top,rect.right,rect.bottom
		push	eax
		invoke SelectObject,hDC,eax
		pop		eax
		invoke DeleteObject,eax
		mov		eax,[ebx].SHEET.gfmt.cell.txtcol
		mov		txtcol,eax
		mov		eax,[ebx].SHEET.gfmt.cell.bckcol
		mov		bckcol,eax
		xor		eax,eax
		mov		al,[esi].FORMAT.imgal
		shl		eax,16
		mov		ah,[esi].FORMAT.txtal
		mov		fmt,eax
		mov		eax,TPE_EMPTY
		mov		tpe,-1
		call	DrawCellBack
	.endif
  Ex:
	retn

DrawCellFmt:
	movzx	eax,[edi].COLDTA.fmt.fnt
	.if al==-1
		movzx	eax,[esi].FORMAT.fnt
	.endif
	mov		fnt,eax
	mov		eax,[edi].COLDTA.fmt.txtcol
	.if eax==-1
		mov		eax,[esi].FORMAT.txtcol
	.endif
	mov		txtcol,eax
	mov		eax,[edi].COLDTA.fmt.bckcol
	.if eax==-1
		mov		eax,[esi].FORMAT.bckcol
	.endif
	mov		bckcol,eax
	movzx	eax,[edi].COLDTA.fmt.txtal
	and		al,FMTA_MASK
	.if al==FMTA_GLOBAL
		mov		al,[esi].FORMAT.txtal
	.endif
	mov		ah,[edi].COLDTA.fmt.imgal
	and		ah,FMTA_MASK
	.if ah==FMTA_GLOBAL
		mov		ah,[esi].FORMAT.imgal
	.endif
	mov		fmt,eax
	retn

DrawCellBack:
	test	eax,TPE_FIXEDSIZE
	.if ZERO?
		mov		edx,eax
		and		edx,TPE_TYPEMASK
		.if edx==TPE_CHECKBOX
			call	DrawCellImage
		.elseif edx==TPE_COMBOBOX
			call	DrawCellImage
		.else
			and		eax,030h
			.if eax==TPE_BUTTON
				call	DrawCellImage
			.elseif eax==TPE_WIDEBUTTON
				invoke DrawFrameControl,hDC,addr rect,DFC_BUTTON,DFCS_BUTTONPUSH
			.else
				call	DrawCellBackColor
			.endif
		.endif
	.else
		mov		edx,eax
		and		edx,TPE_TYPEMASK
		.if edx==TPE_CHECKBOX
			call	DrawCellImageFixed
		.elseif edx==TPE_COMBOBOX
			call	DrawCellImageFixed
		.else
			and		eax,030h
			.if eax==TPE_BUTTON
				call	DrawCellImageFixed
			.elseif eax==TPE_WIDEBUTTON
				invoke DrawFrameControl,hDC,addr rect,DFC_BUTTON,DFCS_BUTTONPUSH
			.else
				call	DrawCellBackColor
			.endif
		.endif
	.endif
	retn

DrawCellImage:
	push	eax
	call	DrawCellBackColor
	mov		eax,fmt
	shr		eax,8
	and		al,FMTA_XMASK
	.if al==FMTA_CENTER
		mov		edx,irect.right
		sub		edx,irect.left
		mov		eax,irect.bottom
		sub		eax,irect.top
		sub		edx,eax
		sar		edx,1
		add		irect.left,edx
		add		eax,irect.left
		mov		irect.right,eax
	.elseif al==FMTA_RIGHT
		mov		eax,irect.bottom
		sub		eax,irect.top
		sub		rect.right,eax
		neg		eax
		add		eax,irect.right
		mov		irect.left,eax
	.else
		mov		eax,irect.bottom
		sub		eax,irect.top
		add		rect.left,eax
		add		eax,irect.left
		mov		irect.right,eax
	.endif
	pop		eax
	.if al==TPE_BUTTON
		invoke DrawFrameControl,hDC,addr irect,DFC_BUTTON,DFCS_BUTTONPUSH
		invoke SelectObject,hDC,eax
		push	eax
		invoke DrawText,hDC,offset szDots,3,addr irect,DT_SINGLELINE or DT_CENTER or DT_VCENTER
		pop		eax
		invoke SelectObject,hDC,eax
	.elseif al==TPE_CHECKBOX
		mov		eax,DFCS_BUTTONCHECK or DFCS_FLAT
		.if ctlval
			mov		eax,DFCS_BUTTONCHECK or DFCS_FLAT or DFCS_CHECKED
		.endif
		invoke DrawFrameControl,hDC,addr irect,DFC_BUTTON,eax
	.elseif al==TPE_COMBOBOX
		invoke DrawFrameControl,hDC,addr irect,DFC_SCROLL,DFCS_SCROLLDOWN
	.endif
	retn

DrawCellImageFixed:
	push	eax
	call	DrawCellBackColor
	mov		eax,fmt
	shr		eax,8
	and		al,FMTA_XMASK
	.if al==FMTA_CENTER
		mov		edx,irect.right
		sub		edx,irect.left
		mov		eax,15
		sub		edx,eax
		sar		edx,1
		add		irect.left,edx
		add		eax,irect.left
		mov		irect.right,eax
	.elseif al==FMTA_RIGHT
		mov		eax,15
		sub		rect.right,eax
		neg		eax
		add		eax,irect.right
		mov		irect.left,eax
	.else
		mov		eax,15
		add		rect.left,eax
		add		eax,irect.left
		mov		irect.right,eax
	.endif
	mov		eax,fmt
	shr		eax,8
	and		al,FMTA_YMASK
	.if al==FMTA_MIDDLE
		mov		edx,irect.bottom
		sub		edx,irect.top
		mov		eax,15
		sub		edx,eax
		sar		edx,1
		add		irect.top,edx
		add		eax,irect.top
		mov		irect.bottom,eax
	.elseif al==FMTA_TOP
		mov		eax,15
		add		eax,irect.top
		mov		irect.bottom,eax
	.else
		mov		eax,irect.bottom
		sub		eax,15
		mov		irect.top,eax
	.endif
	pop		eax
	and		eax,TPE_TYPEMASK or 30h
	.if al==TPE_BUTTON
		invoke SetTextColor,hDC,0
		invoke DrawFrameControl,hDC,addr irect,DFC_BUTTON,DFCS_BUTTONPUSH
		invoke GetStockObject,ANSI_VAR_FONT
		invoke SelectObject,hDC,eax
		push	eax
		invoke DrawText,hDC,offset szDots,3,addr irect,DT_SINGLELINE or DT_CENTER or DT_VCENTER
		pop		eax
		invoke SelectObject,hDC,eax
	.elseif al==TPE_CHECKBOX
		mov		eax,DFCS_BUTTONCHECK or DFCS_FLAT
		.if ctlval
			mov		eax,DFCS_BUTTONCHECK or DFCS_FLAT or DFCS_CHECKED
		.endif
		invoke DrawFrameControl,hDC,addr irect,DFC_BUTTON,eax
	.elseif al==TPE_COMBOBOX
		invoke DrawFrameControl,hDC,addr irect,DFC_SCROLL,DFCS_SCROLLDOWN
	.endif
	retn

DrawCellBackColor:
	mov		esi,lpWin
	mov		edx,bckcol
	mov		eax,nCol
	mov		ecx,nRow
	.if (eax<=[esi].WIN.lcol || ecx<=[esi].WIN.lrow) && ecx && eax
		mov		eax,tpe
		.if tpe!=-1
			mov		eax,[edi].COLDTA.fmt.bckcol
			.if eax==-1
				mov		edx,[ebx].SHEET.gfmt.lockcol
			.endif
		.else
			mov		edx,[ebx].SHEET.gfmt.lockcol
		.endif
	.endif
	mov		eax,[esi].WIN.nwin
	.if eax==[ebx].SHEET.nwin
		mov		eax,nRow
		.if (eax>=[esi].WIN.crow && eax<=[esi].WIN.mrow) || (eax>=[esi].WIN.mrow && eax<=[esi].WIN.crow)
			mov		ecx,[ebx].SHEET.winst
			and		ecx,SPS_ROWSELECT
			mov		eax,nCol
			.if ((eax>=[esi].WIN.ccol && eax<=[esi].WIN.mcol) || (eax>=[esi].WIN.mcol && eax<=[esi].WIN.ccol) || ecx) && eax<=[ebx].SHEET.gfmt.ncols
				invoke GetFocus
				.if eax==[esi].WIN.hwin
					mov		edx,[ebx].SHEET.gfmt.bckfocol
					mov		eax,[ebx].SHEET.gfmt.txtfocol
					mov		txtcol,eax
				.else
					mov		edx,[ebx].SHEET.gfmt.bcknfcol
					mov		eax,[ebx].SHEET.gfmt.txtnfcol
					mov		txtcol,eax
				.endif
			.endif
		.endif
	.endif
	invoke CreateSolidBrush,edx
	mov		hBr,eax
	invoke FillRect,hDC,addr rect,hBr
	invoke DeleteObject,hBr
	dec		rect.bottom
	dec		rect.right
	mov		eax,nCol
	mov		ecx,nRow
	mov		edx,[ebx].SHEET.winst
	and		edx,SPS_GRIDLINES
	.if eax<=[ebx].SHEET.gfmt.ncols && ecx<=[ebx].SHEET.gfmt.nrows && edx
		.if eax && ecx
			invoke CreatePen,PS_SOLID,1,[ebx].SHEET.gfmt.grdcol
		.else
			invoke CreatePen,PS_SOLID,1,[ebx].SHEET.gfmt.hdrgrdcol
		.endif
		mov		hPen,eax
		invoke SelectObject,hDC,hPen
		push	eax
		invoke MoveToEx,hDC,rect.left,rect.bottom,NULL
		dec		rect.top
		invoke LineTo,hDC,rect.right,rect.bottom
		invoke LineTo,hDC,rect.right,rect.top
		inc		rect.top
		pop		eax
		invoke SelectObject,hDC,eax
		invoke DeleteObject,hPen
	.endif
	retn

DrawCellTxt:
	mov		eax,state
	and		eax,STATE_HIDDEN
	.if !eax
		mov		eax,fnt
		mov		edx,sizeof FONT
		mul		edx
		mov		eax,[ebx].SHEET.ofont.hfont[eax]
		invoke SelectObject,hDC,eax
		push	eax
		add		rect.left,2
		sub		rect.right,4
		invoke SetTextColor,hDC,txtcol
		mov		eax,DT_SINGLELINE
		mov		ecx,fmt
		and		cl,FMTA_XMASK
		.if cl==FMTA_LEFT
			or		eax,DT_LEFT
		.elseif cl==FMTA_CENTER
			or		eax,DT_CENTER
		.elseif cl==FMTA_RIGHT
			or		eax,DT_RIGHT
		.elseif cl==FMTA_AUTO
			or		eax,DT_LEFT
		.endif
		mov		ecx,fmt
		and		cl,FMTA_YMASK
		.if cl==FMTA_TOP
			or		eax,DT_TOP
		.elseif cl==FMTA_MIDDLE
			or		eax,DT_VCENTER
		.elseif cl==FMTA_BOTTOM
			or		eax,DT_BOTTOM
		.endif
		mov		cl,[edi].COLDTA.fmt.tpe
		and		cl,0Fh
		.if cl==TPE_TEXTMULTILINE || cl==TPE_COLHDR
			xor		eax,DT_SINGLELINE
			or		eax,DT_WORDBREAK
		.endif
		invoke DrawText,hDC,lpText,-1,addr rect,eax
		pop		eax
		invoke SelectObject,hDC,eax
	.endif
	retn

DrawCell endp

