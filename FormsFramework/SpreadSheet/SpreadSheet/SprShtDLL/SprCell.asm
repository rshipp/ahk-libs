.code

MakeFont proc uses ebx,lpFont:DWORD
	LOCAL	lf:LOGFONT

	mov		ebx,lpFont
	invoke RtlZeroMemory,addr lf,sizeof lf
	mov		eax,[ebx].FONT.ht
	mov		lf.lfHeight,eax
	mov		eax,400
	.if [ebx].FONT.bold
		mov		eax,700
	.endif
	mov		lf.lfWeight,eax
	mov		al,[ebx].FONT.italic
	mov		lf.lfItalic,al
	mov		al,[ebx].FONT.underline
	mov		lf.lfUnderline,al
	mov		al,[ebx].FONT.strikeout
	mov		lf.lfStrikeOut,al
	invoke lstrcpyn,addr lf.lfFaceName,addr [ebx].FONT.face,LF_FACESIZE
	invoke CreateFontIndirect,addr lf
	mov		[ebx].FONT.hfont,eax
	ret

MakeFont endp

;--------------------------------------------------------------------------------

FindCol proc uses ebx esi,lpSheet:DWORD,nCol:DWORD

	mov		ebx,lpSheet
	mov		eax,nCol
	xor		edx,edx
	mov		esi,[ebx].SHEET.lpcol
	.if esi
		cmp		ax,[esi].COLDTA.coln
		jge		@f
	.endif
	mov		esi,[ebx].SHEET.lprow
	mov		edx,sizeof ROWDTA-4
  @@:
	add		esi,edx
	movzx	edx,[esi].COLDTA.len
	or		edx,edx
	je		Nf
	cmp		ax,[esi].COLDTA.coln
	jg		@b
  Nf:
	mov		[ebx].SHEET.lpcol,esi
	mov		eax,esi
	ret

FindCol endp

FindRow proc uses ebx,lpSheet:DWORD,nRow:DWORD

	mov		ebx,lpSheet
	mov		eax,nRow
	mov		ecx,[ebx].SHEET.lprowmem
	lea		eax,[ecx+eax*4]
	mov		eax,[eax]
	mov		[ebx].SHEET.lpcol,0
	mov		[ebx].SHEET.lprow,eax
	ret

FindRow endp

;--------------------------------------------------------------------------------

MakeCol proc uses ebx,lpSheet:DWORD,lpWhere:DWORD,nCol:DWORD

	mov		ebx,lpSheet
	mov		[ebx].SHEET.lpcol,0
	invoke MemMove,ebx,lpWhere,sizeof COLDTA
	mov		ebx,eax
	mov		[ebx].COLDTA.len,sizeof COLDTA
	mov		eax,nCol
	mov		[ebx].COLDTA.coln,ax
	mov		[ebx].COLDTA.expx,0
	mov		[ebx].COLDTA.expy,0
	mov		[ebx].COLDTA.fmt.bckcol,-1
	mov		[ebx].COLDTA.fmt.txtcol,-1
	mov		[ebx].COLDTA.fmt.txtal,FMTA_GLOBAL or FMTD_GLOBAL
	mov		[ebx].COLDTA.fmt.imgal,FMTA_GLOBAL
	mov		[ebx].COLDTA.state,0
	mov		[ebx].COLDTA.fmt.fnt,-1
	mov		[ebx].COLDTA.fmt.tpe,TPE_EMPTY
	mov		eax,lpSheet
	mov		[eax].SHEET.lpcol,ebx
	mov		eax,ebx
	ret

MakeCol endp

MakeRow proc uses ebx esi edi,lpSheet:DWORD,nRow:DWORD

	mov		ebx,lpSheet
	mov		[ebx].SHEET.lpcol,0
	mov		[ebx].SHEET.lprow,0
	mov		eax,nRow
	mov		ebx,[ebx].SHEET.lprowmem
	lea		ebx,[ebx+eax*4]
	.if !dword ptr [ebx]
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,MAXROWMEM
		mov		[ebx],eax
		mov		[eax].ROWDTA.maxlen,MAXROWMEM
	.endif
	mov		ebx,[ebx]

	mov		[ebx].ROWDTA.len,sizeof ROWDTA
	mov		eax,nRow
	mov		[ebx].ROWDTA.rown,ax
	mov		[ebx].ROWDTA.rowht,-1
	mov		[ebx].ROWDTA.colend,0
	mov		eax,lpSheet
	mov		[eax].SHEET.lprow,ebx
	mov		eax,ebx
	ret

MakeRow endp

MakeNewRow proc uses ebx,lpSheet:DWORD,nRow:DWORD

	invoke FindRow,lpSheet,nRow
	.if !eax
		invoke MakeRow,lpSheet,nRow
	.endif
	ret

MakeNewRow endp

MakeNewCol proc uses ebx,lpSheet:DWORD,nCol:DWORD

	mov		ebx,lpSheet
	invoke FindCol,ebx,nCol
	mov		ebx,eax
	movzx	edx,[ebx].COLDTA.len
	movzx	eax,[ebx].COLDTA.coln
	.if eax!=nCol || !edx
		invoke MakeCol,lpSheet,ebx,nCol
		mov		ebx,eax
	.endif
	mov		eax,ebx
	ret

MakeNewCol endp

MakeNewCell proc uses ebx,lpSheet:DWORD,nCol:DWORD,nRow:DWORD

	invoke MakeNewRow,lpSheet,nRow
	invoke MakeNewCol,lpSheet,nCol
	ret

MakeNewCell endp

UpdateCellRef proc uses esi,lpCell:DWORD,nColMin:DWORD,nRowMin:DWORD,nColAdd:DWORD,nRowAdd:DWORD

	mov		esi,lpCell
	movzx	eax,[esi].COLDTA.fmt.tpe
	.if al==TPE_FORMULA || al==TPE_GRAPH
		.if al==TPE_FORMULA
			add		esi,sizeof COLDTA+10
		.else
			add		esi,sizeof COLDTA+4
		.endif
	  @@:
		mov		al,[esi]
		inc		esi
		.if al=='+' || al=='-' || al=='*' || al=='/' || al=='(' || al==')' || al=='^' || al==','
			jmp		@b
		.elseif al==TPE_NOTEQU || al==TPE_GTOREQU || al==TPE_LEOREQU || al==TPE_GT || al==TPE_EQU || al==TPE_LE
			jmp		@b
		.elseif al==TPE_AND || al==TPE_OR || al==TPE_XOR
			jmp		@b
		.elseif al==TPE_INTEGER
			add		esi,4
			jmp		@b
		.elseif al==TPE_FLOAT
			add		esi,10
			jmp		@b
		.elseif al==TPE_CELLREF
			call	UpdateRef
			jmp		@b
		.elseif al==TPE_AREAREF || al==TPE_SUMFUNCTION || al==TPE_CNTFUNCTION || al==TPE_AVGFUNCTION || al==TPE_MINFUNCTION || al==TPE_MAXFUNCTION || al==TPE_VARFUNCTION || al==TPE_STDFUNCTION
			.if byte ptr [esi]==TPE_CELLREF
				inc		esi
				call	UpdateRef
			.else
				add		esi,5
			.endif
			.if byte ptr [esi]==TPE_CELLREF
				inc		esi
				call	UpdateRef
			.else
				add		esi,5
			.endif
			jmp		@b
		.elseif al==TPE_SQTFUNCTION || al==TPE_SINFUNCTION || al==TPE_COSFUNCTION || al==TPE_TANFUNCTION || al==TPE_RADFUNCTION || al==TPE_PIFUNCTION || al==TPE_IIFFUNCTION || al==TPE_ONFUNCTION || al==TPE_ABSFUNCTION || al==TPE_SGNFUNCTION || al==TPE_INTFUNCTION || al==TPE_LOGFUNCTION || al==TPE_LNFUNCTION || al==TPE_EFUNCTION || al==TPE_ASINFUNCTION || al==TPE_ACOSFUNCTION || al==TPE_ATANFUNCTION || al==TPE_GRDFUNCTION || al==TPE_RGBFUNCTION || al==TPE_XFUNCTION
			jmp		@b
		.elseif al==TPE_GRPFUNCTION || al==TPE_GRPXFUNCTION || al==TPE_GRPYFUNCTION || al==TPE_GRPGXFUNCTION || al==TPE_GRPFXFUNCTION
			jmp		@b
		.endif
	.endif
	ret

UpdateRef:
	movzx	eax,word ptr [esi]
	.if eax>=nColMin
		add		eax,nColAdd
		mov		word ptr [esi],ax
	.endif
	movzx	eax,word ptr [esi+2]
	.if eax>=nRowMin
		add		eax,nRowAdd
		mov		word ptr [esi+2],ax
	.endif
	add		esi,4
	retn

UpdateCellRef endp

UpdateSheetRef proc uses ebx esi,lpSheet:DWORD,nColMin:DWORD,nRowMin:DWORD,nColAdd:DWORD,nRowAdd:DWORD

	mov		ebx,lpSheet
	xor		eax,eax
	inc		eax
	.while eax<=[ebx].SHEET.gfmt.nrows
		push	eax
		mov		esi,[ebx].SHEET.lprowmem
		lea		esi,[esi+eax*4]
		mov		esi,[esi]
		.if esi
			add		esi,sizeof ROWDTA-4
			.while eax
				movzx	eax,[esi].COLDTA.len
				.if eax
					invoke UpdateCellRef,esi,nColMin,nRowMin,nColAdd,nRowAdd
					movzx	eax,[esi].COLDTA.len
					add		esi,eax
				.endif
			.endw
		.endif
		pop		eax
		inc		eax
	.endw
	ret

UpdateSheetRef endp

UpdateCell proc uses ebx esi edi,lpSheet:DWORD,nCol:DWORD,nRow:DWORD,nTpe:DWORD,lpDta:DWORD,lpCell:DWORD
	LOCAL	oDtaLen:DWORD
	LOCAL	nDtaLen:DWORD

	mov		esi,lpSheet
	mov		ebx,lpCell
	.if !ebx
		invoke MakeNewCell,esi,nCol,nRow
		mov		ebx,eax
	.endif
	movzx	eax,[ebx].COLDTA.len
	sub		eax,sizeof COLDTA
	mov		oDtaLen,eax
	mov		eax,nTpe
	mov		[ebx].COLDTA.fmt.tpe,al
	and		eax,TPE_TYPEMASK
	.if eax==TPE_COLHDR
		mov		eax,lpDta
		add		eax,2			;Skip col width
		invoke StrLen,eax
		add		eax,3			;ColWt+StrTerminator
		mov		nDtaLen,eax
		mov		edi,ebx
		add		edi,sizeof COLDTA
		mov		eax,nDtaLen
		sub		eax,oDtaLen
		invoke MemMove,esi,edi,eax
		mov		edi,eax
		mov		esi,lpDta
		mov		ecx,nDtaLen
		rep movsb
	.elseif eax==TPE_ROWHDR
		mov		eax,lpDta
		invoke StrLen,eax
		inc		eax				;StrTerminator
		mov		nDtaLen,eax
		mov		edi,ebx
		add		edi,sizeof COLDTA
		mov		eax,nDtaLen
		sub		eax,oDtaLen
		invoke MemMove,esi,edi,eax
		mov		edi,eax
		mov		esi,lpDta
		mov		ecx,nDtaLen
		rep movsb
	.elseif eax==TPE_WINHDR
		mov		nDtaLen,3
		mov		edi,ebx
		add		edi,sizeof COLDTA
		mov		eax,nDtaLen
		sub		eax,oDtaLen
		invoke MemMove,esi,edi,eax
		mov		edi,eax
		mov		esi,lpDta
		mov		ecx,nDtaLen
		rep movsb
	.elseif eax==TPE_TEXT || eax==TPE_TEXTMULTILINE || eax==TPE_HYPERLINK
		mov		eax,lpDta
		invoke StrLen,eax
		inc		eax				;StrTerminator
		mov		nDtaLen,eax
		mov		edi,ebx
		add		edi,sizeof COLDTA
		mov		eax,nDtaLen
		sub		eax,oDtaLen
		invoke MemMove,esi,edi,eax
		mov		edi,eax
		mov		esi,lpDta
		mov		ecx,nDtaLen
		rep movsb
	.elseif eax==TPE_CHECKBOX
		mov		eax,lpDta
		add		eax,4
		invoke StrLen,eax
		inc		eax				;StrTerminator
		add		eax,4
		mov		nDtaLen,eax
		mov		edi,ebx
		add		edi,sizeof COLDTA
		mov		eax,nDtaLen
		sub		eax,oDtaLen
		invoke MemMove,esi,edi,eax
		mov		edi,eax
		mov		esi,lpDta
		mov		ecx,nDtaLen
		rep movsb
	.elseif eax==TPE_INTEGER || eax==TPE_OWNERDRAWINTEGER
		mov		eax,4
		mov		nDtaLen,eax
		mov		edi,ebx
		add		edi,sizeof COLDTA
		mov		eax,nDtaLen
		sub		eax,oDtaLen
		invoke MemMove,esi,edi,eax
		mov		edi,eax
		mov		esi,lpDta
;		mov		ecx,nDtaLen
		movsd
	.elseif eax==TPE_COMBOBOX
		mov		eax,8
		mov		nDtaLen,eax
		mov		edi,ebx
		add		edi,sizeof COLDTA
		mov		eax,nDtaLen
		sub		eax,oDtaLen
		invoke MemMove,esi,edi,eax
		mov		edi,eax
		mov		esi,lpDta
;		mov		ecx,nDtaLen
		movsd
		movsd
	.elseif eax==TPE_FLOAT
		mov		eax,10
		mov		nDtaLen,eax
		mov		edi,ebx
		add		edi,sizeof COLDTA
		mov		eax,nDtaLen
		sub		eax,oDtaLen
		invoke MemMove,esi,edi,eax
		mov		edi,eax
		mov		esi,lpDta
;		mov		ecx,nDtaLen
		movsd
		movsd
		movsw
	.elseif eax==TPE_GRAPH
		mov		edi,ebx
		add		edi,sizeof COLDTA
		push	esi
		mov		esi,lpDta
		add		esi,4	;Result bitmap
		jmp		@f
	.elseif eax==TPE_FORMULA
		mov		edi,ebx
		add		edi,sizeof COLDTA
		push	esi
		mov		esi,lpDta
		add		esi,10	;Result float
	  @@:
		mov		al,[esi]
		inc		esi
		.if al=='+' || al=='-' || al=='*' || al=='/' || al=='(' || al==')' || al=='^' || al==','
			jmp		@b
		.elseif al==TPE_NOTEQU || al==TPE_GTOREQU || al==TPE_LEOREQU || al==TPE_GT || al==TPE_EQU || al==TPE_LE
			jmp		@b
		.elseif al==TPE_AND || al==TPE_OR || al==TPE_XOR
			jmp		@b
		.elseif al==TPE_CELLREF || al==TPE_RELCELLREF
			add		esi,4
			jmp		@b
		.elseif al==TPE_INTEGER
			add		esi,4
			jmp		@b
		.elseif al==TPE_AREAREF || al==TPE_SUMFUNCTION || al==TPE_CNTFUNCTION || al==TPE_AVGFUNCTION || al==TPE_MINFUNCTION || al==TPE_MAXFUNCTION || al==TPE_VARFUNCTION || al==TPE_STDFUNCTION
			add		esi,10
			jmp		@b
		.elseif al==TPE_SQTFUNCTION || al==TPE_SINFUNCTION || al==TPE_COSFUNCTION || al==TPE_TANFUNCTION || al==TPE_RADFUNCTION || al==TPE_PIFUNCTION || al==TPE_IIFFUNCTION || al==TPE_ONFUNCTION || al==TPE_ABSFUNCTION || al==TPE_SGNFUNCTION || al==TPE_INTFUNCTION || al==TPE_LOGFUNCTION || al==TPE_LNFUNCTION || al==TPE_EFUNCTION || al==TPE_ASINFUNCTION || al==TPE_ACOSFUNCTION || al==TPE_ATANFUNCTION || al==TPE_GRDFUNCTION || al==TPE_RGBFUNCTION || al==TPE_XFUNCTION || al==TPE_CDATEFUNCTION
			jmp		@b
		.elseif al==TPE_GRPFUNCTION || al==TPE_GRPTFUNCTION || al==TPE_GRPXFUNCTION || al==TPE_GRPYFUNCTION || al==TPE_GRPGXFUNCTION || al==TPE_GRPFXFUNCTION
			jmp		@b
		.elseif al==TPE_FLOAT
			add		esi,10
			jmp		@b
		.elseif al==TPE_STRING
			movzx	eax,byte ptr [esi]
			add		esi,eax
			jmp		@b
		.endif
		mov		eax,esi
		sub		eax,lpDta
		mov		nDtaLen,eax
		sub		eax,oDtaLen
		pop		esi
		invoke MemMove,esi,edi,eax
		mov		edi,eax
		mov		esi,lpDta
		mov		ecx,nDtaLen
		rep movsb
	.elseif eax==TPE_OWNERDRAWBLOB
		mov		eax,lpDta
		movzx	eax,word ptr [eax]
		add		eax,2
		mov		nDtaLen,eax
		mov		edi,ebx
		add		edi,sizeof COLDTA
		mov		eax,nDtaLen
		sub		eax,oDtaLen
		invoke MemMove,esi,edi,eax
		mov		edi,eax
		mov		esi,lpDta
		mov		ecx,nDtaLen
		rep movsb
	.elseif eax==TPE_EMPTY || eax==TPE_EXPANDED
		mov		nDtaLen,0
		mov		edi,ebx
		add		edi,sizeof COLDTA
		mov		eax,nDtaLen
		sub		eax,oDtaLen
		invoke MemMove,esi,edi,eax
	.endif
	ret

UpdateCell endp

FindCell proc uses ebx,lpSheet:DWORD,nCol:DWORD,nRow:DWORD

	invoke FindRow,lpSheet,nRow
	.if eax
		mov		ebx,eax
		mov		eax,nRow
		.if ax==[ebx].ROWDTA.rown && [ebx].ROWDTA.len!=0
			invoke FindCol,lpSheet,nCol
			mov		ebx,eax
			mov		eax,nCol
			.if ax==[ebx].COLDTA.coln && [ebx].COLDTA.len!=0
				mov		eax,ebx
			.else
				xor		eax,eax
			.endif
		.else
			xor		eax,eax
		.endif
	.endif
	ret

FindCell endp

DeleteCell proc uses ebx,lpSheet:DWORD,nCol:DWORD,nRow:DWORD

	mov		ebx,lpSheet
	invoke FindCell,ebx,nCol,nRow
	.if eax
		movzx	ecx,[eax].COLDTA.len
		neg		ecx
		mov		[ebx].SHEET.lpcol,0
		invoke MemMove,ebx,eax,ecx
	.endif
	ret

DeleteCell endp

MakeColHdr proc uses ebx edi,lpSheet:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	nCols:DWORD

	mov		ebx,lpSheet
	mov		eax,[ebx].SHEET.gfmt.ncols
	mov		nCols,eax
	lea		edi,buffer
	mov		dword ptr [edi],0FFFFh
	invoke UpdateCell,ebx,0,0,TPE_WINHDR,edi,0
	mov		edx,'AA'
	mov		eax,1
	.while eax<=nCols
		test	[ebx].SHEET.winst,SPS_GRIDMODE
		jne		@f
		mov		[edi+2],edx
	  @@:
		push	eax
		invoke UpdateCell,ebx,eax,0,TPE_COLHDR,edi,0
		mov		edx,[edi+2]
		inc		dh
		.if dh>'Z'
			mov		dh,'A'
			inc		dl
		.endif
		pop		eax
		inc		eax
	.endw
	mov		dword ptr [edi],8192
	invoke UpdateCell,ebx,eax,0,TPE_COLHDR,edi,0
	ret

MakeColHdr endp

MakeRowHdr proc uses ebx edi,lpSheet:DWORD
	LOCAL	nRows:DWORD
	LOCAL	buffer[256]:BYTE

	mov		ebx,lpSheet
	mov		eax,[ebx].SHEET.gfmt.nrows
	mov		nRows,eax
	lea		edi,buffer
	mov		byte ptr [edi],0
	mov		eax,1
	.while eax<=nRows
		test	[ebx].SHEET.winst,SPS_GRIDMODE
		jne		@f
		push	eax
		invoke DwToAscii,eax,edi
		pop		eax
	  @@:
		push	eax
		invoke UpdateCell,ebx,0,eax,TPE_ROWHDR,edi,0
		pop		eax
		inc		eax
	.endw
	mov		byte ptr [edi],0
	invoke UpdateCell,ebx,0,eax,TPE_ROWHDR,edi,0
	mov		edi,[ebx].SHEET.lprow
	mov		word ptr [edi].ROWDTA.rowht,8192
	ret

MakeRowHdr endp

GetWinPtr proc hWin:HWND

	invoke GetWindowLong,hWin,0
	mov		ecx,eax
	mov		edx,[ecx].SHEET.nwin
	mov		eax,sizeof WIN
	mul		edx
	lea		eax,[ecx].SHEET.owin[eax]
	ret

GetWinPtr endp

DestroyFonts proc uses ebx edi,lpSheet:DWORD

	mov		ebx,lpSheet
	mov		ecx,FONTMAX
	lea		edi,[ebx].SHEET.ofont
	.while ecx
		push	ecx
		mov		eax,[edi].FONT.hfont
		.if eax
			invoke DeleteObject,eax
		.endif
		pop		ecx
		add		edi,sizeof FONT
		dec		ecx
	.endw
	ret

DestroyFonts endp

DestroyRowMem proc uses ebx edi,lpSheet:DWORD

	mov		ebx,lpSheet
	mov		edi,[ebx].SHEET.lprowmem
	.while dword ptr [edi]
		invoke GlobalFree,[edi]
		mov		dword ptr [edi],0
		lea		edi,[edi+4]
	.endw
	ret

DestroyRowMem endp

DestroyWindows proc uses ebx edi,lpSheet:DWORD

	mov		ecx,WINMAX
	lea		edi,[ebx].SHEET.owin
	.while ecx
		push	ecx
		.if [edi].WIN.act!=-1
			invoke DestroyWindow,[edi].WIN.hwin
		.endif
		pop		ecx
		add		edi,sizeof WIN
		dec		ecx
	.endw
	ret

DestroyWindows endp

InitSheetMem proc uses ebx,hWin:HWND
	LOCAL	lf:LOGFONT

	;Memory
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,sizeof SHEET
	mov		ebx,eax
	invoke SetWindowLong,hWin,0,ebx
	mov		eax,hWin
	mov		[ebx].SHEET.hwnd,eax
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,256*256*4
	mov		[ebx].SHEET.lprowmem,eax

	;Style
	invoke GetWindowLong,hWin,GWL_STYLE
	mov		[ebx].SHEET.winst,eax

	;Font
	invoke StrCpy,addr [ebx].SHEET.ofont.face,offset szFont
	mov		[ebx].SHEET.ofont.fsize,8
	mov		[ebx].SHEET.ofont.ht,-10
	mov		[ebx].SHEET.ofont.bold,FALSE
	mov		[ebx].SHEET.ofont.italic,FALSE
	mov		[ebx].SHEET.ofont.underline,FALSE
	mov		[ebx].SHEET.ofont.strikeout,FALSE
	invoke MakeFont,addr [ebx].SHEET.ofont
	invoke SendMessage,hWin,WM_SETFONT,[ebx].SHEET.ofont.hfont,FALSE

	;Size
	test	[ebx].SHEET.winst,SPS_GRIDMODE
	.if ZERO?
		mov		[ebx].SHEET.gfmt.ghdrwt,HDRWT
		mov		[ebx].SHEET.gfmt.ghdrht,HDRHT
		mov		[ebx].SHEET.gfmt.gcellwt,CELLWT
		mov		[ebx].SHEET.gfmt.gcellht,CELLHT
		mov		[ebx].SHEET.gfmt.ncols,COLMAX
		mov		[ebx].SHEET.gfmt.nrows,ROWMAX
	.else
		mov		[ebx].SHEET.gfmt.ghdrwt,0
		mov		[ebx].SHEET.gfmt.ghdrht,HDRHT
		mov		[ebx].SHEET.gfmt.gcellwt,CELLWT
		mov		[ebx].SHEET.gfmt.gcellht,CELLHT
		mov		[ebx].SHEET.gfmt.ncols,5
		mov		[ebx].SHEET.gfmt.nrows,10
	.endif
	;Global Format
	mov		[ebx].SHEET.gfmt.colhdrbtn,TRUE
	mov		[ebx].SHEET.gfmt.colhdr.bckcol,0C0C0C0h
	mov		[ebx].SHEET.gfmt.colhdr.txtcol,0FF0000h
	mov		[ebx].SHEET.gfmt.colhdr.txtal,FMTA_CENTER or FMTA_MIDDLE or FMTD_0
	mov		[ebx].SHEET.gfmt.colhdr.imgal,FMTA_LEFT or FMTA_MIDDLE

	mov		[ebx].SHEET.gfmt.rowhdrbtn,TRUE
	mov		[ebx].SHEET.gfmt.rowhdr.bckcol,0C0C0C0h
	mov		[ebx].SHEET.gfmt.rowhdr.txtcol,0FF0000h
	mov		[ebx].SHEET.gfmt.rowhdr.txtal,FMTA_RIGHT or FMTA_MIDDLE or FMTD_0
	mov		[ebx].SHEET.gfmt.rowhdr.imgal,FMTA_LEFT or FMTA_MIDDLE

	mov		[ebx].SHEET.gfmt.winhdrbtn,TRUE
	mov		[ebx].SHEET.gfmt.winhdr.bckcol,0C0C0C0h
	mov		[ebx].SHEET.gfmt.winhdr.txtcol,0FFh
	mov		[ebx].SHEET.gfmt.winhdr.txtal,FMTA_CENTER or FMTA_MIDDLE or FMTD_0
	mov		[ebx].SHEET.gfmt.winhdr.imgal,FMTA_LEFT or FMTA_MIDDLE

	mov		[ebx].SHEET.gfmt.cell.bckcol,0FFFFFFh
	mov		[ebx].SHEET.gfmt.cell.txtcol,0h
	mov		[ebx].SHEET.gfmt.cell.txtal,FMTA_AUTO or FMTA_MIDDLE or FMTD_2
	mov		[ebx].SHEET.gfmt.cell.imgal,FMTA_LEFT or FMTA_MIDDLE

	mov		[ebx].SHEET.gfmt.grdcol,0C0C0C0h
	mov		[ebx].SHEET.gfmt.lockcol,0FFF0F0h
	mov		[ebx].SHEET.gfmt.bcknfcol,0C0C0C0h
	mov		[ebx].SHEET.gfmt.txtnfcol,0h
	mov		[ebx].SHEET.gfmt.bckfocol,0800000h
	mov		[ebx].SHEET.gfmt.txtfocol,0FFFFFFh

	;Splitts
	lea		edx,[ebx].SHEET.owin
	xor		ecx,ecx
	.while ecx<=WINMAX
		mov		[edx].WIN.nwin,ecx
		mov		[edx].WIN.act,-1
		mov		[edx].WIN.tcol,1
		mov		[edx].WIN.trow,1
		mov		[edx].WIN.ccol,1
		mov		[edx].WIN.crow,1
		mov		[edx].WIN.mcol,1
		mov		[edx].WIN.mrow,1
		mov		[edx].WIN.lcol,0
		mov		[edx].WIN.lrow,0
		add		edx,sizeof WIN
		inc		ecx
	.endw
	lea		edx,[ebx].SHEET.owin
	mov		[edx].WIN.act,1
	;Headers
	invoke MakeColHdr,ebx
	invoke MakeRowHdr,ebx
	mov		eax,ebx
	ret

InitSheetMem endp

GetX proc uses ebx esi edi,lpSheet:DWORD,nCol:DWORD
	LOCAL	glbl:DWORD

	mov		ebx,lpSheet
	mov		esi,[ebx].SHEET.lprowmem
	mov		esi,[esi]
	add		esi,sizeof ROWDTA-4
	xor		eax,eax
	xor		ecx,ecx
	xor		edx,edx
  Nx:
	add		eax,edx
	mov		glbl,0
	movzx	edx,word ptr [esi].COLDTA.fmt.tpe[1]
	.if edx==0FFFFh
		inc		glbl
		mov		edx,[ebx].SHEET.gfmt.ghdrwt
		.if ecx
			mov		edx,[ebx].SHEET.gfmt.gcellwt
		.endif
	.endif
	movzx	edi,[esi].COLDTA.len
	add		esi,edi
	inc		ecx
	cmp		nCol,ecx
	jnb		Nx
	mov		ecx,glbl
	ret

GetX endp

GetColFromX proc uses ebx esi edi,lpSheet:DWORD,nX:DWORD

	mov		ebx,lpSheet
	mov		esi,[ebx].SHEET.lprowmem
	mov		esi,[esi]
	add		esi,sizeof ROWDTA-4
	mov		eax,nX
	xor		ecx,ecx
  Nx:
	movzx	edx,word ptr [esi].COLDTA.fmt.tpe[1]
	.if edx==0FFFFh
		mov		edx,[ebx].SHEET.gfmt.ghdrwt
		.if ecx
			mov		edx,[ebx].SHEET.gfmt.gcellwt
		.endif
	.endif
	movzx	edi,[esi].COLDTA.len
	add		esi,edi
	inc		ecx
	sub		eax,edx
	jnb		Nx
	dec		ecx
	mov		eax,ecx
	ret

GetColFromX endp

GetY proc uses ebx esi edi,lpSheet:DWORD,nRow:DWORD
	LOCAL	glbl:DWORD

	mov		ebx,lpSheet
	xor		eax,eax
	xor		ecx,ecx
	xor		edx,edx
	mov		edi,[ebx].SHEET.tr
	.if [ebx].SHEET.ty && edi<=nRow
		mov		eax,[ebx].SHEET.ty
		mov		ecx,edi
	.endif
  Nx:
	mov		esi,[ebx].SHEET.lprowmem
	add		eax,edx
	mov		esi,[esi+ecx*4]
	mov		glbl,0
	.if esi
		inc		ecx
		movzx	edx,[esi].ROWDTA.rowht
		.if edx==0FFFFh
			inc		glbl
			mov		edx,[ebx].SHEET.gfmt.ghdrht
			.if ecx
				mov		edx,[ebx].SHEET.gfmt.gcellht
			.endif
		.endif
		cmp		nRow,ecx
		jnb		Nx
	.endif
	mov		ecx,glbl
	ret

GetY endp

GetRowFromY proc uses ebx esi edi,lpSheet:DWORD,nY:DWORD

	mov		ebx,lpSheet
	mov		eax,nY
	xor		ecx,ecx
  Nx:
	mov		esi,[ebx].SHEET.lprowmem
	lea		esi,[esi+ecx*4]
	mov		esi,[esi]
	.if esi
		movzx	edx,[esi].ROWDTA.rowht
		.if edx==0FFFFh
			mov		edx,[ebx].SHEET.gfmt.ghdrht
			.if ecx
				mov		edx,[ebx].SHEET.gfmt.gcellht
			.endif
		.endif
		inc		ecx
		sub		eax,edx
		jnb		Nx
	.endif
	dec		ecx
	mov		eax,ecx
	ret

GetRowFromY endp

GetCellRect proc uses ebx,lpSheet:DWORD,lpWin:DWORD,nCol:DWORD,nRow:DWORD,lpRect:DWORD

	mov		ebx,lpRect
	invoke GetX,lpSheet,nCol
	mov		[ebx].RECT.left,eax
	add		eax,edx
	mov		[ebx].RECT.right,eax
	push	ecx
	invoke GetY,lpSheet,nRow
	mov		[ebx].RECT.top,eax
	add		eax,edx
	mov		[ebx].RECT.bottom,eax
	pop		eax
	mov		ch,cl
	mov		cl,al
	ret

GetCellRect endp

TestCellRect proc uses ebx esi,lpWin:DWORD,lpRect:DWORD

	mov		esi,lpWin
	mov		ebx,lpRect
	xor		eax,eax
	mov		edx,[ebx].RECT.left
	add		edx,[esi].WIN.rect.left
	.if edx>[esi].WIN.rect.right
		or		eax,4
	.endif
	mov		edx,[ebx].RECT.top
	add		edx,[esi].WIN.rect.top
	.if edx>[esi].WIN.rect.bottom
		or		eax,8
	.endif
	mov		edx,[ebx].RECT.right
	add		edx,[esi].WIN.rect.left
	.if edx>[esi].WIN.rect.right
		or		eax,1
	.endif
	mov		edx,[ebx].RECT.bottom
	add		edx,[esi].WIN.rect.top
	.if edx>[esi].WIN.rect.bottom
		or		eax,2
	.endif
	ret

TestCellRect endp

AdjustCellRect proc uses ebx esi edi,lpSheet:DWORD,lpWin:DWORD,lpRect:DWORD
	LOCAL	rect1:RECT
	LOCAL	rect2:RECT

	mov		esi,lpWin
	mov		eax,[esi].WIN.ccol
	mov		ecx,[esi].WIN.crow
	mov		ebx,lpSheet
	mov		edi,lpRect
	.if eax<=[esi].WIN.lcol && ecx<=[esi].WIN.lrow
		;Within locked area
		ret
	.endif
	invoke GetCellRect,ebx,esi,[esi].WIN.lcol,[esi].WIN.lrow,addr rect1
	invoke GetCellRect,ebx,esi,[esi].WIN.tcol,[esi].WIN.trow,addr rect2
	mov		eax,rect1.right
	sub		rect2.left,eax
	sub		rect2.right,eax
	mov		eax,rect1.bottom
	sub		rect2.top,eax
	sub		rect2.bottom,eax
	mov		eax,[esi].WIN.ccol
	.if eax>[esi].WIN.lcol
		mov		eax,rect2.left
		sub		[edi].RECT.left,eax
		sub		[edi].RECT.right,eax
	.endif
	mov		eax,[esi].WIN.crow
	.if eax>[esi].WIN.lrow
		mov		eax,rect2.top
		sub		[edi].RECT.top,eax
		sub		[edi].RECT.bottom,eax
	.endif
	ret

AdjustCellRect endp

GetRealCellRect proc uses esi,lpSheet:DWORD,lpWin:DWORD,lpRect:DWORD

	mov		esi,lpWin
	invoke GetCellRect,lpSheet,esi,[esi].WIN.ccol,[esi].WIN.crow,lpRect
	invoke AdjustCellRect,lpSheet,esi,lpRect
	ret

GetRealCellRect endp

TestCurCol proc uses esi,lpWin:DWORD

	mov		esi,lpWin
	xor		edx,edx
	mov		eax,[esi].WIN.ccol
	.if eax<[esi].WIN.tcol
		mov		[esi].WIN.tcol,eax
		mov		edx,2
	.endif
	mov		eax,[esi].WIN.lcol
	.if eax>=[esi].WIN.tcol
		inc		eax
		mov		[esi].WIN.tcol,eax
		mov		edx,2
	.endif
	mov		eax,edx
	ret

TestCurCol endp

TestCurRow proc uses esi,lpWin:DWORD

	mov		esi,lpWin
	xor		edx,edx
	mov		eax,[esi].WIN.crow
	.if eax<[esi].WIN.trow
		mov		[esi].WIN.trow,eax
		mov		edx,1
	.endif
	mov		eax,[esi].WIN.lrow
	.if eax>=[esi].WIN.trow
		inc		eax
		mov		[esi].WIN.trow,eax
		mov		edx,1
	.endif
	mov		eax,edx
	ret

TestCurRow endp

TestCurPos proc uses ebx esi,lpSheet:DWORD,lpWin:DWORD
	LOCAL	rect:RECT
	LOCAL	flag:DWORD

	mov		ebx,lpSheet
	mov		esi,lpWin
	invoke TestCurCol,esi
	mov		flag,eax
	invoke TestCurRow,esi
	or		flag,eax
  Nx:
	invoke GetRealCellRect,ebx,esi,addr rect
	test	[ebx].SHEET.winst,SPS_VSCROLL
	.if !ZERO?
		add		rect.right,SBSIZE
	.endif
	test	[ebx].SHEET.winst,SPS_HSCROLL
	.if !ZERO?
		add		rect.bottom,SBSIZE
	.endif
	invoke TestCellRect,esi,addr rect
	test	eax,1
	je		@f
	mov		edx,[esi].WIN.tcol
	.if edx<[esi].WIN.ccol
		inc 	[esi].WIN.tcol
		or		flag,2
	.else
		and		eax,2
	.endif
  @@:
	test	eax,2
	je		@f
	mov		edx,[esi].WIN.trow
	.if edx<[esi].WIN.crow
		inc 	[esi].WIN.trow
		or		flag,1
	.else
		and		eax,1
	.endif
  @@:
	test	eax,3
	jne		Nx
	mov		eax,flag
	ret

TestCurPos endp

TestSync proc uses esi,lpWin:DWORD
	LOCAL	fSync:DWORD

	mov		esi,lpWin
	mov		fSync,3
	mov		ecx,[esi].WIN.nwin
	mov		edx,esi
	.while ecx
		sub		edx,sizeof WIN
		dec		ecx
		mov		eax,[edx].WIN.sync
		and		fSync,eax
		je		ExPrev
		test	eax,1
		je		@f
		mov		eax,[esi].WIN.trow
		.if eax!=[edx].WIN.trow
			mov		[edx].WIN.trow,eax
			pushad
			invoke InvalidateRect,[edx].WIN.hwin,NULL,TRUE
			popad
		.endif
	  @@:
		test	eax,2
		je		@f
		mov		eax,[esi].WIN.tcol
		.if eax!=[edx].WIN.tcol
			mov		[edx].WIN.tcol,eax
			pushad
			invoke InvalidateRect,[edx].WIN.hwin,NULL,TRUE
			popad
		.endif
	  @@:
	.endw
  ExPrev:
	mov		fSync,3
	mov		ecx,[esi].WIN.nwin
	mov		edx,esi
	.while ecx<WINMAX-1
		mov		eax,[edx].WIN.sync
		add		edx,sizeof WIN
		inc		ecx
		and		fSync,eax
		je		ExNext
		test	eax,1
		je		@f
		mov		eax,[esi].WIN.trow
		.if eax!=[edx].WIN.trow
			mov		[edx].WIN.trow,eax
			pushad
			invoke InvalidateRect,[edx].WIN.hwin,NULL,TRUE
			popad
		.endif
	  @@:
		test	eax,2
		je		@f
		mov		eax,[esi].WIN.tcol
		.if eax!=[edx].WIN.tcol
			mov		[edx].WIN.tcol,eax
			pushad
			invoke InvalidateRect,[edx].WIN.hwin,NULL,TRUE
			popad
		.endif
	  @@:
	.endw
  ExNext:
	ret

TestSync endp

CurMove proc uses ebx esi,lpSheet:DWORD,lpWin:DWORD,nCols:DWORD,nRows:DWORD,fMulSel:DWORD

	mov		ebx,lpSheet
	mov		esi,lpWin
	mov		eax,nCols
	add		[esi].WIN.ccol,eax
	mov		eax,nRows
	add		[esi].WIN.crow,eax
	mov		eax,fMulSel
	.if !al
		mov		eax,[esi].WIN.ccol
		mov		[esi].WIN.mcol,eax
		mov		eax,[esi].WIN.crow
		mov		[esi].WIN.mrow,eax
	.endif
	ret

CurMove endp

GetCellFromPt proc uses ebx esi,lpSheet:DWORD,lpWin:DWORD,lpPt:DWORD
	LOCAL	rect:RECT

	mov		ebx,lpSheet
	mov		esi,lpWin
	push	[esi].WIN.ccol
	push	[esi].WIN.crow
	mov		[esi].WIN.ccol,0
	mov		eax,[esi].WIN.trow
	mov		[esi].WIN.crow,eax
	mov		[esi].WIN.ccol,0
	invoke GetRealCellRect,ebx,esi,addr rect
	mov		edx,lpPt
	mov		edx,[edx].POINT.y
	.if edx<rect.top
		mov		[esi].WIN.crow,0
	.endif
	mov		eax,[esi].WIN.crow
	.while eax<=[ebx].SHEET.gfmt.nrows
		invoke GetRealCellRect,ebx,esi,addr rect
		mov		edx,lpPt
		mov		edx,[edx].POINT.y
	  .break .if edx>=rect.top && edx<=rect.bottom
		inc		[esi].WIN.crow
		mov		eax,[esi].WIN.crow
	.endw
	mov		eax,[esi].WIN.crow
	.if eax<=[ebx].SHEET.gfmt.nrows && eax
		mov		eax,[esi].WIN.ccol
		.while eax<=[ebx].SHEET.gfmt.ncols
			invoke GetRealCellRect,ebx,esi,addr rect
			mov		edx,lpPt
			mov		edx,[edx].POINT.x
		  .break .if edx>=rect.left && edx<=rect.right
			inc		[esi].WIN.ccol
			mov		eax,[esi].WIN.ccol
		.endw
		mov		eax,[esi].WIN.ccol
		.if eax<=[ebx].SHEET.gfmt.ncols && eax
			pop		eax
			pop		eax
			mov		eax,[esi].WIN.crow
			shl		eax,16
			or		eax,[esi].WIN.ccol
		.else
			pop		[esi].WIN.crow
			pop		[esi].WIN.ccol
			xor		eax,eax
		.endif
	.else
		pop		[esi].WIN.crow
		pop		[esi].WIN.ccol
		xor		eax,eax
	.endif
	ret

GetCellFromPt endp

BlankCell proc uses ebx,lpSheet:DWORD,nCol:DWORD,nRow:DWORD
	LOCAL	buffer[4]:BYTE

	mov		ebx,lpSheet
	invoke FindCell,ebx,nCol,nRow
	.if eax
		mov		buffer,0
		invoke UpdateCell,ebx,nCol,nRow,TPE_EMPTY,addr buffer,0
	.endif
	ret

BlankCell endp

SetCellData proc uses ebx esi edi,lpSheet:DWORD,lpSpri:DWORD

	mov		edi,lpSpri
	mov		ebx,lpSheet
	invoke FindCell,ebx,[edi].SPR_ITEM.col,[edi].SPR_ITEM.row
	.if !eax
		invoke MakeNewCell,ebx,[edi].SPR_ITEM.col,[edi].SPR_ITEM.row
		mov		eax,[ebx].SHEET.lpcol
	.endif
	.if eax
		mov		esi,eax
		mov		edx,[edi].SPR_ITEM.flag
		test	edx,SPRIF_TYPE
		je		@f
		mov		al,[edi].SPR_ITEM.fmt.tpe
		mov		[esi].COLDTA.fmt.tpe,al
	  @@:
		test	edx,SPRIF_DATA
		je		@f
		test	edx,SPRIF_COMPILE
		.if !ZERO?
			invoke Compile,ebx,[edi].SPR_ITEM.lpdta,addr buff
			lea		eax,buff
			mov		[edi].SPR_ITEM.lpdta,eax
		.endif
		movzx	eax,[esi].COLDTA.fmt.tpe
		.if eax==TPE_COLHDR || eax==TPE_ROWHDR || eax==TPE_WINHDR
			push	eax
			mov		ax,word ptr [esi].COLDTA.fmt.tpe[1]
			mov		word ptr buff,ax
			invoke StrCpy,addr buff[2],[edi].SPR_ITEM.lpdta
			lea		edx,buff
			pop		eax
		.else
			mov		edx,[edi].SPR_ITEM.lpdta
			test	[edi].SPR_ITEM.flag,SPRIF_DOUBLE
			.if !ZERO?
				fld		qword ptr [edx]
				fstp	exdouble
				mov		edx,offset exdouble
			.endif
			test	[edi].SPR_ITEM.flag,SPRIF_SINGLE
			.if !ZERO?
				fld		dword ptr [edx]
				fstp	exdouble
				mov		edx,offset exdouble
			.endif
		.endif
		invoke UpdateCell,ebx,[edi].SPR_ITEM.col,[edi].SPR_ITEM.row,eax,edx,esi
		mov		edx,[edi].SPR_ITEM.flag
	  @@:
		test	edx,SPRIF_BACKCOLOR
		je		@f
		mov		eax,[edi].SPR_ITEM.fmt.bckcol
		mov		[esi].COLDTA.fmt.bckcol,eax
	  @@:
		test	edx,SPRIF_TEXTCOLOR
		je		@f
		mov		eax,[edi].SPR_ITEM.fmt.txtcol
		mov		[esi].COLDTA.fmt.txtcol,eax
	  @@:
		test	edx,SPRIF_TEXTALIGN
		je		@f
		mov		al,[edi].SPR_ITEM.fmt.txtal
		mov		[esi].COLDTA.fmt.txtal,al
	  @@:
		test	edx,SPRIF_IMAGEALIGN
		je		@f
		mov		al,[edi].SPR_ITEM.fmt.imgal
		mov		[esi].COLDTA.fmt.imgal,al
	  @@:
		test	edx,SPRIF_STATE
		je		@f
		mov		al,[edi].SPR_ITEM.state
		mov		[esi].COLDTA.state,al
	  @@:
		test	edx,SPRIF_FONT
		je		@f
		mov		al,[edi].SPR_ITEM.fmt.fnt
		mov		[esi].COLDTA.fmt.fnt,al
	  @@:
		test	edx,SPRIF_WIDTH
		je		@f
		push	edx
		invoke FindCell,ebx,[edi].SPR_ITEM.col,0
		mov		edx,[edi].SPR_ITEM.wt
		mov		word ptr [eax].COLDTA.fmt.tpe[1],dx
		pop		edx
	  @@:
		test	edx,SPRIF_HEIGHT
		je		@f
		push	edx
		invoke FindRow,ebx,[edi].SPR_ITEM.row
		mov		edx,[edi].SPR_ITEM.ht
		mov		[eax].ROWDTA.rowht,dx
		pop		edx
	  @@:
		.if [esi].COLDTA.fmt.tpe==TPE_GRAPH
			mov		eax,dword ptr [esi].COLDTA.fmt.tpe[1]
			.if eax
				invoke DeleteObject,eax
				mov		dword ptr [esi].COLDTA.fmt.tpe[1],0
			.endif
		.endif
		mov		eax,esi
	.endif
	ret

SetCellData endp

GetCellData proc uses ebx esi edi,lpSheet:DWORD,lpWin:DWORD,lpSpri:DWORD
	LOCAL	rect:RECT

	mov		ebx,lpSheet
	mov		edi,lpSpri
	invoke FindCell,ebx,[edi].SPR_ITEM.col,[edi].SPR_ITEM.row
	.if eax
		mov		esi,eax
		mov		eax,[esi].COLDTA.fmt.bckcol
		mov		[edi].SPR_ITEM.fmt.bckcol,eax
		mov		eax,[esi].COLDTA.fmt.txtcol
		mov		[edi].SPR_ITEM.fmt.txtcol,eax
		mov		al,[esi].COLDTA.fmt.txtal
		mov		[edi].SPR_ITEM.fmt.txtal,al
		mov		al,[esi].COLDTA.fmt.imgal
		mov		[edi].SPR_ITEM.fmt.imgal,al
		mov		al,[esi].COLDTA.state
		mov		[edi].SPR_ITEM.state,al
		mov		al,[esi].COLDTA.fmt.fnt
		mov		[edi].SPR_ITEM.fmt.fnt,al
		mov		al,[esi].COLDTA.expx
		mov		[edi].SPR_ITEM.expx,al
		mov		al,[esi].COLDTA.expy
		mov		[edi].SPR_ITEM.expy,al
		mov		al,[esi].COLDTA.fmt.tpe
		mov		[edi].SPR_ITEM.fmt.tpe,al
		lea		eax,[esi].COLDTA.fmt.tpe[1]
		mov		[edi].SPR_ITEM.lpdta,eax
		test	[edi].SPR_ITEM.flag,SPRIF_DOUBLE
		.if !ZERO?
			mov		al,[esi].COLDTA.fmt.tpe
			.if al==TPE_FLOAT || al==TPE_FORMULA
				lea		eax,[esi].COLDTA.fmt.tpe[1]
				fld		tbyte ptr [eax]
				fstp	double
				mov		[edi].SPR_ITEM.lpdta,offset double
			.elseif al==TPE_INTEGER || al==TPE_CHECKBOX || al==TPE_COMBOBOX || al==TPE_OWNERDRAWINTEGER
				lea		eax,[esi].COLDTA.fmt.tpe[1]
				fild	dword ptr [eax]
				fstp	double
				mov		[edi].SPR_ITEM.lpdta,offset double
			.else
				fldz
				fstp	double
				mov		[edi].SPR_ITEM.lpdta,offset double
			.endif
		.endif
		test	[edi].SPR_ITEM.flag,SPRIF_SINGLE
		.if !ZERO?
			mov		al,[esi].COLDTA.fmt.tpe
			.if al==TPE_FLOAT || al==TPE_FORMULA
				lea		eax,[esi].COLDTA.fmt.tpe[1]
				fld		tbyte ptr [eax]
				fstp	single
				mov		[edi].SPR_ITEM.lpdta,offset single
			.elseif al==TPE_INTEGER || al==TPE_CHECKBOX || al==TPE_COMBOBOX || al==TPE_OWNERDRAWINTEGER
				lea		eax,[esi].COLDTA.fmt.tpe[1]
				fild	dword ptr [eax]
				fstp	single
				mov		[edi].SPR_ITEM.lpdta,offset single
			.else
				fldz
				fstp	single
				mov		[edi].SPR_ITEM.lpdta,offset single
			.endif
		.endif
		xor		eax,eax
	.else
		mov		[edi].SPR_ITEM.fmt.bckcol,-1
		mov		[edi].SPR_ITEM.fmt.txtcol,-1
		mov		[edi].SPR_ITEM.fmt.txtal,-1
		mov		[edi].SPR_ITEM.fmt.imgal,-1
		mov		[edi].SPR_ITEM.state,0
		mov		[edi].SPR_ITEM.fmt.fnt,-1
		mov		[edi].SPR_ITEM.expx,0
		mov		[edi].SPR_ITEM.expy,0
		mov		[edi].SPR_ITEM.fmt.tpe,TPE_EMPTY
		mov		[edi].SPR_ITEM.wt,-1
		mov		[edi].SPR_ITEM.ht,-1
		mov		[edi].SPR_ITEM.lpdta,0
		mov		eax,-1
	.endif
	push	eax
	invoke GetCellRect,ebx,lpWin,[edi].SPR_ITEM.col,[edi].SPR_ITEM.row,addr rect
	.if cl
		mov		[edi].SPR_ITEM.wt,-1
	.else
		mov		eax,rect.right
		sub		eax,rect.left
		mov		[edi].SPR_ITEM.wt,eax
	.endif
	.if ch
		mov		[edi].SPR_ITEM.ht,-1
	.else
		mov		eax,rect.bottom
		sub		eax,rect.top
		mov		[edi].SPR_ITEM.ht,eax
	.endif
	pop		eax
	ret

GetCellData endp

DeleteRow proc uses ebx esi edi,lpSheet:DWORD,nRow:DWORD
	LOCAL	buffer[32]:BYTE
	LOCAL	fGridMode:DWORD

	mov		ebx,lpSheet
	mov		eax,nRow
	.if eax && eax<=[ebx].SHEET.gfmt.nrows
		mov		eax,[ebx].SHEET.winst
		and		eax,SPS_GRIDMODE
		mov		fGridMode,eax
		mov		[ebx].SHEET.lpcol,0
		mov		[ebx].SHEET.lprow,0
		invoke FindRow,ebx,nRow
		mov		ecx,nRow
		.if cx==[eax].ROWDTA.rown && [eax].ROWDTA.len
			mov		edi,[ebx].SHEET.lprowmem
			lea		edi,[edi+ecx*4]
			invoke GlobalFree,[edi]
			lea		esi,[edi+4]
			.while dword ptr [esi]
				mov		eax,[esi]
				mov		[edi],eax
				dec		[eax].ROWDTA.rown
				.if !fGridMode
					push	edi
					mov		edi,eax
					mov		[ebx].SHEET.lprow,edi
					movzx	edx,[edi].ROWDTA.rown
					invoke DwToAscii,edx,addr buffer
					add		edi,sizeof ROWDTA-4
					mov		ax,[edi].COLDTA.len
					.if ax
						mov		[ebx].SHEET.lpcol,edi
						add		edi,sizeof COLDTA
						invoke StrLen,edi
						push	eax
						invoke StrLen,addr buffer
						pop		ecx
						.if eax==ecx
							invoke StrCpy,edi,addr buffer
						.else
							sub		eax,ecx
							invoke MemMove,ebx,edi,eax
							mov		edi,eax
							invoke StrCpy,edi,addr buffer
						.endif
					.endif
					pop		edi
				.endif
				lea		esi,[esi+4]
				lea		edi,[edi+4]
			.endw
			mov		dword ptr [edi],0
			mov		[ebx].SHEET.lpcol,0
			mov		[ebx].SHEET.lprow,0
			dec		[ebx].SHEET.gfmt.nrows
			xor		eax,eax
		.else
			mov		eax,-1
		.endif
	.else
		mov		eax,-1
	.endif
	mov		[ebx].SHEET.lpcol,0
	mov		[ebx].SHEET.lprow,0
	ret

DeleteRow endp

DeleteCol proc uses ebx edi,lpSheet:DWORD,nCol:DWORD
	LOCAL	buffer[32]:BYTE
	LOCAL	nRow:DWORD
	LOCAL	fGridMode:DWORD

	mov		ebx,lpSheet
	mov		eax,nCol
	.if eax && eax<=[ebx].SHEET.gfmt.ncols
		mov		[ebx].SHEET.lpcol,0
		mov		[ebx].SHEET.lprow,0
		mov		eax,[ebx].SHEET.winst
		and		eax,SPS_GRIDMODE
		mov		fGridMode,eax
		mov		eax,[ebx].SHEET.gfmt.nrows
		inc		eax
		mov		nRow,eax
		.while nRow
			dec		nRow
			invoke FindRow,ebx,nRow
			mov		ecx,nRow
			.if cx==[eax].ROWDTA.rown && [eax].ROWDTA.len
				invoke FindCol,ebx,nCol
				mov		edi,eax
				.if [edi].COLDTA.len
					mov		ecx,nCol
					.if cx==[edi].COLDTA.coln
						mov		[ebx].SHEET.lpcol,0
						movzx	ecx,[edi].COLDTA.len
						neg		ecx
						invoke MemMove,ebx,edi,ecx
						mov		edi,eax
					.endif
					call RenumCols
				.endif
			.endif
		.endw
		dec		[ebx].SHEET.gfmt.ncols
		xor		eax,eax
	.else
		mov		eax,-1
	.endif
	mov		[ebx].SHEET.lpcol,0
	mov		[ebx].SHEET.lprow,0
	ret

RenumCols:
	movzx	edx,[edi].COLDTA.len
	.if edx
		.if !nRow && !fGridMode
			mov		cx,word ptr [edi].COLDTA.fmt.tpe[3]
			.if cl
				dec		ch
				.if ch<'A'
					mov		ch,'Z'
					dec		cl
				.endif
				mov		word ptr [edi].COLDTA.fmt.tpe[3],cx
			.endif
		.endif
		dec		[edi].COLDTA.coln
		add		edi,edx
		jmp		RenumCols
	.endif
	retn

DeleteCol endp

InsertRow proc uses ebx esi edi,lpSheet:DWORD,nRow:DWORD
	LOCAL	buffer[32]:BYTE
	LOCAL	fGridMode:DWORD

	mov		ebx,lpSheet
	mov		eax,nRow
	dec		eax
	.if eax<=[ebx].SHEET.gfmt.nrows
		mov		eax,[ebx].SHEET.winst
		and		eax,SPS_GRIDMODE
		mov		fGridMode,eax
		mov		[ebx].SHEET.lpcol,0
		mov		[ebx].SHEET.lprow,0
		invoke FindRow,ebx,nRow
		mov		ecx,nRow
		.if cx==[eax].ROWDTA.rown && [eax].ROWDTA.len
			mov		esi,[ebx].SHEET.lprowmem
			mov		ecx,nRow
			lea		esi,[esi+ecx*4]
			mov		edi,[esi]
			mov		dword ptr [esi],0
			.while edi
				inc		[edi].ROWDTA.rown
				.if !fGridMode
					push	edi
					mov		[ebx].SHEET.lprow,edi

					mov		[ebx].SHEET.lpcol,0
					movzx	edx,[edi].ROWDTA.rown
					invoke DwToAscii,edx,addr buffer
					add		edi,sizeof ROWDTA-4
					mov		ax,[edi].COLDTA.len
					.if ax
						mov		[ebx].SHEET.lpcol,edi
						add		edi,sizeof COLDTA
						invoke StrLen,edi
						push	eax
						invoke StrLen,addr buffer
						pop		ecx
						.if eax==ecx
							invoke StrCpy,edi,addr buffer
						.else
							sub		eax,ecx
							invoke MemMove,ebx,edi,eax
							mov		edi,eax
							invoke StrCpy,edi,addr buffer
						.endif
					.endif
					pop		edi
				.endif
				lea		esi,[esi+4]
				xchg	edi,[esi]
			.endw
			mov		[ebx].SHEET.lpcol,0
			mov		[ebx].SHEET.lprow,0
			inc		[ebx].SHEET.gfmt.nrows
			invoke DwToAscii,nRow,addr buffer
			invoke UpdateCell,ebx,0,nRow,TPE_ROWHDR,addr buffer,0
			xor		eax,eax
		.else
			mov		eax,-1
		.endif
	.else
		mov		eax,-1
	.endif
	ret

InsertRow endp

ColToStr proc nCol:DWORD

	mov		eax,nCol
	dec		eax
	xor		edx,edx
	mov		ecx,26
	div		ecx
	mov		ah,dl
	add		ax,'AA'
	ret

ColToStr endp

InsertCol proc uses ebx edi,lpSheet:DWORD,nCol:DWORD
	LOCAL	buffer[32]:BYTE
	LOCAL	nRow:DWORD
	LOCAL	fGridMode:DWORD

	mov		ebx,lpSheet
	mov		eax,nCol
	dec		eax
	.if eax<=[ebx].SHEET.gfmt.ncols
		mov		eax,[ebx].SHEET.winst
		and		eax,SPS_GRIDMODE
		mov		fGridMode,eax
		mov		eax,[ebx].SHEET.gfmt.nrows
		inc		eax
		mov		nRow,eax
		.while nRow
			dec		nRow
			invoke FindRow,ebx,nRow
			mov		ecx,nRow
			.if cx==[eax].ROWDTA.rown && [eax].ROWDTA.len
				invoke FindCol,ebx,nCol
				mov		edi,eax
				.if [edi].COLDTA.len
					call RenumCols
					.if !nRow
						mov		dword ptr buffer,0FFFFh
						.if !fGridMode
							invoke ColToStr,nCol
							mov		dword ptr buffer[2],eax
						.endif
						invoke UpdateCell,ebx,nCol,0,TPE_COLHDR,addr buffer,0
					.endif
				.endif
			.endif
		.endw
		inc		[ebx].SHEET.gfmt.ncols
		xor		eax,eax
	.else
		mov		eax,-1
	.endif
	ret

RenumCols:
	movzx	edx,[edi].COLDTA.len
	.if edx
		.if !nRow && !fGridMode
			mov		cx,word ptr [edi].COLDTA.fmt.tpe[3]
			.if cl
				inc		ch
				.if ch>'Z'
					mov		ch,'A'
					inc		cl
				.endif
				mov		word ptr [edi].COLDTA.fmt.tpe[3],cx
			.endif
		.endif
		inc		[edi].COLDTA.coln
		add		edi,edx
		jmp		RenumCols
	.endif
	retn

InsertCol endp

GetImpData proc uses esi edi,lpDest:DWORD,lpSource:DWORD,nSepChar:DWORD

	mov		esi,lpSource
	mov		edi,lpDest
	mov		edx,nSepChar
  @@:
	mov		al,[esi]
	.if al
		inc		esi
		.if al!=dl
			mov		[edi],al
			inc		edi
			jmp		@b
		.endif
	.endif
	xor		al,al
	mov		[edi],al
	mov		eax,esi
	sub		eax,lpSource
	ret

GetImpData endp

ConvInt proc uses esi,lpDta:DWORD

	mov		esi,lpDta
	xor		eax,eax
	inc		al
	.while al
		mov		al,[esi]
		.if al && (al<'0' || al>'9')
			inc		ah
			.break
		.endif
		inc		esi
	.endw
	.if !ah
		mov		esi,lpDta
		invoke AsciiToDw,esi
		mov		[esi],eax
		xor		eax,eax
		inc		eax
	.else
		xor		eax,eax
	.endif
	ret

ConvInt endp

DecompFormula proc uses esi edi,lpFormula:DWORD,lpStr:DWORD

	mov		esi,lpFormula
	mov		edi,lpStr
  @@:
	mov		al,[esi]
	inc		esi
	.if al=='+' || al=='-' || al=='*' || al=='/' || al=='(' || al==')' || al=='^' || al==','
		mov		[edi],al
		inc		edi
		jmp		@b
	.elseif al==TPE_NOTEQU
		mov		word ptr [edi],'><'
		add		edi,2
		jmp		@b
	.elseif al==TPE_GTOREQU
		mov		word ptr [edi],'=>'
		add		edi,2
		jmp		@b
	.elseif al==TPE_LEOREQU
		mov		word ptr [edi],'=<'
		add		edi,2
		jmp		@b
	.elseif al==TPE_GT
		mov		byte ptr [edi],'>'
		add		edi,1
		jmp		@b
	.elseif al==TPE_EQU
		mov		byte ptr [edi],'='
		add		edi,1
		jmp		@b
	.elseif al==TPE_LE
		mov		byte ptr [edi],'<'
		add		edi,1
		jmp		@b
	.elseif al==TPE_AND
		mov		dword ptr [edi],'dnA '
		add		edi,4
		mov		byte ptr [edi],' '
		add		edi,1
		jmp		@b
	.elseif al==TPE_OR
		mov		dword ptr [edi],' rO '
		add		edi,4
		jmp		@b
	.elseif al==TPE_XOR
		mov		dword ptr [edi],'roX '
		add		edi,4
		mov		byte ptr [edi],' '
		add		edi,1
		jmp		@b
	.elseif al==TPE_INTEGER
		mov		eax,[esi]
		invoke DwToAscii,eax,edi
		add		esi,4
		invoke StrLen,edi
		add		edi,eax
		jmp		@b
	.elseif al==TPE_FLOAT
		invoke FpToAscii,esi,edi,FALSE
		add		esi,10
		invoke StrLen,edi
		add		edi,eax
		jmp		@b
	.elseif al==TPE_CELLREF
		call ConvCellRef
		jmp		@b
	.elseif al==TPE_RELCELLREF
		call ConvRelCellRef
		jmp		@b
	.elseif al==TPE_AREAREF
		mov		al,[esi]
		inc		esi
		.if al==TPE_CELLREF
			call ConvCellRef
		.else
			call ConvRelCellRef
		.endif
		mov		byte ptr [edi],':'
		inc		edi
		mov		al,[esi]
		inc		esi
		.if al==TPE_CELLREF
			call ConvCellRef
		.else
			call ConvRelCellRef
		.endif
		jmp		@b
	.elseif al==TPE_SUMFUNCTION
		mov		dword ptr [edi],'(muS'
	  Fun:
		add		edi,4
		mov		al,[esi]
		inc		esi
		.if al==TPE_CELLREF
			call ConvCellRef
		.else
			call ConvRelCellRef
		.endif
		mov		byte ptr [edi],':'
		inc		edi
		mov		al,[esi]
		inc		esi
		.if al==TPE_CELLREF
			call ConvCellRef
		.else
			call ConvRelCellRef
		.endif
		mov		byte ptr [edi],')'
		inc		edi
		jmp		@b
	.elseif al==TPE_CNTFUNCTION
		mov		dword ptr [edi],'(tnC'
		jmp		Fun
	.elseif al==TPE_AVGFUNCTION
		mov		dword ptr [edi],'(gvA'
		jmp		Fun
	.elseif al==TPE_MINFUNCTION
		mov		dword ptr [edi],'(niM'
		jmp		Fun
	.elseif al==TPE_MAXFUNCTION
		mov		dword ptr [edi],'(xaM'
		jmp		Fun
	.elseif al==TPE_VARFUNCTION
		mov		dword ptr [edi],'(raV'
		jmp		Fun
	.elseif al==TPE_STDFUNCTION
		mov		dword ptr [edi],'(dtS'
		jmp		Fun
	.elseif al==TPE_SQTFUNCTION
		mov		dword ptr [edi],'(tqS'
		add		edi,4
		jmp		@b
	.elseif al==TPE_SINFUNCTION
		mov		dword ptr [edi],'(niS'
		add		edi,4
		jmp		@b
	.elseif al==TPE_COSFUNCTION
		mov		dword ptr [edi],'(soC'
		add		edi,4
		jmp		@b
	.elseif al==TPE_TANFUNCTION
		mov		dword ptr [edi],'(naT'
		add		edi,4
		jmp		@b
	.elseif al==TPE_RADFUNCTION
		mov		dword ptr [edi],'(daR'
		add		edi,4
		jmp		@b
	.elseif al==TPE_PIFUNCTION
		mov		dword ptr [edi],')(IP'
		add		edi,4
		jmp		@b
	.elseif al==TPE_IIFFUNCTION
		mov		dword ptr [edi],'(fII'
		add		edi,4
		jmp		@b
	.elseif al==TPE_ONFUNCTION
		mov		dword ptr [edi],'(nO'
		add		edi,3
		jmp		@b
	.elseif al==TPE_ABSFUNCTION
		mov		dword ptr [edi],'(sbA'
		add		edi,4
		jmp		@b
	.elseif al==TPE_SGNFUNCTION
		mov		dword ptr [edi],'(ngS'
		add		edi,4
		jmp		@b
	.elseif al==TPE_INTFUNCTION
		mov		dword ptr [edi],'(tnI'
		add		edi,4
		jmp		@b
	.elseif al==TPE_LOGFUNCTION
		mov		dword ptr [edi],'(goL'
		add		edi,4
		jmp		@b
	.elseif al==TPE_LNFUNCTION
		mov		dword ptr [edi],'(nL'
		add		edi,3
		jmp		@b
	.elseif al==TPE_EFUNCTION
		mov		dword ptr [edi],')(e'
		add		edi,3
		jmp		@b
	.elseif al==TPE_ASINFUNCTION
		mov		dword ptr [edi],'nisA'
		add		edi,4
		mov		byte ptr [edi],'('
		add		edi,1
		jmp		@b
	.elseif al==TPE_ACOSFUNCTION
		mov		dword ptr [edi],'socA'
		add		edi,4
		mov		byte ptr [edi],'('
		add		edi,1
		jmp		@b
	.elseif al==TPE_ATANFUNCTION
		mov		dword ptr [edi],'natA'
		add		edi,4
		mov		byte ptr [edi],'('
		add		edi,1
		jmp		@b
	.elseif al==TPE_GRDFUNCTION
		mov		dword ptr [edi],'(drG'
		add		edi,4
		jmp		@b
	.elseif al==TPE_RGBFUNCTION
		mov		dword ptr [edi],'(bgR'
		add		edi,4
		jmp		@b
	.elseif al==TPE_XFUNCTION
		mov		dword ptr [edi],')(x'
		add		edi,3
		jmp		@b
	.elseif al==TPE_GRPFUNCTION
		mov		dword ptr [edi],'(prG'
		add		edi,4
		jmp		@b
	.elseif al==TPE_GRPTFUNCTION
		mov		word ptr [edi],'(T'
		add		edi,2
		jmp		@b
	.elseif al==TPE_GRPXFUNCTION
		mov		word ptr [edi],'(X'
		add		edi,2
		jmp		@b
	.elseif al==TPE_GRPYFUNCTION
		mov		word ptr [edi],'(Y'
		add		edi,2
		jmp		@b
	.elseif al==TPE_GRPGXFUNCTION
		mov		dword ptr [edi],'(xg'
		add		edi,3
		jmp		@b
	.elseif al==TPE_GRPFXFUNCTION
		mov		dword ptr [edi],'(xf'
		add		edi,3
		jmp		@b
	.elseif al==TPE_CDATEFUNCTION
		mov		dword ptr [edi],'taDC'
		mov		dword ptr [edi+4],'(e'
		add		edi,6
		mov		al,[esi]
		.if al==TPE_STRING
			inc		esi
			call	ConvString
			mov		byte ptr [edi],')'
			inc		edi
		.endif
		jmp		@b
	.elseif al==TPE_STRING
		call	ConvString
		jmp		@b
	.endif
	mov		byte ptr [edi],0
	ret

ConvString:
	inc		esi
	mov		byte ptr [edi],'"'
	inc		edi
  NxStr:
	mov		al,[esi]
	mov		[edi],al
	inc		esi
	inc		edi
	or		al,al
	jne		NxStr
	mov		byte ptr [edi-1],'"'
	retn

ConvCellRef:
	movzx	eax,word ptr [esi]
	dec		eax
	mov		ecx,26
	xor		edx,edx
	div		ecx
	add		al,'A'
	add		dl,'A'
	mov		[edi],al
	mov		[edi+1],dl
	add		edi,2
	movzx	eax,word ptr [esi+2]
	invoke DwToAscii,eax,edi
	invoke StrLen,edi
	add		edi,eax
	add		esi,4
	retn

ConvRelCellRef:
	mov		word ptr [edi],'(@'
	add		edi,2
	movsx	eax,word ptr [esi]
	invoke DwToAscii,eax,edi
	invoke StrLen,edi
	add		edi,eax
	mov		byte ptr [edi],','
	inc		edi
	movsx	eax,word ptr [esi+2]
	invoke DwToAscii,eax,edi
	invoke StrLen,edi
	add		edi,eax
	mov		byte ptr [edi],')'
	inc		edi
	add		esi,4
	retn

DecompFormula endp

CheckClick proc uses ebx esi,lpSheet:DWORD,lpWin:DWORD,lpCell:DWORD
	LOCAL	spredt:SPR_EDIT

	mov		ebx,lpSheet
	mov		esi,lpWin
	mov		eax,lpCell
	push	eax
	mov		eax,[esi].WIN.ccol
	mov		[ebx].SHEET.spri.col,eax
	mov		eax,[esi].WIN.crow
	mov		[ebx].SHEET.spri.row,eax
	invoke GetCellData,ebx,esi,addr [ebx].SHEET.spri
	mov		eax,[ebx].SHEET.hwnd
	mov		spredt.hdr.hwndFrom,eax
	mov		eax,[ebx].SHEET.nid
	mov		spredt.hdr.idFrom,eax
	mov		spredt.hdr.code,SPRN_BEFOREUPDATE
	lea		eax,[ebx].SHEET.spri
	mov		spredt.lpspri,eax
	mov		spredt.fcancel,FALSE
	invoke SendMessage,[ebx].SHEET.howner,WM_NOTIFY,[ebx].SHEET.nid,addr spredt
	pop		eax
	.if !spredt.fcancel
		xor		dword ptr [eax].COLDTA.fmt.tpe[1],1
		mov		eax,[esi].WIN.ccol
		mov		[ebx].SHEET.spri.col,eax
		mov		eax,[esi].WIN.crow
		mov		[ebx].SHEET.spri.row,eax
		invoke GetCellData,ebx,esi,addr [ebx].SHEET.spri
		mov		eax,[ebx].SHEET.hwnd
		mov		spredt.hdr.hwndFrom,eax
		mov		eax,[ebx].SHEET.nid
		mov		spredt.hdr.idFrom,eax
		mov		spredt.hdr.code,SPRN_AFTERUPDATE
		lea		eax,[ebx].SHEET.spri
		mov		spredt.lpspri,eax
		mov		spredt.fcancel,FALSE
		invoke SendMessage,[ebx].SHEET.howner,WM_NOTIFY,[ebx].SHEET.nid,addr spredt
		invoke RecalcSheet,ebx
	.endif
	ret

CheckClick endp

ComboClick proc uses ebx esi,lpSheet:DWORD,lpWin:DWORD,lpCell:DWORD
	LOCAL	rect:RECT

	mov		ebx,lpSheet
	mov		esi,lpWin
	mov		eax,lpCell
	mov		lpCellData,eax
	mov		edx,dword ptr [eax].COLDTA.fmt.tpe[1]
	mov		eax,dword ptr [eax].COLDTA.fmt.tpe[1+4]
	mov		hCtrl,eax
	invoke SendMessage,hCtrl,LB_SETCURSEL,edx,0
	invoke SendMessage,hCtrl,LB_GETCOUNT,0,0
	push	eax
	invoke SendMessage,hCtrl,LB_GETITEMHEIGHT,eax,0
	pop		edx
	mul		edx
	add		eax,2
	push	eax
	invoke GetWindowLong,hCtrl,GWL_USERDATA
	mov		eax,[eax].COMBO.height
	push	eax
	invoke GetRealCellRect,ebx,esi,addr rect
	invoke ClientToScreen,[esi].WIN.hwin,addr rect.left
	invoke ClientToScreen,[esi].WIN.hwin,addr rect.right
	mov		edx,rect.right
	sub		edx,rect.left
	dec		edx
	pop		eax
	pop		ecx
	.if eax>ecx
		mov		eax,ecx
	.endif
	invoke SetWindowPos,hCtrl,HWND_TOP,rect.left,rect.bottom,edx,eax,SWP_SHOWWINDOW
	mov		eax,[esi].WIN.hwin
	mov		hCurrent,eax
	ret

ComboClick endp

EditCell proc uses ebx esi,lpSheet:DWORD,lpWin:DWORD,fCell:DWORD,nChrRect:DWORD
	LOCAL	rect:RECT
	LOCAL	buffer[512]:BYTE
	LOCAL	spredt:SPR_EDIT

	mov		ebx,lpSheet
	mov		esi,lpWin
	mov		eax,[ebx].SHEET.winst
	test	eax,SPS_CELLEDIT
	je		Ex
	invoke FindCell,ebx,[esi].WIN.ccol,[esi].WIN.crow
	.if eax
		movzx	edx,[eax].COLDTA.fmt.tpe
		mov		ecx,edx
		and		edx,TPE_TYPEMASK
		and		ecx,30h
		.if edx==TPE_CHECKBOX
			mov		edx,nChrRect
			.if edx==VK_SPACE || !edx;==VK_RETURN
				invoke CheckClick,ebx,esi,eax
				invoke InvalidateRect,[esi].WIN.hwin,NULL,TRUE
				invoke InvalidateRect,[ebx].SHEET.hwnd,NULL,TRUE
			.endif
			jmp		ExZero
		.elseif edx==TPE_COMBOBOX
			mov		edx,nChrRect
			.if edx==VK_SPACE || !edx;==VK_RETURN
				invoke ComboClick,ebx,esi,eax
			.endif
			jmp		ExZero
		.elseif ecx==TPE_BUTTON || ecx==TPE_WIDEBUTTON
			movzx	edx,[eax].COLDTA.state
			test	edx,STATE_LOCKED
			.if !ZERO?
				jmp		Ex
			.endif
		.endif
	.endif
	mov		eax,[esi].WIN.ccol
	mov		[ebx].SHEET.spri.col,eax
	mov		eax,[esi].WIN.crow
	mov		[ebx].SHEET.spri.row,eax
	invoke GetCellData,ebx,esi,addr [ebx].SHEET.spri
	movzx	eax,[ebx].SHEET.spri.state
	and		eax,STATE_LOCKED
	jne		ExZero
	mov		eax,[ebx].SHEET.hwnd
	mov		spredt.hdr.hwndFrom,eax
	mov		eax,[ebx].SHEET.nid
	mov		spredt.hdr.idFrom,eax
	mov		spredt.hdr.code,SPRN_BEFOREEDIT
	lea		eax,[ebx].SHEET.spri
	mov		spredt.lpspri,eax
	mov		spredt.fcancel,FALSE
	invoke SendMessage,[ebx].SHEET.howner,WM_NOTIFY,[ebx].SHEET.nid,addr spredt
	mov		eax,spredt.fcancel
	.if !eax
		.if fCell
			movzx	eax,[ebx].SHEET.spri.fmt.fnt
			.if al!=-1
				mov		edx,sizeof FONT
				mul		edx
				mov		eax,[ebx].SHEET.ofont.hfont[eax]
			.else
				mov		eax,[ebx].SHEET.ofont.hfont
			.endif
		.else
			mov		[ebx].SHEET.fedt,TRUE
			mov		eax,[ebx].SHEET.ofont.hfont
		.endif
		invoke SendMessage,[ebx].SHEET.hedt,WM_SETFONT,eax,FALSE
		.if fCell && nChrRect
			mov		eax,nChrRect
			test	[ebx].SHEET.spri.fmt.tpe,TPE_FORCETYPE
			.if ZERO?
				mov		[ebx].SHEET.spri.fmt.tpe,TPE_EMPTY
				.if eax=='"'
					mov		[ebx].SHEET.spri.fmt.tpe,TPE_TEXT
					xor		eax,eax
				.endif
			.endif
			mov		dword ptr buffer,eax
			lea		eax,buffer
		.else
			movzx	eax,[ebx].SHEET.spri.fmt.tpe
			mov		edx,eax
			and		edx,0F0h
			and		eax,TPE_TYPEMASK
			.if eax==TPE_INTEGER || eax==TPE_OWNERDRAWINTEGER
				.if edx==TPE_DATE
					mov		edx,[ebx].SHEET.spri.lpdta
					mov		edx,[edx]
					invoke DateToString,ebx,edx,addr buffer,sizeof buffer
				.else
					mov		edx,[ebx].SHEET.spri.lpdta
					mov		edx,[edx]
					invoke DwToAscii,edx,addr buffer
				.endif
				lea		eax,buffer
			.elseif eax==TPE_FLOAT
				mov		edx,[ebx].SHEET.spri.lpdta
				invoke FpToAscii,edx,addr buffer,FALSE
				lea		eax,buffer
			.elseif eax==TPE_FORMULA
				mov		edx,[ebx].SHEET.spri.lpdta
				add		edx,10
				invoke DecompFormula,edx,addr buffer
				lea		eax,buffer
			.elseif eax==TPE_GRAPH
				mov		edx,[ebx].SHEET.spri.lpdta
				add		edx,4
				invoke DecompFormula,edx,addr buffer
				lea		eax,buffer
			.elseif eax==TPE_TEXT || eax==TPE_TEXTMULTILINE || eax==TPE_HYPERLINK
				mov		eax,[ebx].SHEET.spri.lpdta
			.elseif eax==TPE_OWNERDRAWBLOB
				mov		eax,offset szNULL
			.else
				mov		eax,offset szNULL
			.endif
			test	[ebx].SHEET.spri.fmt.tpe,TPE_FORCETYPE
			.if ZERO?
				mov		[ebx].SHEET.spri.fmt.tpe,TPE_EMPTY
			.endif
		.endif
		push	eax
		invoke SendMessage,[ebx].SHEET.hedt,WM_SETTEXT,0,eax
		.if fCell
			invoke GetRealCellRect,ebx,esi,addr rect
			dec		rect.left
			dec		rect.top
			mov		edx,[esi].WIN.hwin
		.else
			invoke CopyRect,addr rect,nChrRect
			mov		edx,[ebx].SHEET.hwnd
		.endif
		mov		eax,rect.left
		sub		rect.right,eax
		mov		eax,rect.top
		sub		rect.bottom,eax
		invoke SetParent,[ebx].SHEET.hedt,edx
		invoke MoveWindow,[ebx].SHEET.hedt,rect.left,rect.top,rect.right,rect.bottom,TRUE
		invoke ShowWindow,[ebx].SHEET.hedt,SW_SHOW
		pop		eax
		invoke StrLen,eax
		invoke SendMessage,[ebx].SHEET.hedt,EM_SETSEL,eax,eax
		invoke SetFocus,[ebx].SHEET.hedt
	.endif
  ExZero:
	xor		eax,eax
  Ex:
	ret

EditCell endp

DeleteExpanded proc uses ebx edi,lpSheet:DWORD,lpCell:DWORD,lpRect:DWORD
	LOCAL	rect:RECT

	invoke CopyRect,addr rect,lpRect
	mov		ebx,lpSheet
	mov		edi,lpCell
	movzx	ecx,[edi].COLDTA.expx
	movzx	edx,[edi].COLDTA.expy
	.if ecx || edx
		;Delete expanded cells
		mov		eax,rect.left
		add		eax,ecx
		mov		rect.right,eax
		mov		eax,rect.top
		add		eax,edx
		mov		rect.bottom,eax
		mov		edx,rect.top
		.while edx<=rect.bottom
			mov		ecx,rect.left
			.while ecx<=rect.right
				.if ecx!=rect.left || edx!=rect.top
					push	ecx
					push	edx
					invoke DeleteCell,ebx,ecx,edx
					pop		edx
					pop		ecx
				.endif
				inc		ecx
			.endw
			inc		edx
		.endw
	.endif
	ret

DeleteExpanded endp

MakeExpanded proc uses ebx edi,lpSheet:DWORD,lpCell:DWORD,lpRect:DWORD
	LOCAL	rect:RECT

	invoke CopyRect,addr rect,lpRect
	mov		ebx,lpSheet
	mov		edi,lpCell
	mov		ecx,rect.right
	sub		ecx,rect.left
	mov		edx,rect.bottom
	sub		edx,rect.top
	mov		[edi].COLDTA.expx,cl
	mov		[edi].COLDTA.expy,dl
	.if ecx || edx
		;Create expanded cells
		mov		edx,rect.top
		.while edx<=rect.bottom
			mov		ecx,rect.left
			.while ecx<=rect.right
				.if ecx!=rect.left || edx!=rect.top
					push	ecx
					push	edx
					invoke MakeNewCell,ebx,ecx,edx
					mov		[eax].COLDTA.fmt.tpe,TPE_EXPANDED
					mov		[eax].COLDTA.state,STATE_LOCKED
					mov		edx,rect.top
					shl		edx,16
					or		edx,rect.left
					mov		[eax].COLDTA.fmt.txtcol,edx
					pop		edx
					pop		ecx
				.endif
				inc		ecx
			.endw
			inc		edx
		.endw
	.endif
	ret

MakeExpanded endp

UpdateExpanded proc uses ebx esi,lpSheet:DWORD,fDelete:DWORD
	LOCAL	rect:RECT

	mov		ebx,lpSheet
	xor		eax,eax
	inc		eax
	.while eax<=[ebx].SHEET.gfmt.nrows
		push	eax
		mov		esi,[ebx].SHEET.lprowmem
		lea		esi,[esi+eax*4]
		mov		esi,[esi]
		.if esi
			movzx	eax,[esi].ROWDTA.rown
			mov		rect.top,eax
			add		esi,sizeof ROWDTA-4
		  Nx2:
			movzx	eax,[esi].COLDTA.len
			.if eax
				movzx	eax,[esi].COLDTA.coln
				mov		rect.left,eax
				push	esi
				movzx	ecx,[esi].COLDTA.expx
				movzx	edx,[esi].COLDTA.expy
				.if ecx || edx
					add		ecx,rect.left
					mov		rect.right,ecx
					add		edx,rect.top
					mov		rect.bottom,edx
					.if fDelete
						invoke DeleteExpanded,ebx,esi,addr rect
					.else
						invoke MakeExpanded,ebx,esi,addr rect
					.endif
				.endif
				pop		esi
				movzx	eax,[esi].COLDTA.len
				add		esi,eax
				jmp		Nx2
			.endif
		.endif
		pop		eax
		inc		eax
	.endw
	ret

UpdateExpanded endp
