.data

Function		db TPE_SUMFUNCTION,		'Sum(',0
				db TPE_CNTFUNCTION,		'Cnt(',0
				db TPE_AVGFUNCTION,		'Avg(',0
				db TPE_MINFUNCTION,		'Min(',0
				db TPE_MAXFUNCTION,		'Max(',0
				db TPE_VARFUNCTION,		'Var(',0
				db TPE_STDFUNCTION,		'Std(',0
				db TPE_SQTFUNCTION,		'Sqt(',0
				db TPE_SINFUNCTION,		'Sin(',0
				db TPE_COSFUNCTION,		'Cos(',0
				db TPE_TANFUNCTION,		'Tan(',0
				db TPE_RADFUNCTION,		'Rad(',0
				db TPE_PIFUNCTION,		'PI()',0
				db TPE_IIFFUNCTION,		'IIf(',0
				db TPE_ONFUNCTION,		'On(',0
				db TPE_ABSFUNCTION,		'Abs(',0
				db TPE_SGNFUNCTION,		'Sgn(',0
				db TPE_INTFUNCTION,		'Int(',0
				db TPE_LOGFUNCTION,		'Log(',0
				db TPE_LNFUNCTION,		'Ln(',0
				db TPE_EFUNCTION,		'e()',0
				db TPE_ASINFUNCTION,	'Asin(',0
				db TPE_ACOSFUNCTION,	'Acos(',0
				db TPE_ATANFUNCTION,	'Atan(',0
				db TPE_GRDFUNCTION,		'Grd(',0
				db TPE_RGBFUNCTION,		'Rgb(',0
				db TPE_XFUNCTION,		'x()',0
				db TPE_CDATEFUNCTION,	'CDate(',0
				db TPE_GRPFUNCTION,		'Grp(',0
				db TPE_GRPTFUNCTION,	'T(',0
				db TPE_GRPXFUNCTION,	'X(',0
				db TPE_GRPYFUNCTION,	'Y(',0
				db TPE_GRPGXFUNCTION,	'gx(',0
				db TPE_GRPFXFUNCTION,	'fx(',0
				db 0

.code

IsMath proc uses eax,lpStr:DWORD

	mov		ecx,lpStr
	mov		dl,[ecx]
	.if dl=='+' || dl=='-' || dl=='*' || dl=='/' || dl=='^' || dl=='(' || dl==')' || dl==':' || dl==',' || dl==0
		add		ecx,1
		xor		dh,dh
	.else
		mov		dx,[ecx]
		.if dx=='><'
			add		ecx,2
			mov		dl,TPE_NOTEQU
			xor		dh,dh
		.elseif dx=='=>'
			add		ecx,2
			mov		dl,TPE_GTOREQU
			xor		dh,dh
		.elseif dx=='=<'
			add		ecx,2
			mov		dl,TPE_LEOREQU
			xor		dh,dh
		.elseif dl=='>'
			add		ecx,1
			mov		dl,TPE_GT
			xor		dh,dh
		.elseif dl=='='
			add		ecx,1
			mov		dl,TPE_EQU
			xor		dh,dh
		.elseif dl=='<'
			add		ecx,1
			mov		dl,TPE_LE
			xor		dh,dh
		.else
			mov		edx,[ecx]
			mov		al,[ecx+4]
			and		edx,5F5F5FFFh
			.if edx=='DNA ' && al==' '
				add		ecx,5
				mov		dl,TPE_AND
				xor		dh,dh
			.elseif edx=='ROX ' && al==' '
				add		ecx,5
				mov		dl,TPE_XOR
				xor		dh,dh
			.else
				mov		edx,[ecx]
				and		edx,0FF5F5FFFh
				.if edx==' RO '
					add		ecx,4
					mov		dl,TPE_OR
					xor		dh,dh
				.else
					xor		dh,dh
					inc		dh
				.endif
			.endif
		.endif
	.endif
	ret

IsMath endp

IsDate proc uses ebx esi edi,lpSheet:DWORD,lpStr:DWORD
	LOCAL	stime:SYSTEMTIME
	LOCAL	ftime:FILETIME
	LOCAL	buffer[32]:BYTE
	LOCAL	val1:DWORD
	LOCAL	val2:DWORD
	LOCAL	val3:DWORD
	LOCAL	sep[32]:BYTE

	mov		ebx,lpSheet
	lea		ecx,[ebx].SHEET.szDateFormat
	lea		edx,sep
	xor		eax,eax
	.while byte ptr [ecx]
		mov		al,[ecx]
		.if al!='d' && al!='M' && al!='y'
			mov		[edx],ax
			inc		edx
		.endif
		inc		ecx
	.endw
	mov		esi,lpStr
	mov		dl,[esi]
	.if dl>='0' && dl<='9'
		invoke lstrcpyn,addr buffer,lpStr,sizeof buffer
		lea		esi,buffer
		xor		ecx,ecx
		xor		edx,edx
		.while byte ptr [esi+ecx]
			mov		al,[esi+ecx]
			.if al<'0' || al>'9'
				.if al!=sep[edx]
					jmp		NotDate
				.endif
				inc		edx
				mov		byte ptr [esi+ecx],0
			.endif
			inc		ecx
		.endw
		.if edx==2
			invoke AsciiToDw,esi
			mov		val1,eax
			invoke StrLen,esi
			lea		esi,[esi+eax+1]
			invoke AsciiToDw,esi
			mov		val2,eax
			invoke StrLen,esi
			lea		esi,[esi+eax+1]
			invoke AsciiToDw,esi
			mov		val3,eax
		.else
			jmp		NotDate
		.endif
		lea		ecx,[ebx].SHEET.szDateFormat
		mov		edx,dword ptr [ecx]
		mov		eax,val1
		.if dx=='dd'
			mov		stime.wDay,ax
			add		ecx,3
		.elseif dx=='MM'
			mov		stime.wMonth,ax
			add		ecx,3
		.elseif edx=='yyyy'
			.if eax<30
				add		eax,2000
			.elseif eax<100
				add		eax,1900
			.endif
			mov		stime.wYear,ax
			add		ecx,5
		.elseif dx=='yy'
			.if eax<30
				add		eax,2000
			.elseif eax<100
				add		eax,1900
			.endif
			mov		stime.wYear,ax
			add		ecx,3
		.else
			jmp		NotDate
		.endif
		mov		edx,dword ptr [ecx]
		mov		eax,val2
		.if dx=='dd'
			mov		stime.wDay,ax
			add		ecx,3
		.elseif dx=='MM'
			mov		stime.wMonth,ax
			add		ecx,3
		.elseif edx=='yyyy'
			.if eax<30
				add		eax,2000
			.elseif eax<100
				add		eax,1900
			.endif
			mov		stime.wYear,ax
			add		ecx,5
		.elseif dx=='yy'
			.if eax<30
				add		eax,2000
			.elseif eax<100
				add		eax,1900
			.endif
			mov		stime.wYear,ax
			add		ecx,3
		.else
			jmp		NotDate
		.endif
		mov		edx,dword ptr [ecx]
		mov		eax,val3
		.if dx=='dd'
			mov		stime.wDay,ax
			add		ecx,3
		.elseif dx=='MM'
			mov		stime.wMonth,ax
			add		ecx,3
		.elseif edx=='yyyy'
			.if eax<30
				add		eax,2000
			.elseif eax<100
				add		eax,1900
			.endif
			mov		stime.wYear,ax
			add		ecx,5
		.elseif dx=='yy'
			.if eax<30
				add		eax,2000
			.elseif eax<100
				add		eax,1900
			.endif
			mov		stime.wYear,ax
			add		ecx,3
		.else
			jmp		NotDate
		.endif
		xor		eax,eax
		mov		stime.wDayOfWeek,ax
		mov		stime.wHour,ax
		mov		stime.wMinute,ax
		mov		stime.wSecond,ax
		mov		stime.wMilliseconds,ax
		invoke SystemTimeToFileTime,addr stime,addr ftime
		or		eax,eax
		je		NotDate
		;Convert to days since 01.01.1601
		mov		ecx,10*1000*1000
		mov		eax,ftime.dwHighDateTime
		xor		edx,edx
		div		ecx
		mov		ftime.dwHighDateTime,eax
		mov		eax,ftime.dwLowDateTime
		div		ecx
		mov		ftime.dwLowDateTime,eax
		mov		ecx,24*60*60
		mov		edx,ftime.dwHighDateTime
		mov		eax,ftime.dwLowDateTime
		div		ecx
		xor		dh,dh
		ret
	.endif
  NotDate:
	mov		ecx,lpStr
	mov		dl,[ecx]
	xor		dh,dh
	inc		dh
	ret

IsDate endp

IsInteger proc lpStr:DWORD

	mov		ecx,lpStr
	mov		dl,[ecx]
	.if dl=='-' || (dl>='0' && dl<='9')
		invoke AsciiToDw,ecx
		jc		NotInt
		push	ecx
		invoke IsMath,ecx
		pop		ecx
		jne		NotInt
		xor		dh,dh
		ret
	.endif
  NotInt:
	mov		ecx,lpStr
	mov		dl,[ecx]
	xor		dh,dh
	inc		dh
	ret

IsInteger endp

IsFloat proc lpStr:DWORD

	mov		ecx,lpStr
	mov		dl,[ecx]
	.if dl=='-' || (dl>='0' && dl<='9')
		invoke AsciiToFp,ecx,offset acmltr0
		jc		NotFloat
		mov		ecx,eax
		push	ecx
		invoke IsMath,ecx
		pop		ecx
		jne		NotFloat
		mov		eax,offset acmltr0
		xor		dh,dh
		ret
	.endif
  NotFloat:
	mov		ecx,lpStr
	mov		dl,[ecx]
	xor		dh,dh
	inc		dh
	ret

IsFloat endp

IsCellRef proc lpStr:DWORD

	mov		ecx,lpStr
	mov		dl,[ecx]
	.if (dl>='A' && dl<='Z') || (dl>='a' && dl<='z')
		mov		dl,[ecx+1]
		.if (dl>='A' && dl<='Z') || (dl>='a' && dl<='z')
			movzx	eax,byte ptr [ecx]
			and		al,5Fh
			sub		al,'A'
			mov		edx,26
			mul		edx
			movzx	edx,byte ptr [ecx+1]
			and		dl,5Fh
			sub		dl,'@'
			add		eax,edx
			push	eax
			add		ecx,2
			invoke IsInteger,ecx
			pop		edx
			jne		NotCellRef
			shl		eax,16
			add		eax,edx
			push	eax
			push	ecx
			invoke IsMath,ecx
			pop		ecx
			pop		eax
			jne		NotCellRef
			xor		dh,dh
			ret
		.endif
	.endif
	ret
  NotCellRef:
	mov		ecx,lpStr
	mov		dl,[ecx]
	xor		dh,dh
	inc		dh
	ret

IsCellRef endp

IsRelCellRef proc lpStr:DWORD
	LOCAL	val:DWORD

	mov		ecx,lpStr
	mov		dx,[ecx]
	.if dx=='(@'
		add		ecx,2
		invoke IsInteger,ecx
		jne		NotRelCellRef
		movzx	eax,ax
		mov		val,eax
		mov		dl,[ecx]
		cmp		dl,','
		jne		NotRelCellRef
		inc		ecx
		invoke IsInteger,ecx
		jne		NotRelCellRef
		mov		dl,[ecx]
		cmp		dl,')'
		jne		NotRelCellRef
		shl		eax,16
		add		eax,val
		inc		ecx
		xor		dh,dh
		ret
	.endif
	ret
  NotRelCellRef:
	mov		ecx,lpStr
	mov		dl,[ecx]
	xor		dh,dh
	inc		dh
	ret

IsRelCellRef endp

IsFunction proc uses edi,lpStr:DWORD

	mov		edi,offset Function
	mov		ecx,lpStr
	.while byte ptr [edi]
		xor		dh,dh
		mov		dl,[edi]
		inc		edi
	  @@:
		mov		al,[edi]
		.break .if !al
		call ConvChr
		mov		ah,al
		mov		al,[ecx]
		call ConvChr
		.if al==ah
			inc		edi
			inc		ecx
			jmp		@b
		.endif
	  @@:
		mov		dl,[edi]
		inc		edi
		or		dl,dl
		jne		@b
		dec		dh
		mov		ecx,lpStr
	.endw
	or		dh,dh
	ret

ConvChr:
	.if al>='a' && al<='z'
		and		al,5Fh
	.endif
	retn

IsFunction endp

CompileFormula proc lpStr:DWORD,lpOut:DWORD,nPara:DWORD
	LOCAL	espsave:DWORD

	mov		espsave,esp
	mov		esi,lpStr
	mov		edi,lpOut
  Nxt:
	call CompNum
	jne		String
  NxtM:
	invoke IsMath,esi
	jne		String
	mov		[edi],dl
	inc		edi
	or		dl,dl
	je		ExFormula
	mov		esi,ecx
	cmp		dl,','
	je		ExFormula
	cmp		dl,')'
	jne		Nxt
  @@:
	cmp		nPara,0
	je		ExFormula
	dec		nPara
	jmp		NxtM

  String:
	mov		eax,TPE_TEXT
  ExNum:
	mov		esp,espsave
	ret
  ExFormula:
	.if nPara
		jmp		String
	.endif
	mov		eax,TPE_FORMULA
	mov		esp,espsave
	ret

CompNum:
	mov		al,[esi]
	cmp		al,'('
	jne		@f
	mov		[edi],al
	inc		esi
	inc		edi
	inc		nPara
	jmp		CompNum
  @@:
	invoke IsInteger,esi
	jne		@f
	mov		esi,ecx
	mov		byte ptr [edi],TPE_INTEGER
	inc		edi
	mov		[edi],eax
	add		edi,4
	xor		eax,eax
	retn
  @@:
	invoke IsFloat,esi
	jne		@f
	mov		esi,ecx
	mov		byte ptr [edi],TPE_FLOAT
	inc		edi
	mov		eax,dword ptr [acmltr0]
	mov		[edi],eax
	mov		eax,dword ptr [acmltr0+4]
	mov		[edi+4],eax
	mov		ax,word ptr [acmltr0+8]
	mov		[edi+8],ax
	add		edi,10
	xor		eax,eax
	retn
  @@:
	invoke IsCellRef,esi
	jne		@f
	mov		esi,ecx
	mov		byte ptr [edi],TPE_CELLREF
	inc		edi
	mov		[edi],eax
	add		edi,4
	xor		eax,eax
	retn
  @@:
	invoke IsRelCellRef,esi
	jne		@f
	mov		esi,ecx
	mov		byte ptr [edi],TPE_RELCELLREF
	inc		edi
	mov		[edi],eax
	add		edi,4
	xor		eax,eax
	retn
  @@:
	invoke IsFunction,esi
	jne		Ex
	mov		esi,ecx
	mov		[edi],dl
	inc		edi
	.if dl>=TPE_SUMFUNCTION && dl<=TPE_STDFUNCTION
		invoke IsRelCellRef,esi
		mov		dl,TPE_RELCELLREF
		je		@f
		invoke IsCellRef,esi
		jne		String
		mov		dl,TPE_CELLREF
	  @@:
		mov		[edi],dl
		inc		edi
		mov		esi,ecx
		mov		[edi],eax
		add		edi,4
		mov		al,[esi]
		cmp		al,':'
		jne		String
		inc		esi
		invoke IsRelCellRef,esi
		mov		dl,TPE_RELCELLREF
		je		@f
		invoke IsCellRef,esi
		jne		String
		mov		dl,TPE_CELLREF
	  @@:
		mov		[edi],dl
		inc		edi
		mov		esi,ecx
		mov		dl,[esi]
		cmp		dl,')'
		jne		String
		inc		esi
;		mov		ecx,[edi-5]
;		.if eax<ecx
;			xchg	eax,ecx
;		.endif
;		.if ax<cx
;			xchg	ax,cx
;		.endif
;		mov		[edi-5],ecx
		mov		[edi],eax
		add		edi,4
		xor		eax,eax
		retn
	.elseif dl==TPE_PIFUNCTION || dl==TPE_EFUNCTION || dl==TPE_XFUNCTION; || dl==TPE_CDATEFUNCTION
		xor		eax,eax
		retn
	.else
		inc		nPara
		.if dl==TPE_IIFFUNCTION
			invoke CompileFormula,esi,edi,0
			cmp		eax,TPE_FORMULA
			jne		String
			cmp		dl,','
			jne		String
			invoke CompileFormula,esi,edi,0
			cmp		eax,TPE_FORMULA
			jne		String
			cmp		dl,','
			jne		String
			invoke CompileFormula,esi,edi,0
		.elseif dl==TPE_ONFUNCTION
			invoke CompileFormula,esi,edi,0
			cmp		eax,TPE_FORMULA
			jne		String
			cmp		dl,','
			jne		String
		  NxtOn:
			invoke CompileFormula,esi,edi,0
			cmp		eax,TPE_FORMULA
			jne		String
			cmp		dl,','
			je		NxtOn
		.elseif dl==TPE_RGBFUNCTION
			invoke CompileFormula,esi,edi,0
			cmp		eax,TPE_FORMULA
			jne		String
			cmp		dl,','
			jne		String
			invoke CompileFormula,esi,edi,0
			cmp		eax,TPE_FORMULA
			jne		String
			cmp		dl,','
			jne		String
			invoke CompileFormula,esi,edi,0
			cmp		eax,TPE_FORMULA
			jne		String
		.elseif dl==TPE_CDATEFUNCTION
			.if byte ptr [esi]=='"'
				inc		esi
				mov		byte ptr [edi],TPE_STRING
				inc		edi
				mov		edx,edi
				inc		edi
				.while byte ptr [esi] && byte ptr [esi]!='"'
					mov		al,[esi]
					mov		[edi],al
					inc		esi
					inc		edi
				.endw
				.if byte ptr [esi]!='"'
					jmp		String
				.endif
				inc		esi
				mov		byte ptr [edi],0
				inc		edi
				mov		eax,edi
				sub		eax,edx
				mov		[edx],al
				mov		dl,[esi]
				inc		esi
				mov		eax,TPE_FORMULA
			.else
				invoke CompileFormula,esi,edi,0
			.endif
		.else
			invoke CompileFormula,esi,edi,0
		.endif
		cmp		eax,TPE_FORMULA
		jne		String
		cmp		dl,')'
		jne		String
		dec		nPara
		xor		eax,eax
		retn
	.endif
  Ex:
	xor		eax,eax
	dec		eax
	retn

CompileFormula endp

CompileGraph proc lpStr:DWORD,lpOut:DWORD
	LOCAL	espsave:DWORD

	mov		espsave,esp
	mov		esi,lpStr
	mov		edi,lpOut
	invoke IsFunction,esi
	jne		NotGraph
	cmp		dl,TPE_GRPFUNCTION
	jne		NotGraph
	mov		[edi],dl
	inc		edi
	mov		esi,ecx
  @@:
	invoke IsFunction,esi
	jne		NotGraph
	cmp		dl,TPE_GRPTFUNCTION
	jne		@f
	call	StoreT
	jne		NotGraph
	mov		dl,[esi]
	cmp		dl,','
	jne		NotGraph
	mov		[edi],dl
	inc		edi
	inc		esi
	jmp		@b
  @@:
	invoke IsFunction,esi
	jne		NotGraph
	cmp		dl,TPE_GRPXFUNCTION
	jne		NotGraph
	call	StoreXY
	jne		NotGraph
	mov		dl,[esi]
	cmp		dl,','
	jne		NotGraph
	mov		[edi],dl
	inc		edi
	inc		esi

	invoke IsFunction,esi
	jne		NotGraph
	cmp		dl,TPE_GRPYFUNCTION
	jne		NotGraph
	call	StoreXY
	jne		NotGraph
	mov		dl,[esi]
	cmp		dl,','
	jne		NotGraph
	mov		[edi],dl
	inc		edi
	inc		esi

  CompileGraph1:
	invoke IsFunction,esi
	jne		NotGraph
	cmp		dl,TPE_GRPGXFUNCTION
	jne		@f
	call	StoreGX
	jne		NotGraph
	mov		dl,[esi]
	cmp		dl,','
	jne		CompileGraph2
	mov		[edi],dl
	inc		esi
	inc		edi
	jmp		CompileGraph1
  @@:
	cmp		dl,TPE_GRPFXFUNCTION
	jne		NotGraph
	call	StoreFX
	jne		NotGraph
	mov		dl,[esi]
	cmp		dl,','
	jne		CompileGraph2
	mov		[edi],dl
	inc		esi
	inc		edi
	jmp		CompileGraph1
  CompileGraph2:
	mov		dl,[esi]
	cmp		dl,')'
	jne		NotGraph
	mov		[edi],dl
	inc		edi
	mov		byte ptr [edi],0
	inc		edi
	inc		esi
	mov		esp,espsave
	mov		eax,TPE_GRAPH
	ret
  NotGraph:
	mov		esp,espsave
	xor		eax,eax
	dec		eax
	ret

StoreT:
	mov		[edi],dl
	inc		edi
	mov		esi,ecx
	call	StoreNum		;X
	jne		NotT
	call	StoreNum		;Y
	jne		NotT
	call	StoreNum		;Rotate
	jne		NotT
	call	StoreNum		;Color
	jne		NotT
	call	StoreString		;Text
	jne		NotT
	cmp		dl,')'
	jne		NotT
	xor		eax,eax
	retn
  NotT:
	xor		eax,eax
	dec		eax
	retn

StoreXY:
	mov		[edi],dl
	inc		edi
	mov		esi,ecx
	call	StoreNum		;X-Min
	jne		NotXY
	call	StoreNum		;X-Max
	jne		NotXY
	call	StoreNum		;X-Origo
	jne		NotXY
	call	StoreNum		;X-Tick
	jne		NotXY
	call	StoreNum		;X-Color
	jne		NotXY
	.if byte ptr [esi]!='"'
		call	StoreNum		;X-TickVal
		jne		NotXY
	.endif
	call	StoreString		;X-Caption
	jne		NotXY
	cmp		dl,')'
	jne		NotXY
	xor		eax,eax
	retn
  NotXY:
	xor		eax,eax
	dec		eax
	retn

StoreGX:
	mov		[edi],dl
	inc		edi
	mov		esi,ecx
	mov		byte ptr [edi],TPE_AREAREF
	inc		edi
	invoke IsCellRef,esi
	jne		NotGX
	mov		byte ptr [edi],TPE_CELLREF
	inc		edi
	mov		[edi],eax
	add		edi,4
	mov		esi,ecx
	mov		dl,[esi]
	cmp		dl,':'
	jne		NotGX
	inc		esi
	invoke IsCellRef,esi
	jne		NotGX
	mov		byte ptr [edi],TPE_CELLREF
	inc		edi
	mov		[edi],eax
	add		edi,4
	mov		esi,ecx
	mov		dl,[esi]
	cmp		dl,','
	jne		NotGX
	mov		[edi],dl
	inc		esi
	inc		edi
	call	StoreNum		;Color
	jne		NotGX
	call	StoreString		;Caption
	jne		NotGX
	cmp		dl,')'
	jne		NotGX
	xor		eax,eax
	retn
  NotGX:
	xor		eax,eax
	dec		eax
	retn

StoreFX:
	mov		[edi],dl
	inc		edi
	mov		esi,ecx
	call	StoreNum		;Function
	jne		NotFX
	call	StoreNum		;Step
	jne		NotFX
	call	StoreNum		;Color
	jne		NotFX
	call	StoreString		;Caption
	jne		NotFX
	cmp		dl,')'
	jne		NotFX
	xor		eax,eax
	retn
  NotFX:
	xor		eax,eax
	dec		eax
	retn

StoreNum:
	invoke CompileFormula,esi,edi,0
	cmp		eax,TPE_FORMULA
	jne		NotNum
	cmp		dl,','
	jne		NotNum
	xor		eax,eax
	retn
  NotNum:
	xor		eax,eax
	dec		eax
	retn

StoreString:
	mov		byte ptr [edi],TPE_STRING
	inc		edi
	mov		edx,edi
	inc		edi
	mov		al,[esi]
	cmp		al,'"'
	jne		NotString
	inc		esi
  @@:
	mov		al,[esi]
	or		al,al
	je		NotString
	inc		esi
	cmp		al,'"'
	je		@f
	mov		[edi],al
	inc		edi
	jmp		@b
  @@:
	mov		byte ptr [edi],0
	inc		edi
	mov		eax,edi
	sub		eax,edx
	mov		[edx],al
	mov		dl,[esi]
	cmp		dl,','
	je		@f
	cmp		dl,')'
	jne		NotString
  @@:
	mov		[edi],dl
	inc		esi
	inc		edi
	xor		eax,eax
	retn
  NotString:
	xor		eax,eax
	dec		eax
	retn

CompileGraph endp

Compile Proc uses esi edi,lpSheet:DWORD,lpStr:DWORD,lpOut:DWORD

	mov		esi,lpStr
	mov		edi,lpOut
	mov		eax,TPE_EMPTY
	mov		dl,[esi]
	or		dl,dl
	je		Ex
	invoke IsDate,lpSheet,esi
	jne		@f
	mov		[edi],eax
	mov		eax,TPE_INTEGER or TPE_DATE
	jmp		Ex
  @@:
	invoke IsInteger,esi
	jne		@f
	or		dl,dl
	jne		@f
	mov		[edi],eax
	mov		eax,TPE_INTEGER
	jmp		Ex
  @@:
	invoke IsFloat,esi
	jne		@f
	or		dl,dl
	jne		@f
	mov		eax,dword ptr [acmltr0]
	mov		[edi],eax
	mov		eax,dword ptr [acmltr0+4]
	mov		[edi+4],eax
	mov		ax,word ptr [acmltr0+8]
	mov		[edi+8],ax
	mov		eax,TPE_FLOAT
	jmp		Ex
  @@:
	mov		esi,lpStr
	mov		edi,lpOut
	xor		eax,eax
	mov		[edi],eax
	add		edi,4
	invoke CompileGraph,esi,edi
	cmp		eax,TPE_GRAPH
	je		Ex
	mov		esi,lpStr
	mov		edi,lpOut
	xor		eax,eax
	mov		[edi],eax
	mov		[edi+4],eax
	mov		[edi+8],ax
	add		edi,10
	invoke CompileFormula,esi,edi,0
	.if eax==TPE_TEXT || dl
		invoke StrCpy,lpOut,lpStr
		mov		eax,TPE_TEXT
	.endif
  Ex:
	ret

Compile endp
