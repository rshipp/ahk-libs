.const

PlusOne		dq 1.0

.code

DateToString proc uses ebx,lpSheet:DWORD,nDate:DWORD,lpBuff:DWORD,nSizeBuff:DWORD
	LOCAL	stime:SYSTEMTIME
	LOCAL	ftime:FILETIME

	mov		ebx,lpSheet
	;Days since 01.01.1601
	mov		eax,nDate
	;Convert to number of 100 nano seconds since 01.01.1601
	mov		ecx,24*60*60
	mul		ecx
	push	edx
	mov		ecx,1000*1000*10
	mul		ecx
	mov		ftime.dwLowDateTime,eax
	pop		eax
	push	edx
	mul		ecx
	pop		edx
	add		eax,edx
	mov		ftime.dwHighDateTime,eax
	invoke FileTimeToSystemTime,addr ftime,addr stime
	invoke GetDateFormat,NULL,NULL,addr stime,addr [ebx].SHEET.szDateFormat,lpBuff,nSizeBuff
	ret

DateToString endp

AddFun proc

	fld		tbyte ptr [ecx]
	fld		tbyte ptr [edx]
	faddp	st(1),st(0)
	fstp	tbyte ptr [edx]
	ret

AddFun endp

SubFun proc

	fld		tbyte ptr [ecx]
	fld		tbyte ptr [edx]
	fsubp	st(1),st(0)
	fstp	tbyte ptr [edx]
	ret

SubFun endp

MulFun proc

	fld		tbyte ptr [ecx]
	fld		tbyte ptr [edx]
	fmulp	st(1),st(0)
	fstp	tbyte ptr [edx]
	ret

MulFun endp

DivFun proc

	fld		tbyte ptr [ecx]
	fld		tbyte ptr [edx]
	fdivp	st(1),st(0)
	fstp	tbyte ptr [edx]
	ret

DivFun endp

ExpFun proc
	fld		tbyte ptr [edx]
	fld		tbyte ptr [ecx]
	fyl2x
	sub		esp,16
	fist	dword ptr [esp+12]
	fld1
	fstp	tbyte ptr [esp]
	fisub	dword ptr [esp+12]
	mov		eax,[esp+12]
	add		[esp+8],eax
	f2xm1
	fld1
	fadd 
	fld		tbyte ptr [esp]
	fmul
	add		esp,16
	fstp	tbyte ptr [edx]
	ret

ExpFun endp

SumFun proc uses esi,lpRef:DWORD,lpAcm:DWORD
	LOCAL	nMinCol:DWORD
	LOCAL	nMinRow:DWORD
	LOCAL	nMaxCol:DWORD
	LOCAL	nMaxRow:DWORD
	LOCAL	nCol:DWORD
	LOCAL	nRow:DWORD
	LOCAL	nCount:DWORD

	mov		esi,lpRef
	mov		edx,lpAcm
	xor		eax,eax
	mov		[edx],eax
	mov		[edx+4],eax
	mov		[edx+8],ax
	movsx	eax,word ptr [esi+1]
	.if byte ptr [esi]==TPE_RELCELLREF
		add		eax,nCalcCol
	.endif
	mov		nMinCol,eax
	movsx	eax,word ptr [esi+6]
	.if byte ptr [esi+5]==TPE_RELCELLREF
		add		eax,nCalcCol
	.endif
	.if eax<nMinCol
		xchg	eax,nMinCol
	.endif
	mov		nMaxCol,eax
	movsx	eax,word ptr [esi+3]
	.if byte ptr [esi]==TPE_RELCELLREF
		add		eax,nCalcRow
	.endif
	mov		nMinRow,eax
	movsx	eax,word ptr [esi+8]
	.if byte ptr [esi+5]==TPE_RELCELLREF
		add		eax,nCalcRow
	.endif
	.if eax<nMinRow
		xchg	eax,nMinRow
	.endif
	mov		nMaxRow,eax
	mov		nCount,0
	mov		eax,nMinRow
	mov		nRow,eax
  NxRow:
	mov		eax,nMinCol
	mov		nCol,eax
  NxCol:
	invoke FindCell,ebx,nCol,nRow
	.if eax
		mov		esi,eax
		mov		al,[esi].COLDTA.fmt.tpe
		.if al==TPE_FLOAT
			lea		ecx,[esi].COLDTA.fmt.tpe[1]
			mov		edx,lpAcm
			fld		tbyte ptr [ecx]
			fld		tbyte ptr [edx]
			faddp	st(1),st(0)
			fstp	tbyte ptr [edx]
			inc		nCount
		.elseif al==TPE_INTEGER || al==TPE_CHECKBOX || al==TPE_COMBOBOX
			lea		ecx,[esi].COLDTA.fmt.tpe[1]
			mov		edx,lpAcm
			fild	dword ptr [ecx]
			fld		tbyte ptr [edx]
			faddp	st(1),st(0)
			fstp	tbyte ptr [edx]
			inc		nCount
		.elseif al==TPE_FORMULA
			mov		al,[esi].COLDTA.state
			and		al,STATE_ERRMASK
			.if !al
				lea		ecx,[esi].COLDTA.fmt.tpe[1]
				mov		edx,lpAcm
				fld		tbyte ptr [ecx]
				fld		tbyte ptr [edx]
				faddp	st(1),st(0)
				fstp	tbyte ptr [edx]
				inc		nCount
			.else
				jmp		RefEx
			.endif
		.endif
	.endif
	inc		nCol
	mov		eax,nMaxCol
	cmp		eax,nCol
	jnb		NxCol
	inc		nRow
	mov		eax,nMaxRow
	cmp		eax,nRow
	jnb		NxRow
	mov		eax,nCount
	ret
  RefEx:
	xor		eax,eax
	dec		eax
	ret

SumFun endp

MinMaxFun proc uses esi,lpRef:DWORD,lpAcm:DWORD,fMax:DWORD
	LOCAL	nMinCol:DWORD
	LOCAL	nMinRow:DWORD
	LOCAL	nMaxCol:DWORD
	LOCAL	nMaxRow:DWORD
	LOCAL	nCol:DWORD
	LOCAL	nRow:DWORD
	LOCAL	nCount:DWORD

	mov		esi,lpRef
	mov		edx,lpAcm
	xor		eax,eax
	dec		eax
	mov		[edx],eax
	mov		[edx+4],eax
	.if !fMax
		and		ax,7FFFh
	.endif
	dec		ax
	mov		[edx+8],ax
	movsx	eax,word ptr [esi+1]
	.if byte ptr [esi]==TPE_RELCELLREF
		add		eax,nCalcCol
	.endif
	mov		nMinCol,eax
	movsx	eax,word ptr [esi+6]
	.if byte ptr [esi+5]==TPE_RELCELLREF
		add		eax,nCalcCol
	.endif
	.if eax<nMinCol
		xchg	eax,nMinCol
	.endif
	mov		nMaxCol,eax
	movsx	eax,word ptr [esi+3]
	.if byte ptr [esi]==TPE_RELCELLREF
		add		eax,nCalcRow
	.endif
	mov		nMinRow,eax
	movsx	eax,word ptr [esi+8]
	.if byte ptr [esi+5]==TPE_RELCELLREF
		add		eax,nCalcRow
	.endif
	.if eax<nMinRow
		xchg	eax,nMinRow
	.endif
	mov		nMaxRow,eax
	mov		nCount,0
	mov		eax,nMinRow
	mov		nRow,eax
  NxRow:
	mov		eax,nMinCol
	mov		nCol,eax
  NxCol:
	invoke FindCell,ebx,nCol,nRow
	.if eax
		mov		esi,eax
		mov		al,[esi].COLDTA.fmt.tpe
		.if al==TPE_FLOAT
			lea		ecx,[esi].COLDTA.fmt.tpe[1]
			mov		edx,lpAcm
			fld		tbyte ptr [ecx]
			fld		tbyte ptr [edx]
			fcompp
			fstsw	ax
			and		ah,45h
			.if fMax
				.if ah==1
					mov		eax,[ecx]
					mov		[edx],eax
					mov		eax,[ecx+4]
					mov		[edx+4],eax
					mov		ax,[ecx+8]
					mov		[edx+8],ax
				.endif
			.else
				.if !ah
					mov		eax,[ecx]
					mov		[edx],eax
					mov		eax,[ecx+4]
					mov		[edx+4],eax
					mov		ax,[ecx+8]
					mov		[edx+8],ax
				.endif
			.endif
			inc		nCount
		.elseif al==TPE_INTEGER || al==TPE_CHECKBOX || al==TPE_COMBOBOX
			lea		ecx,[esi].COLDTA.fmt.tpe[1]
			mov		edx,lpAcm
			fild	dword ptr [ecx]
			fld		tbyte ptr [edx]
			fcompp
			fstsw	ax
			and		ah,45h
			.if fMax
				.if ah==1
					fild	dword ptr [ecx]
					fstp	tbyte ptr [edx]
				.endif
			.else
				.if !ah
					fild	dword ptr [ecx]
					fstp	tbyte ptr [edx]
				.endif
			.endif
			inc		nCount
		.elseif al==TPE_FORMULA
			mov		al,[esi].COLDTA.state
			and		al,STATE_ERRMASK
			.if !al
				lea		ecx,[esi].COLDTA.fmt.tpe[1]
				mov		edx,lpAcm
				fld		tbyte ptr [ecx]
				fld		tbyte ptr [edx]
				fcompp
				fstsw	ax
				and		ah,45h
				.if fMax
					.if ah==1
						mov		eax,[ecx]
						mov		[edx],eax
						mov		eax,[ecx+4]
						mov		[edx+4],eax
						mov		ax,[ecx+8]
						mov		[edx+8],ax
					.endif
				.else
					.if !ah
						mov		eax,[ecx]
						mov		[edx],eax
						mov		eax,[ecx+4]
						mov		[edx+4],eax
						mov		ax,[ecx+8]
						mov		[edx+8],ax
					.endif
				.endif
				inc		nCount
			.else
				jmp		RefEx
			.endif
		.endif
	.endif
	inc		nCol
	mov		eax,nMaxCol
	cmp		eax,nCol
	jnb		NxCol
	inc		nRow
	mov		eax,nMaxRow
	cmp		eax,nRow
	jnb		NxRow
	mov		eax,nCount
	ret
  RefEx:
	xor		eax,eax
	dec		eax
	ret

MinMaxFun endp

;Variance s^2=Sum((Xn-M)^2)/(n-1)
VarFun proc uses esi,lpRef:DWORD,lpAcm:DWORD
	LOCAL	nMinCol:DWORD
	LOCAL	nMinRow:DWORD
	LOCAL	nMaxCol:DWORD
	LOCAL	nMaxRow:DWORD
	LOCAL	nCol:DWORD
	LOCAL	nRow:DWORD
	LOCAL	mid:TBYTE
	LOCAL	var:TBYTE
	LOCAL	nCount:DWORD

	mov		esi,lpRef
	invoke SumFun,esi,addr mid
	mov		nCount,eax
	inc		eax
	je		RefEx
	dec		eax
	je		ErrEx
	dec		eax
	je		ErrEx
	fld		mid
	fild	nCount
	fdivp	st(1),st(0)
	fstp	mid
	xor		eax,eax
	mov		dword ptr var,eax
	mov		dword ptr var+4,eax
	mov		word ptr var+8,ax

	movsx	eax,word ptr [esi+1]
	.if byte ptr [esi]==TPE_RELCELLREF
		add		eax,nCalcCol
	.endif
	mov		nMinCol,eax
	movsx	eax,word ptr [esi+6]
	.if byte ptr [esi+5]==TPE_RELCELLREF
		add		eax,nCalcCol
	.endif
	.if eax<nMinCol
		xchg	eax,nMinCol
	.endif
	mov		nMaxCol,eax
	movsx	eax,word ptr [esi+3]
	.if byte ptr [esi]==TPE_RELCELLREF
		add		eax,nCalcRow
	.endif
	mov		nMinRow,eax
	movsx	eax,word ptr [esi+8]
	.if byte ptr [esi+5]==TPE_RELCELLREF
		add		eax,nCalcRow
	.endif
	.if eax<nMinRow
		xchg	eax,nMinRow
	.endif
	mov		nMaxRow,eax
	mov		eax,nMinRow
	mov		nRow,eax
  NxRow:
	mov		eax,nMinCol
	mov		nCol,eax
  NxCol:
	invoke FindCell,ebx,nCol,nRow
	.if eax
		mov		esi,eax
		mov		al,[esi].COLDTA.fmt.tpe
		.if al==TPE_FLOAT
			lea		ecx,[esi].COLDTA.fmt.tpe[1]
			fld		tbyte ptr [ecx]
			fld		mid
			fsubp	st(1),st(0)
			fmul	st(0),st(0)
			fld		var
			faddp	st(1),st(0)
			fstp	var
		.elseif al==TPE_INTEGER || al==TPE_CHECKBOX || al==TPE_COMBOBOX
			lea		ecx,[esi].COLDTA.fmt.tpe[1]
			fild	dword ptr [ecx]
			fld		mid
			fsubp	st(1),st(0)
			fmul	st(0),st(0)
			fld		var
			faddp	st(1),st(0)
			fstp	var
		.elseif al==TPE_FORMULA
			mov		al,[esi].COLDTA.state
			and		al,STATE_ERRMASK
			.if !al
				lea		ecx,[esi].COLDTA.fmt.tpe[1]
				fld		tbyte ptr [ecx]
				fld		mid
				fsubp	st(1),st(0)
				fmul	st(0),st(0)
				fld		var
				faddp	st(1),st(0)
				fstp	var
			.else
				jmp		RefEx
			.endif
		.endif
	.endif
	inc		nCol
	mov		eax,nMaxCol
	cmp		eax,nCol
	jnb		NxCol
	inc		nRow
	mov		eax,nMaxRow
	cmp		eax,nRow
	jnb		NxRow
	dec		nCount
	fld		var
	fild	nCount
	fdivp	st(1),st(0)
	mov		edx,lpAcm
	fstp	tbyte ptr [edx]
	mov		eax,nCount
	inc		eax
	ret
  RefEx:
	xor		eax,eax
	dec		eax
	ret
  ErrEx:
	xor		eax,eax
	ret

VarFun endp

CmpFun proc

	fld		tbyte ptr [ecx]
	fld		tbyte ptr [edx]
	fcompp
	fstsw	ax
	and		ah,45h
	ret

CmpFun endp

CalculateCell proc uses ebx,lpSheet:DWORD,nFun:DWORD,lpAcm:DWORD
	LOCAL	espSave:DWORD
	LOCAL	acm:TBYTE
	LOCAL	dummyacm:TBYTE
	LOCAL	dwval:DWORD

	mov		ebx,lpSheet
	mov		espSave,esp
  Nx:
	movzx	eax,byte ptr [esi]
	.if al=='(' || al==')' || al==',' || al=='+' || al=='-' || al=='*' || al=='/' || al=='^' || (al>=TPE_NOTEQU && al<=TPE_LE) || (al>=TPE_AND && al<=TPE_XOR) || !al
		.if al!='('
			mov	edx,eax
			mov		eax,nFun
			.if al=='^'
				call DoMath
				mov		nFun,0
				jmp		Ex
			.elseif al=='*' || al=='/'
				.if dl!='^'
					call DoMath
					mov		nFun,0
					jmp		Ex
				.endif
			.elseif al=='+' || al=='-'
				.if dl!='^' && dl!='*' && dl!='/'
					call DoMath
					mov		nFun,0
					jmp		Ex
				.endif
			.elseif al>=TPE_NOTEQU && al<=TPE_LE
				.if (dl>=TPE_NOTEQU && dl<=TPE_LE) || (dl>=TPE_AND && dl<=TPE_XOR) || dl==')' || dl==',' || !dl
					call DoMath
					mov		nFun,0
					jmp		Ex
				.endif
			.elseif al>=TPE_AND && al<=TPE_XOR
				.if (dl>=TPE_AND && dl<=TPE_XOR) || dl==')' || dl==',' || !dl
					call DoMath
					mov		nFun,0
					jmp		Ex
				.endif
			.elseif al=='('
				.if dl==')'
					inc		esi
					mov		nFun,0
					jmp		Ex
				.endif
			.elseif !al && (dl==')' || dl==',')
				jmp		Ex
			.elseif !dl
				.if eax
					call DoMath
				.endif
				mov		nFun,0
				jmp		Ex
			.endif
		.endif
		movzx	edx,byte ptr [esi]
		.if edx; && edx!=','
			inc		esi
			invoke CalculateCell,ebx,edx,addr acm
			jmp		Nx
		.endif
		jmp Ex
	.else
		call GetNum
		jmp		Nx
	.endif

Ex:
	.if nFun
		jmp		ErrEx
	.endif
	mov		edx,lpAcm
	mov		eax,dword ptr acm
	mov		dword ptr [edx],eax
	mov		eax,dword ptr acm+4
	mov		dword ptr [edx+4],eax
	mov		ax,word ptr acm+8
	mov		word ptr [edx+8],ax
	mov		esp,espSave
	xor		eax,eax
	ret
ExErr:
	mov		esp,espSave
	ret
RefEx:
	mov		esp,espSave
	xor		eax,eax
	inc		eax
	ret
ErrEx:
	mov		esp,espSave
	xor		eax,eax
	dec		eax
	ret
DivEx:
	mov		esp,espSave
	mov		eax,STATE_DIV0
	ret
OvfEx:
	mov		esp,espSave
	mov		eax,STATE_OVERFLOW
	ret
UvfEx:
	mov		esp,espSave
	mov		eax,STATE_UNDERFLOW
	ret

DoMath:
	mov		ecx,lpAcm
	lea		edx,acm
	.if al=='+'
		call AddFun
	.elseif al=='-'
		call SubFun
	.elseif al=='*'
		call MulFun
	.elseif al=='/'
		mov		al,[edx+9]
		or		al,al
		je		DivEx
		call DivFun
	.elseif al=='^'
		call ExpFun
	.elseif al==TPE_LE
		call CmpFun
		.if !ah
			call StoreOne
		.else
			call StoreNull
		.endif
	.elseif al==TPE_LEOREQU
		call CmpFun
		.if !ah || ah==40h
			call StoreOne
		.else
			call StoreNull
		.endif
	.elseif al==TPE_EQU
		call CmpFun
		.if ah==40h
			call StoreOne
		.else
			call StoreNull
		.endif
	.elseif al==TPE_GTOREQU
		call CmpFun
		.if ah==1 || ah==40h
			call StoreOne
		.else
			call StoreNull
		.endif
	.elseif al==TPE_GT
		call CmpFun
		.if ah==1
			call StoreOne
		.else
			call StoreNull
		.endif
	.elseif al==TPE_NOTEQU
		call CmpFun
		.if ah!=40h
			call StoreOne
		.else
			call StoreNull
		.endif
	.elseif al==TPE_AND
		.if dword ptr [ecx+6] && dword ptr [edx+6]
			call StoreOne
		.else
			call StoreNull
		.endif
	.elseif al==TPE_OR
		.if dword ptr [ecx+6] || dword ptr [edx+6]
			call StoreOne
		.else
			call StoreNull
		.endif
	.elseif al==TPE_XOR
		.if dword ptr [ecx+6] || dword ptr [edx+6]
			.if dword ptr [ecx+6] && dword ptr [edx+6]
				call StoreNull
			.else
				call StoreOne
			.endif
		.else
			call StoreNull
		.endif
	.elseif al && al!='(' && al!=')' && al!=','
		jmp		ErrEx
	.endif
	fstsw	ax
	test	al,08h
	jne		OvfEx
	test	al,10h
	jne		UvfEx
	retn

StoreNull:
	xor		eax,eax
	mov		[edx],eax
	mov		[edx+4],eax
	mov		[edx+8],ax
	retn

StoreOne:
	xor		eax,eax
	mov		[edx],eax
	mov		[edx+4],ax
	mov		eax,3FFF8000h
	mov		[edx+6],eax
	retn

GetNum:
	movzx	eax,byte ptr [esi]
	cmp		al,TPE_CELLREF
	jne		GetNum0
	mov		eax,[esi+1]
	add		esi,5
	mov		edx,eax
	shr		edx,16
	and		eax,0FFFFh
	invoke FindCell,ebx,eax,edx
	.if eax
		mov		dl,[eax].COLDTA.fmt.tpe
		and		dl,TPE_TYPEMASK
		cmp		dl,TPE_FLOAT
		je		Flt
		cmp		dl,TPE_FORMULA
		je		Form
		cmp		dl,TPE_INTEGER
		jz		Intgr
		cmp		dl,TPE_CHECKBOX
		jz		Intgr
		cmp		dl,TPE_COMBOBOX
		jne		Ldz
	  Intgr:
		fild	dword ptr [eax+sizeof COLDTA]
		fstp	acm
		retn
	  Form:
		mov		dl,[eax].COLDTA.state
		and		dl,STATE_ERRMASK
		jne		RefEx
	  Flt:
		lea		edx,[eax+sizeof COLDTA]
		mov		eax,[edx]
		mov		dword ptr acm,eax
		mov		eax,[edx+4]
		mov		dword ptr acm+4,eax
		mov		ax,[edx+8]
		mov		word ptr acm+8,ax
		retn
	.endif
  Ldz:
	xor		eax,eax
	mov		dword ptr acm,eax
	mov		dword ptr acm+4,eax
	mov		word ptr acm+8,ax
	retn
GetNum0:
	cmp		al,TPE_RELCELLREF
	jne		GetNum1
	mov		edx,[esi+1]
	add		esi,5
	movsx	eax,dx
	shr		edx,16
	movsx	edx,dx
	add		eax,nCalcCol
	add		edx,nCalcRow
	invoke FindCell,ebx,eax,edx
	.if eax
		mov		dl,[eax].COLDTA.fmt.tpe
		and		dl,TPE_TYPEMASK
		cmp		dl,TPE_FLOAT
		je		Flt
		cmp		dl,TPE_FORMULA
		je		Form
		cmp		dl,TPE_INTEGER
		je		Intgr
		cmp		dl,TPE_CHECKBOX
		jz		Intgr
		cmp		dl,TPE_COMBOBOX
		jz		Intgr
	.endif
	jmp		Ldz
GetNum1:
	cmp		al,TPE_INTEGER
	jne		GetNum2
	fild	dword ptr [esi+1]
	fstp	acm
	add		esi,5
	retn
GetNum2:
	cmp		al,TPE_FLOAT
	jne		GetNum3
	mov		eax,[esi+1]
	mov		dword ptr acm,eax
	mov		eax,[esi+5]
	mov		dword ptr acm+4,eax
	mov		ax,[esi+9]
	mov		word ptr acm+8,ax
	add		esi,11
	retn
GetNum3:
	cmp		al,TPE_SUMFUNCTION
	jne		GetNum4
	inc		esi
	invoke SumFun,esi,addr acm
	add		esi,10
	inc		eax
	je		RefEx
	retn
GetNum4:
	cmp		al,TPE_CNTFUNCTION
	jne		GetNum5
	inc		esi
	invoke SumFun,esi,addr acm
	add		esi,10
	inc		eax
	je		RefEx
	dec		eax
	mov		dwval,eax
	fild	dwval
	fstp	acm
	retn
GetNum5:
	cmp		al,TPE_AVGFUNCTION
	jne		GetNum6
	inc		esi
	invoke SumFun,esi,addr acm
	add		esi,10
	inc		eax
	je		RefEx
	dec		eax
	je		ErrEx
	mov		dwval,eax
	fld		acm
	fild	dwval
	fdivp	st(1),st(0)
	fstp	acm
	retn
GetNum6:
	cmp		al,TPE_MINFUNCTION
	jne		GetNum7
	inc		esi
	invoke MinMaxFun,esi,addr acm,FALSE
	add		esi,10
	inc		eax
	je		RefEx
	dec		eax
	je		ErrEx
	retn
GetNum7:
	cmp		al,TPE_MAXFUNCTION
	jne		GetNum8
	inc		esi
	invoke MinMaxFun,esi,addr acm,TRUE
	add		esi,10
	inc		eax
	je		RefEx
	dec		eax
	je		ErrEx
	retn
GetNum8:
	cmp		al,TPE_VARFUNCTION
	jne		GetNum9
	inc		esi
	invoke VarFun,esi,addr acm
	add		esi,10
	inc		eax
	je		RefEx
	dec		eax
	je		ErrEx
	retn
GetNum9:
	cmp		al,TPE_STDFUNCTION
	jne		GetNum10
	inc		esi
	invoke VarFun,esi,addr acm
	add		esi,10
	inc		eax
	je		RefEx
	dec		eax
	je		ErrEx
	fld		acm
	fsqrt
	fstp	acm
	retn
GetNum10:
	cmp		al,TPE_SQTFUNCTION
	jne		GetNum11
	inc		esi
	invoke CalculateCell,ebx,0,addr acm
	or		eax,eax
	jne		ExErr
	mov		al,[esi]
	cmp		al,')'
	jne		ExErr
	inc		esi
	fld		acm
	fsqrt
	fstp	acm
	retn
GetNum11:
	cmp		al,TPE_SINFUNCTION
	jne		GetNum12
	inc		esi
	invoke CalculateCell,ebx,0,addr acm
	or		eax,eax
	jne		ExErr
	mov		al,[esi]
	cmp		al,')'
	jne		ExErr
	inc		esi
	fld		acm
	fsin
	fstp	acm
	retn
GetNum12:
	cmp		al,TPE_COSFUNCTION
	jne		GetNum13
	inc		esi
	invoke CalculateCell,ebx,0,addr acm
	or		eax,eax
	jne		ExErr
	mov		al,[esi]
	cmp		al,')'
	jne		ExErr
	inc		esi
	fld		acm
	fcos
	fstp	acm
	retn
GetNum13:
	cmp		al,TPE_TANFUNCTION
	jne		GetNum14
	inc		esi
	invoke CalculateCell,ebx,0,addr acm
	or		eax,eax
	jne		ExErr
	mov		al,[esi]
	cmp		al,')'
	jne		ExErr
	inc		esi
	fld		acm
	fptan
	fstp	st
	fstp	acm
	retn
GetNum14:
	cmp		al,TPE_RADFUNCTION
	jne		GetNum15
	inc		esi
	invoke CalculateCell,ebx,0,addr acm
	or		eax,eax
	jne		ExErr
	mov		al,[esi]
	cmp		al,')'
	jne		ExErr
	inc		esi
	fld		acm
	fldpi
	fmulp	st(1),st(0)
	mov		dwval,360/2
	fild	dwval
	fdivp	st(1),st(0)
	fstp	acm
	retn
GetNum15:
	cmp		al,TPE_PIFUNCTION
	jne		GetNum16
	inc		esi
	fldpi
	fstp	acm
	retn
GetNum16:
	cmp		al,TPE_IIFFUNCTION
	jne		GetNum17
	inc		esi
	invoke CalculateCell,ebx,0,addr acm
	or		eax,eax
	jne		ExErr
	mov		al,[esi]
	cmp		al,','
	jne		ExErr
	inc		esi
	.if dword ptr [acm+6]
		invoke CalculateCell,ebx,0,addr acm
		or		eax,eax
		jne		ExErr
		mov		al,[esi]
		cmp		al,','
		jne		ExErr
		inc		esi
		invoke CalculateCell,ebx,0,addr dummyacm
		or		eax,eax
		jne		ExErr
		mov		al,[esi]
		cmp		al,')'
		jne		ExErr
		inc		esi
	.else
		invoke CalculateCell,ebx,0,addr dummyacm
		or		eax,eax
		jne		ExErr
		mov		al,[esi]
		cmp		al,','
		jne		ExErr
		inc		esi
		invoke CalculateCell,ebx,0,addr acm
		or		eax,eax
		jne		ExErr
		mov		al,[esi]
		cmp		al,')'
		jne		ExErr
		inc		esi
	.endif
	retn
GetNum17:
	cmp		al,TPE_ONFUNCTION
	jne		GetNum18
	inc		esi
	invoke CalculateCell,ebx,0,addr acm
	or		eax,eax
	jne		ExErr
	mov		al,[esi]
	cmp		al,','
	jne		ExErr
	inc		esi
	lea		ecx,dummyacm
	lea		edx,acm
	xor		eax,eax
	mov		[ecx],eax
	mov		[ecx+4],eax
	mov		[ecx+8],ax
	call CmpFun
	.if !ah
		mov		dword ptr [ecx+6],4005C800h
		call CmpFun
		.if !ah
			xor		eax,eax
			mov		[edx],eax
			mov		[ecx+4],ax
			mov		dword ptr [ecx+6],4005C800h
		.endif
	.else
		call StoreNull
	.endif
	fld		acm
	fistp	dwval
	inc		dwval
	.while dwval
		invoke CalculateCell,ebx,0,addr acm
		or		eax,eax
		jne		ExErr
		mov		al,[esi]
		inc		esi
		.break .if al!=','
		dec		dwval
	.endw
	.while al!=')'
		invoke CalculateCell,ebx,0,addr dummyacm
		or		eax,eax
		jne		ExErr
		mov		al,[esi]
		inc		esi
		.break .if al!=','
	.endw
	cmp		al,')'
	jne		ExErr
	retn
GetNum18:
	cmp		al,TPE_ABSFUNCTION
	jne		GetNum19
	inc		esi
	invoke CalculateCell,ebx,0,addr acm
	or		eax,eax
	jne		ExErr
	mov		al,[esi]
	cmp		al,')'
	jne		ExErr
	inc		esi
	and		byte ptr acm+9,7Fh
	retn
GetNum19:
	cmp		al,TPE_SGNFUNCTION
	jne		GetNum20
	inc		esi
	invoke CalculateCell,ebx,0,addr acm
	or		eax,eax
	jne		ExErr
	mov		al,[esi]
	cmp		al,')'
	jne		ExErr
	inc		esi
	mov		al,byte ptr acm+9
	.if al
		push	eax
		call StoreOne
		pop		eax
		.if al>=80h
			or		byte ptr acm+9,80h
		.endif
	.else
		call StoreNull
	.endif
	retn
GetNum20:
	cmp		al,TPE_INTFUNCTION
	jne		GetNum21
	inc		esi
	invoke CalculateCell,ebx,0,addr acm
	or		eax,eax
	jne		ExErr
	mov		al,[esi]
	cmp		al,')'
	jne		ExErr
	inc		esi
	fclex
	fld		acm
	fistp	dwval
	fstsw	ax
	test	al,01h
	jne		OvfEx
	fild	dwval
	fstp	acm
	retn
GetNum21:
	cmp		al,TPE_LOGFUNCTION
	jne		GetNum22
	inc		esi
	invoke CalculateCell,ebx,0,addr acm
	or		eax,eax
	jne		ExErr
	mov		al,[esi]
	cmp		al,')'
	jne		ExErr
	inc		esi
	fld		flpten
	fld		acm
	fld1
	fxch
	fyl2x
	fxch
	fld1
	fxch
	fyl2x
	fdiv
	fstp	acm
	retn
GetNum22:
	cmp		al,TPE_LNFUNCTION
	jne		GetNum23
	inc		esi
	invoke CalculateCell,ebx,0,addr acm
	or		eax,eax
	jne		ExErr
	mov		al,[esi]
	cmp		al,')'
	jne		ExErr
	inc		esi
	fld		acm
	fld		iL2e
	fxch
	fyl2x
	fstp	acm
	retn
GetNum23:
	cmp		al,TPE_EFUNCTION
	jne		GetNum24
	inc		esi
	mov		eax,dword ptr flpe
	mov		dword ptr acm,eax
	mov		eax,dword ptr flpe+4
	mov		dword ptr acm+4,eax
	mov		ax,word ptr flpe+8
	mov		word ptr acm+8,ax
	retn
GetNum24:
	cmp		al,TPE_ASINFUNCTION
	jne		GetNum25
	inc		esi
	invoke CalculateCell,ebx,0,addr acm
	or		eax,eax
	jne		ExErr
	mov		al,[esi]
	cmp		al,')'
	jne		ExErr
	inc		esi
	fld		acm
	fld		st
	fmul	st,st
	fsubr	PlusOne
	fsqrt
	fpatan
	fstp	acm
	retn
GetNum25:
	cmp		al,TPE_ACOSFUNCTION
	jne		GetNum26
	inc		esi
	invoke CalculateCell,ebx,0,addr acm
	or		eax,eax
	jne		ExErr
	mov		al,[esi]
	cmp		al,')'
	jne		ExErr
	inc		esi
	fld		acm
	fld		st
	fmul	st,st
	fsubr	PlusOne
	fsqrt
	fxch
	fpatan
	fstp	acm
	retn
GetNum26:
	cmp		al,TPE_ATANFUNCTION
	jne		GetNum27
	inc		esi
	invoke CalculateCell,ebx,0,addr acm
	or		eax,eax
	jne		ExErr
	mov		al,[esi]
	cmp		al,')'
	jne		ExErr
	inc		esi
	fld		acm
	fld		PlusOne
	fpatan
	fstp	acm
	retn
GetNum27:
	cmp		al,TPE_GRDFUNCTION
	jne		GetNum28
	inc		esi
	invoke CalculateCell,ebx,0,addr acm
	or		eax,eax
	jne		ExErr
	mov		al,[esi]
	cmp		al,')'
	jne		ExErr
	inc		esi
	fld		acm
	fldpi
	fdivp	st(1),st(0)
	mov		dwval,180
	fild	dwval
	fmulp	st(1),st(0)
	fstp	acm
	retn
GetNum28:
	cmp		al,TPE_RGBFUNCTION
	jne		GetNum29
	inc		esi
	invoke CalculateCell,ebx,0,addr acm
	or		eax,eax
	jne		ExErr
	mov		al,[esi]
	cmp		al,','
	jne		ExErr
	inc		esi
	fld		acm
	fistp	dwval
	cmp		dwval,255
	jg		OvfEx
	invoke CalculateCell,ebx,0,addr acm
	or		eax,eax
	jne		ExErr
	mov		al,[esi]
	cmp		al,','
	jne		ExErr
	inc		esi
	mov		eax,dwval
	fld		acm
	fistp	dwval
	cmp		dwval,255
	jg		OvfEx
	shl		dwval,8
	add		dwval,eax
	invoke CalculateCell,ebx,0,addr acm
	or		eax,eax
	jne		ExErr
	mov		al,[esi]
	cmp		al,')'
	jne		ExErr
	inc		esi
	mov		eax,dwval
	fld		acm
	fistp	dwval
	cmp		dwval,255
	jg		OvfEx
	shl		dwval,16
	add		dwval,eax
	fild	dwval
	fstp	acm
	retn
GetNum29:
	cmp		al,TPE_XFUNCTION
	jne		GetNum30
	inc		esi
	fld		funx
	fstp	acm
	retn
GetNum30:
	cmp		al,TPE_CDATEFUNCTION
	jne		GetNum31
	inc		esi
	mov		al,[esi]
	.if al==TPE_STRING
		inc		esi
		mov		eax,esi
		inc		eax
		invoke IsDate,ebx,eax
		.if !dh
			mov		dwval,eax
			movzx	eax,byte ptr [esi]
			add		esi,eax
			fild	dwval
			fstp	acm
		.else
			jmp		ErrEx
		.endif
	.elseif al==TPE_CELLREF
		mov		eax,[esi+1]
		add		esi,5
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		invoke FindCell,ebx,eax,edx
		.if eax
			mov		dl,[eax].COLDTA.fmt.tpe
			and		dl,TPE_TYPEMASK
			.if dl==TPE_TEXT
				lea		eax,[eax].COLDTA.fmt.tpe[1]
				invoke IsDate,ebx,eax
				.if !dh
					mov		dwval,eax
					fild	dwval
					fstp	acm
				.else
					jmp		ErrEx
				.endif
			.else
				jmp		ErrEx
			.endif
		.else
			jmp		RefEx
		.endif
	.else
		jmp		ErrEx
	.endif
	retn
GetNum31:
	.if al && al!='(' && al!=')' && al!=','
		jmp		ErrEx
	.endif
	retn

CalculateCell endp


RecalcSheet proc uses ebx esi edi,lpSheet:DWORD
	LOCAL	nLastCalcCells:DWORD

	mov		nCalcCells,0
	mov		ebx,lpSheet
	xor		eax,eax
	.while eax<=[ebx].SHEET.gfmt.nrows
		push	eax
		mov		esi,[ebx].SHEET.lprowmem
		lea		esi,[esi+eax*4]
		mov		esi,[esi]
		.if esi
			add		esi,sizeof ROWDTA-4
		  Nx2:
			movzx	eax,[esi].COLDTA.len
			.if eax
				push	esi
				mov		al,[esi].COLDTA.fmt.tpe
				.if al==TPE_FORMULA
					and		[esi].COLDTA.state,03h
					or		[esi].COLDTA.state,80h
					inc		nCalcCells
				.elseif al==TPE_GRAPH
					invoke DeleteObject,dword ptr [esi].COLDTA.fmt.tpe[1]
					mov		dword ptr [esi].COLDTA.fmt.tpe[1],0
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

  Recalc:
	mov		eax,nCalcCells
	or		eax,eax
	je		Ex
	mov		nLastCalcCells,eax
	xor		eax,eax
	.while eax<=[ebx].SHEET.gfmt.nrows
		push	eax
		mov		esi,[ebx].SHEET.lprowmem
		lea		esi,[esi+eax*4]
		mov		esi,[esi]
		.if esi
			movzx	eax,[esi].ROWDTA.rown
			mov		nCalcRow,eax
			add		esi,sizeof ROWDTA-4
		  Nxt2:
			movzx	eax,[esi].COLDTA.len
			.if eax
				movzx	eax,[esi].COLDTA.coln
				mov		nCalcCol,eax
				push	esi
				mov		al,[esi].COLDTA.fmt.tpe
				mov		ah,[esi].COLDTA.state
				and		ah,STATE_RECALC
				.if al==TPE_FORMULA && ah
					push	esi
					lea		esi,[esi+sizeof COLDTA+10]
					invoke CalculateCell,ebx,0,offset acmltr0
					pop		esi
					.if !eax
						dec		nCalcCells
						and		[esi].COLDTA.state,03h
						lea		esi,[esi+sizeof COLDTA]
						mov		eax,dword ptr acmltr0
						mov		[esi],eax
						mov		eax,dword ptr acmltr0+4
						mov		[esi+4],eax
						mov		ax,word ptr acmltr0+8
						mov		[esi+8],ax
					.elseif eax==-1
						and		[esi].COLDTA.state,03h
						or		[esi].COLDTA.state,STATE_ERROR
					.elseif eax==STATE_DIV0 || eax==STATE_OVERFLOW || eax==STATE_UNDERFLOW
						fclex
						and		[esi].COLDTA.state,03h
						or		[esi].COLDTA.state,al
					.endif
				.endif
				pop		esi
				movzx	eax,[esi].COLDTA.len
				add		esi,eax
				mov		eax,nCalcCells
				or		eax,eax
				jne		Nxt2
			.endif
		.endif
		pop		eax
		inc		eax
		.break .if !nCalcCells
	.endw
	mov		eax,nCalcCells
	cmp		eax,nLastCalcCells
	jne		Recalc
  Ex:
	ret

RecalcSheet endp

;--------------------------------------------------------------------------------

