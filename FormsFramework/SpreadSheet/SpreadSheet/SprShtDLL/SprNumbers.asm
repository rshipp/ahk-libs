.const

FP_LESSTHAN	equ	01h
FP_EQUALTO	equ	40h

ten16		dq	1.0e16

ten			dq	10.0

ten_1		dt	1.0e1
			dt	1.0e2
			dt	1.0e3
			dt	1.0e4
			dt	1.0e5
			dt	1.0e6
			dt	1.0e7
			dt	1.0e8
			dt	1.0e9
			dt	1.0e10
			dt	1.0e11
			dt	1.0e12
			dt	1.0e13
			dt	1.0e14
			dt	1.0e15
ten_16		dt	1.0e16
			dt	1.0e32
			dt	1.0e48
			dt	1.0e64
			dt	1.0e80
			dt	1.0e96
			dt	1.0e112
			dt	1.0e128
			dt	1.0e144
			dt	1.0e160
			dt	1.0e176
			dt	1.0e192
			dt	1.0e208
			dt	1.0e224
			dt	1.0e240
ten_256		dt	1.0e256
			dt	1.0e512
			dt	1.0e768
			dt	1.0e1024
			dt	1.0e1280
			dt	1.0e1536
			dt	1.0e1792
			dt	1.0e2048
			dt	1.0e2304
			dt	1.0e2560
			dt	1.0e2816
			dt	1.0e3072
			dt	1.0e3328
			dt	1.0e3584
			dt	1.0e4096
			dt	1.0e4352
			dt	1.0e4608
			dt	1.0e4864

.code

hexEax proc

	pushad
	mov     edi,offset strHex+7
	call    hexNibble
	call    hexNibble
	call    hexNibble
	call    hexNibble
	call    hexNibble
	call    hexNibble
	call    hexNibble
	call    hexNibble
	popad
	ret

  hexNibble:
	push    eax
	and     eax,0fh
	cmp     eax,0ah
	jb      hexNibble1
	add     eax,07h
  hexNibble1:
	add     eax,30h
	mov     [edi],al
	dec     edi
	pop     eax
	shr     eax,4
	ret
	
hexEax endp

AsciiToDw proc lpAscii:DWORD
	LOCAL	fNeg:DWORD

    mov     ecx,lpAscii
    xor     eax,eax
    xor		edx,edx
    mov		fNeg,eax
	cmp		byte ptr [ecx],'-'
	jne		@1
	inc		ecx
	inc		fNeg
	jmp		@1
  @@:
	cmp		eax,214748365
	jnb		Err
	lea		eax,[eax*4+eax]
    inc     ecx
	lea		eax,[eax*2+edx]
  @1:
	mov		dl,[ecx]
	xor		dl,'0'
	cmp		dl,10
	jb		@b
	mov		dl,[ecx]
	dec		fNeg
	je		@f
	or		eax,eax
	js		Err
	ret
  @@:
	dec		eax
	js		Err
	inc		eax
	neg		eax
	clc
	ret
  Err:
	xor		eax,eax
	dec		eax
	stc
	ret

AsciiToDw endp

DwToAscii proc uses ebx esi edi,dwVal:DWORD,lpAscii:DWORD

	mov		eax,dwVal
	mov		edi,lpAscii
	or		eax,eax
	jns		pos
	mov		byte ptr [edi],'-'
	neg		eax
	inc		edi
  pos:      
	mov		ecx,429496730
	mov		esi,edi
  @@:
	mov		ebx,eax
	mul		ecx
	mov		eax,edx
	lea		edx,[edx*4+edx]
	add		edx,edx
	sub		ebx,edx
	add		bl,'0'
	mov		[edi],bl
	inc		edi
	or		eax,eax
	jne		@b
	mov		byte ptr [edi],al
	.while esi<edi
		dec		edi
		mov		al,[esi]
		mov		ah,[edi]
		mov		[edi],al
		mov		[esi],ah
		inc		esi
	.endw
	ret

DwToAscii endp

AsciiToFp proc uses ebx esi edi,lpAscii:DWORD,lpAcmltr:DWORD
	LOCAL	tmp:DWORD

	mov		esi,lpAscii
	xor		ebx,ebx
	; First, see if we have a sign at the front end.
	movzx	eax,byte ptr [esi]
	.if eax=='+'
		inc		esi
		movzx	eax,byte ptr [esi]
	.elseif eax=='-'
		inc		esi
		inc		ebx
		movzx	eax,byte ptr [esi]
	.endif
	fldz
	xor		edi,edi
	xor		edx,edx
	xor		ecx,ecx
	; OK, now start our main loop.
	;   esi => character in string now in al
	;   al = next character to be converted
	;   edx = number of digits encountered thus far
	;   ecx = exponent
	;   ST(0) = accumulator
cvtloop:
	cmp		eax,'E'
	je		doExponent
	cmp		eax,'e'
	je		doExponent
	cmp		eax,'.'
	je		doDecimal
	xor		eax,'0'
	cmp		eax,10
	jnb		sdFinish			; if not a digit
	inc		esi
	fmul	ten					; d *= 10
	mov		tmp,eax
	add		edx,edi				; increment digit counter
	movzx	eax,byte ptr [esi]
	fiadd	dword ptr tmp		; d += new digit
	jmp		cvtloop
doDecimal:
	inc		esi
	mov		edi,1
	movzx	eax,byte ptr [esi]
	jmp		cvtloop

	; We have the mantissa at the top of the stack.  Now convert the exponent.
	; Fortunately, this is an integer.
	;   esi = pointer to character in al
	;   al = next character to convert
	;   ebx = digit counter
	;   ecx = accumulated exponent
	;   ST(0) = mantissa
doExponent:
	inc		esi
	movzx	eax,byte ptr [esi]
	; Does the exponent have a sign?
	.if	eax=='+'
		inc		esi
		movzx	eax,byte ptr [esi]
	.elseif eax=='-'
		inc		esi
		inc		bh
		movzx	eax,byte ptr [esi]
	.endif
	xor		eax,'0'
	cmp		eax,10
	jnb		sdFinish
expLoop:
	lea		ecx,[ecx*4+ecx]
	inc		esi
	lea		ecx,[ecx*2+eax]
	movzx	eax,byte ptr [esi]
	xor		eax,'0'
	cmp		eax,10
	jb		expLoop
	; Adjust the exponent to account for decimal places.  At this juncture, 
	; we work with the absolute value of the exponent.  That means we need
	; to subtract the adjustment if the exponent will be negative, add if
	; the exponent will be positive.
	;  ST(0) = mantissa
	;  ecx = unadjusted exponent
	;  ebx = total number of digits
sdFinish:
	or		bh,bh;test	ebx,100h
	je		@f
	;exp sign
	neg		ecx
  @@:
	;decimal position
	sub		ecx,edx	; adjust exponent
	mov		edi,lpAcmltr
	je		@f
	;  ecx = exponent
	; Multiply a floating point value by an integral power of 10.
	; Entry: EAX = power of 10, -4932..4932.
	;	ST(0) = value to be multiplied
	; Exit:	ST(0) = value x 10^eax
	mov		eax,ecx
	.if	(SDWORD PTR ecx < 0)
		neg		ecx
	.endif
	fld1
	mov		edx,ecx
	and		edx,0Fh
	.if	(!ZERO?)
		lea		edx,[edx+edx*4]
		fld		ten_1[edx*2][-10]
		fmulp	st(1),st
	.endif
	mov		edx,ecx
	shr		edx,4
	and		edx,0Fh
	.if (!ZERO?)
		lea		edx,[edx+edx*4]
		fld		ten_16[edx*2][-10]
		fmulp	st(1),st
	.endif
	mov		dl,ch
	and		edx,1Fh
	.if (!ZERO?)
		lea		edx,[edx+edx*4]
		fld		ten_256[edx*2][-10]
		fmulp	st(1),st
	.endif
	.if (SDWORD PTR eax < 0)
		fdivp	st(1),st
	.else
		fmulp	st(1),st
	.endif
  @@:
	; Negate the whole thing, if necessary.
	or		bl,bl;test	ebx,1
	je		@f
	fchs
  @@:
	; That's it!  Store it and go home.
	mov		eax,esi	; return pt to next unread char
	fstp	tbyte ptr [edi]	; store the reslt
	fwait
	ret

AsciiToFp endp

FpToAscii proc USES esi edi,lpFpin:PTR TBYTE,lpStr:PTR CHAR,fSci:DWORD
	LOCAL	iExp:DWORD
	LOCAL	stat:WORD
	LOCAL	mystat:WORD
	LOCAL	sztemp[32]:BYTE
	LOCAL	temp:TBYTE

	mov		esi,lpFpin
	mov		edi,lpStr
	.if	dword ptr [esi]== 0 && dword ptr [esi+4]==0
		; Special case zero.  fxtract fails for zero.
		mov		word ptr [edi], '0'
		ret
	.endif
	; Check for a negative number.
	push	[esi+6]
	.if	sdword ptr [esi+6]<0
		and		byte ptr [esi+9],07fh	; change to positive
		mov		byte ptr [edi],'-'		; store a minus sign
		inc		edi
	.endif
	fld		TBYTE ptr [esi]
	fld		st(0)
	; Compute the closest power of 10 below the number.  We can't get an
	; exact value because of rounding.  We could get close by adding in
	; log10(mantissa), but it still wouldn't be exact.  Since we'll have to
	; check the result anyway, it's silly to waste cycles worrying about
	; the mantissa.
	;
	; The exponent is basically log2(lpfpin).  Those of you who remember
	; algebra realize that log2(lpfpin) x log10(2) = log10(lpfpin), which is
	; what we want.
	fxtract					; ST=> mantissa, exponent, [lpfpin]
	fstp	st(0)			; drop the mantissa
	fldlg2					; push log10(2)
	fmulp	st(1),st		; ST = log10([lpfpin]), [lpfpin]
	fistp 	iExp			; ST = [lpfpin]
	; A 10-byte double can carry 19.5 digits, but fbstp only stores 18.
	.IF	iExp<18
		fld		st(0)		; ST = lpfpin, lpfpin
		frndint				; ST = int(lpfpin), lpfpin
		fcomp	st(1)		; ST = lpfpin, status set
		fstsw	ax
		.IF ah&FP_EQUALTO && !fSci	; if EQUAL
			; We have an integer!  Lucky day.  Go convert it into a temp buffer.
			call FloatToBCD
			mov		eax,17
			mov		ecx,iExp
			sub		eax,ecx
			inc		ecx
			lea		esi,[sztemp+eax]
			; The off-by-one order of magnitude problem below can hit us here.  
			; We just trim off the possible leading zero.
			.IF byte ptr [esi]=='0'
				inc esi
				dec ecx
			.ENDIF
			; Copy the rest of the converted BCD value to our buffer.
			rep movsb
			jmp ftsExit
		.ENDIF
	.ENDIF
	; Have fbstp round to 17 places.
	mov		eax, 17			; experiment
	sub		eax,iExp		; adjust exponent to 17
	call PowerOf10
	; Either we have exactly 17 digits, or we have exactly 16 digits.  We can
	; detect that condition and adjust now.
	fcom	ten16
	; x0xxxx00 means top of stack > ten16
	; x0xxxx01 means top of stack < ten16
	; x1xxxx00 means top of stack = ten16
	fstsw	ax
	.IF ah & 1
		fmul	ten
		dec		iExp
	.ENDIF
	; Go convert to BCD.
	call FloatToBCD
	lea		esi,sztemp		; point to converted buffer
	; If the exponent is between -15 and 16, we should express this as a number
	; without scientific notation.
	mov ecx, iExp
	.IF SDWORD PTR ecx>=-15 && SDWORD PTR ecx<=16 && !fSci
		; If the exponent is less than zero, we insert '0.', then -ecx
		; leading zeros, then 16 digits of mantissa.  If the exponent is
		; positive, we copy ecx+1 digits, then a decimal point (maybe), then 
		; the remaining 16-ecx digits.
		inc ecx
		.IF SDWORD PTR ecx<=0
			mov		word ptr [edi],'.0'
			add		edi, 2
			neg		ecx
			mov		al,'0'
			rep		stosb
			mov		ecx,18
		.ELSE
			.if byte ptr [esi]=='0' && ecx>1
				inc		esi
				dec		ecx
			.endif
			rep		movsb
			mov		byte ptr [edi],'.'
			inc		edi
			mov		ecx,17
			sub		ecx,iExp
		.ENDIF
		rep movsb
		; Trim off trailing zeros.
		.WHILE byte ptr [edi-1]=='0'
			dec		edi
		.ENDW
		; If we cleared out all the decimal digits, kill the decimal point, too.
		.IF byte ptr [edi-1]=='.'
			dec		edi
		.ENDIF
		; That's it.
		jmp		ftsExit
	.ENDIF
	; Now convert this to a standard, usable format.  If needed, a minus
	; sign is already present in the outgoing buffer, and edi already points
	; past it.
	mov		ecx,17
	.if byte ptr [esi]=='0'
		inc		esi
		dec		iExp
		dec		ecx
	.endif
	movsb						; copy the first digit
	mov		byte ptr [edi],'.'	; plop in a decimal point
	inc		edi
	rep movsb
	; The printf %g specified trims off trailing zeros here.  I dislike
	; this, so I've disabled it.  Comment out the if 0 and endif if you
	; want this.
	.WHILE byte ptr [edi-1]=='0'
		dec		edi
	.ENDW
	.if byte ptr [edi-1]=='.'
		dec		edi
	.endif
	; Shove in the exponent.
	mov		byte ptr [edi],'e'	; start the exponent
	mov		eax,iExp
	.IF sdword ptr eax<0		; plop in the exponent sign
		mov		byte ptr [edi+1],'-'
		neg		eax
	.ELSE
		mov		byte ptr [edi+1],'+'
	.ENDIF
	mov		ecx, 10
	xor		edx,edx
	div		ecx
	add		dl,'0'
	mov		[edi+5],dl		; shove in the ones exponent digit
	xor		edx,edx
	div		ecx
	add		dl,'0'
	mov		[edi+4],dl		; shove in the tens exponent digit
	xor		edx,edx
	div		ecx
	add		dl,'0'
	mov		[edi+3],dl		; shove in the hundreds exponent digit
	xor		edx,edx
	div		ecx
	add		dl,'0'
	mov		[edi+2],dl		; shove in the thousands exponent digit
	add		edi,6			; point to terminator
ftsExit:
	; Clean up and go home.
	mov		esi,lpFpin
	pop		[esi+6]
	mov		byte ptr [edi],0
	fwait
	ret

; Convert a floating point register to ASCII.
; The result always has exactly 18 digits, with zero padding on the
; left if required.
;
; Entry:	ST(0) = a number to convert, 0 <= ST(0) < 1E19.
;			sztemp = an 18-character buffer.
;
; Exit:		sztemp = the converted result.
FloatToBCD:
	push	esi
	push	edi
    fbstp	temp
	; Now we need to unpack the BCD to ASCII.
    lea		esi,[temp]
    lea		edi,[sztemp]
    mov		ecx,8
    .REPEAT
		movzx	ax,byte ptr [esi+ecx]	; 0000 0000 AAAA BBBB
		rol		ax,12					; BBBB 0000 0000 AAAA
		shr		ah,4					; 0000 BBBB 0000 AAAA
		add		ax,3030h				; 3B3A
		stosw
		dec		ecx
    .UNTIL SIGN?
	pop		edi
	pop		esi
    retn

PowerOf10:
    mov		ecx,eax
    .IF	SDWORD PTR eax<0
		neg		eax
    .ENDIF
    fld1
    mov		dl,al
    and		edx,0fh
    .IF	!ZERO?
		lea		edx,[edx+edx*4]
		fld		ten_1[edx*2][-10]
		fmulp	st(1),st
    .ENDIF
    mov		dl,al
    shr		dl,4
    and		edx,0fh
    .IF !ZERO?
		lea		edx,[edx+edx*4]
		fld		ten_16[edx*2][-10]
		fmulp	st(1),st
    .ENDIF
    mov		dl,ah
    and		edx,1fh
    .IF !ZERO?
		lea		edx,[edx+edx*4]
		fld		ten_256[edx*2][-10]
		fmulp	st(1),st
    .ENDIF
    .IF SDWORD PTR ecx<0
		fdivp	st(1),st
    .ELSE
		fmulp	st(1),st
    .ENDIF
    retn

FpToAscii endp

