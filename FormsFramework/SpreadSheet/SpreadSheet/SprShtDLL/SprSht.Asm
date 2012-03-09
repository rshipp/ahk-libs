.386
.model flat,stdcall
option casemap:none
option proc:private

include SprSht.inc
include \RadASM\Masm\Inc\RADbg.inc
include SprMisc.asm
include SprNumbers.asm
include SprMath.asm
include SprCompile.asm
include SprCell.asm
include SprDraw.asm
include SprWin.asm

.code

SprShtInstall proc public hInst:DWORD
	LOCAL	wc:WNDCLASSEX

    push    hInst
    pop     hInstance
	;Create a windowclass for the user control
	mov		wc.cbSize,sizeof WNDCLASSEX
IFDEF DLL
	mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_GLOBALCLASS or CS_PARENTDC or CS_DBLCLKS
ELSE
	mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_PARENTDC or CS_DBLCLKS
ENDIF
	mov		wc.lpfnWndProc,offset SheetProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,4		;Holds memory handle
	push	hInstance
	pop		wc.hInstance
	mov		wc.hbrBackground,NULL
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset szClassNameSheet
	mov		eax,NULL
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		hCurArrow,eax
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	invoke LoadCursor,NULL,IDC_SIZEALL
	mov		hCurSize,eax

	;Create a windowclass for the child wibdows
	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_PARENTDC or CS_DBLCLKS
	mov		wc.lpfnWndProc,offset WinProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,NULL
	push	hInstance
	pop		wc.hInstance
	mov		wc.hbrBackground,NULL
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset szClassNameSheetWin
	mov		eax,NULL
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	invoke LoadCursor,hInstance,IDR_HSPLIT
	mov		hCurHSplit,eax
	invoke LoadCursor,hInstance,IDR_VSPLIT
	mov		hCurVSplit,eax
	ret

SprShtInstall endp

SprShtUninstall proc public

	invoke DestroyCursor,hCurHSplit
	invoke DestroyCursor,hCurVSplit
	ret

SprShtUninstall endp

;--------------------------------------------------------------------------------

IsOnCellButton proc uses esi,lpSheet:DWORD,lpWin:DWORD,lpPoint:DWORD,lpCelldata:DWORD
	LOCAL	rect:RECT

	mov		ebx,lpSheet
	mov		esi,lpCelldata
	invoke GetRealCellRect,lpSheet,lpWin,addr rect
	movzx	eax,[esi].COLDTA.fmt.imgal
	and		eax,FMTA_MASK
	.if eax==FMTA_GLOBAL
		movzx	eax,[ebx].SHEET.gfmt.cell.imgal
	.endif
	test	[esi].COLDTA.fmt.tpe,TPE_FIXEDSIZE
	.if ZERO?
		and		eax,FMTA_XMASK
		.if eax==FMTA_CENTER
			mov		edx,rect.right
			sub		edx,rect.left
			mov		eax,rect.bottom
			sub		eax,rect.top
			sub		edx,eax
			sar		edx,1
			add		rect.left,edx
			add		eax,rect.left
			mov		rect.right,eax
		.elseif eax==FMTA_RIGHT
			mov		eax,rect.bottom
			sub		eax,rect.top
			neg		eax
			add		eax,rect.right
			mov		rect.left,eax
		.else
			mov		eax,rect.bottom
			sub		eax,rect.top
			add		eax,rect.left
			mov		rect.right,eax
		.endif
	.else
		push	eax
		and		eax,FMTA_XMASK
		.if eax==FMTA_CENTER
			mov		edx,rect.right
			sub		edx,rect.left
			mov		eax,15
			sub		edx,eax
			sar		edx,1
			add		rect.left,edx
			add		eax,rect.left
			mov		rect.right,eax
		.elseif eax==FMTA_RIGHT
			mov		eax,15
			neg		eax
			add		eax,rect.right
			mov		rect.left,eax
		.else
			mov		eax,15
			add		eax,rect.left
			mov		rect.right,eax
		.endif
		pop		eax
		and		eax,FMTA_YMASK
		.if eax==FMTA_MIDDLE
			mov		edx,rect.bottom
			sub		edx,rect.top
			mov		eax,15
			sub		edx,eax
			sar		edx,1
			add		rect.top,edx
			add		eax,rect.top
			mov		rect.bottom,eax
		.elseif eax==FMTA_TOP
			mov		eax,15
			add		eax,rect.top
			mov		rect.bottom,eax
		.else
			mov		eax,rect.bottom
			sub		eax,15
			mov		rect.top,eax
		.endif
	.endif
	mov		edx,lpPoint
	mov		eax,[edx].POINT.x
	.if eax<rect.left || eax>rect.right
		xor		eax,eax
		ret
	.endif
	mov		eax,[edx].POINT.y
	.if eax<rect.top || eax>rect.bottom
		xor		eax,eax
		ret
	.endif
	mov		eax,TRUE
	ret

IsOnCellButton endp

WinProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	pt:POINT
	LOCAL	mDC:HDC
	LOCAL	ps:PAINTSTRUCT
	LOCAL	nWin:DWORD
	LOCAL	lf:LOGFONT
	LOCAL	sinf:SCROLLINFO
	LOCAL	nMin:DWORD
	LOCAL	nMax:DWORD
	LOCAL	sprsc:SPR_SELCHANGE
	LOCAL	sprlnk:SPR_HYPERLINK
	LOCAL	sprbtn:SPR_BUTTON
	LOCAL	spredt:SPR_EDIT
	LOCAL	spri:SPR_ITEM
	LOCAL	CellClick:DWORD

	invoke GetParent,hWin
	invoke GetWindowLong,eax,0
	.if eax
		mov		ebx,eax
		invoke GetWindowLong,hWin,GWL_ID
		mov		edx,sizeof WIN
		mul		edx
		lea		esi,[ebx].SHEET.owin[eax]
	.endif
	mov		eax,uMsg
	.if eax==WM_PAINT
		invoke BeginPaint,hWin,addr ps
		mov		eax,ps.hdc
		mov		[esi].WIN.hdc,eax
		invoke GetClientRect,hWin,addr rect
		invoke CreateCompatibleDC,ps.hdc
		mov		mDC,eax
		mov		[esi].WIN.mdc,eax
		invoke CreateCompatibleBitmap,ps.hdc,rect.right,rect.bottom
		push	eax
		invoke SelectObject,mDC,eax
		push	eax
		invoke SelectObject,mDC,[ebx].SHEET.ofont.hfont
		push	eax
		invoke SetBkMode,mDC,TRANSPARENT
		invoke DrawWin,ebx,esi
		invoke BitBlt,ps.hdc,0,0,rect.right,rect.bottom,mDC,0,0,SRCCOPY
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
		invoke EndPaint,hWin,addr ps
		mov		eax,[ebx].SHEET.nwin
		.if eax==[esi].WIN.nwin
			invoke DrawInput,ebx,esi
		.endif
		invoke GetClientRect,hWin,addr rect
		test	[ebx].SHEET.winst,SPS_VSCROLL
		.if !ZERO?
			mov		sinf.cbSize,sizeof sinf
			mov		sinf.fMask,SIF_ALL
			invoke GetScrollInfo,hWin,SB_VERT,addr sinf
			invoke GetY,ebx,[esi].WIN.lrow
			add		eax,edx
			mov		sinf.nMin,eax
			invoke GetY,ebx,[ebx].SHEET.gfmt.nrows
			add		eax,edx
			add		eax,SBSIZE
			mov		sinf.nMax,eax
			mov		eax,rect.bottom
			sub		eax,sinf.nMin
			mov		sinf.nPage,eax
			invoke GetY,ebx,[esi].WIN.trow
			mov		sinf.nPos,eax
			invoke SetScrollInfo,hWin,SB_VERT,addr sinf,TRUE
		.endif
		test	[ebx].SHEET.winst,SPS_HSCROLL
		.if !ZERO?
			mov		sinf.cbSize,sizeof sinf
			mov		sinf.fMask,SIF_ALL
			invoke GetScrollInfo,hWin,SB_HORZ,addr sinf
			invoke GetX,ebx,[esi].WIN.lcol
			add		eax,edx
			mov		sinf.nMin,eax
			invoke GetX,ebx,[ebx].SHEET.gfmt.ncols
			add		eax,edx
			add		eax,SBSIZE
			mov		sinf.nMax,eax
			mov		eax,rect.right
			sub		eax,sinf.nMin
			mov		sinf.nPage,eax
			invoke GetX,ebx,[esi].WIN.tcol
			mov		sinf.nPos,eax
			invoke SetScrollInfo,hWin,SB_HORZ,addr sinf,TRUE
		.endif
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_MOUSEWHEEL
		invoke ShowWindow,[ebx].SHEET.hedt,SW_HIDE
		invoke SetParent,[ebx].SHEET.hedt,[ebx].SHEET.hwnd
		mov		edx,wParam
		test	edx,MK_CONTROL
		.if ZERO?
			mov		eax,[esi].WIN.trow
			.if SDWORD ptr edx>0
				.if eax>3
					sub		eax,3
				.else
					mov		eax,1
				.endif
				.if eax<=[esi].WIN.lrow
					mov		eax,[esi].WIN.lrow
					inc		eax
				.endif
			.else
				add		eax,3
				.if eax>[ebx].SHEET.gfmt.nrows
					mov		eax,[ebx].SHEET.gfmt.nrows
				.endif
			.endif
			mov		[esi].WIN.trow,eax
		.else
			mov		eax,[esi].WIN.tcol
			.if SDWORD ptr edx>0
				.if eax>3
					sub		eax,3
				.else
					mov		eax,1
				.endif
				.if eax<=[esi].WIN.lcol
					mov		eax,[esi].WIN.lcol
					inc		eax
				.endif
			.else
				add		eax,3
				.if eax>[ebx].SHEET.gfmt.ncols
					mov		eax,[ebx].SHEET.gfmt.ncols
				.endif
			.endif
			mov		[esi].WIN.tcol,eax
		.endif
		invoke InvalidateRect,hWin,NULL,FALSE
	.elseif eax==WM_LBUTTONDBLCLK
		mov		eax,lParam
		and		eax,0FFFFh
		mov		pt.x,eax
		mov		eax,lParam
		shr		eax,16
		mov		pt.y,eax
		invoke GetCellFromPt,ebx,esi,addr pt
		.if eax
			mov		edx,eax
			movzx	eax,ax
			shr		edx,16
			.if eax==[esi].WIN.ccol && edx==[esi].WIN.crow
				invoke FindCell,ebx,[esi].WIN.ccol,[esi].WIN.crow
				.if eax
					movzx	eax,[eax].COLDTA.fmt.tpe
					and		eax,TPE_TYPEMASK
					.if eax==TPE_CHECKBOX || eax==TPE_COMBOBOX
						invoke PostMessage,hWin,WM_LBUTTONDOWN,wParam,lParam
						xor		eax,eax
						jmp		Ex
					.endif
				.endif
				invoke EditCell,ebx,esi,TRUE,0
			.endif
		.endif
	.elseif eax==WM_LBUTTONDOWN
		mov		eax,lParam
		and		eax,0FFFFh
		mov		pt.x,eax
		mov		eax,lParam
		shr		eax,16
		mov		pt.y,eax
		.if ![esi].WIN.sflag
			invoke IsWindowVisible,[ebx].SHEET.hedt
			.if eax
				invoke ShowWindow,[ebx].SHEET.hedt,SW_HIDE
			.endif
			mov		edx,SPRN_SELCHANGE
			call	SelChange
			.if !sprsc.fcancel
				invoke ShowWindow,[ebx].SHEET.hedt,SW_HIDE
				invoke SetParent,[ebx].SHEET.hedt,[ebx].SHEET.hwnd
				invoke SetFocus,hWin
				push	[esi].WIN.ccol
				push	[esi].WIN.crow
				invoke GetCellFromPt,ebx,esi,addr pt
				pop		[esi].WIN.crow
				pop		[esi].WIN.ccol
				.if eax
					mov		ecx,wParam
					and		ecx,MK_SHIFT
					mov		edx,eax
					movzx	eax,ax
					shr		edx,16
					mov		CellClick,TRUE
					.if eax!=[esi].WIN.ccol || edx!=[esi].WIN.crow
						mov		[esi].WIN.ccol,eax
						mov		[esi].WIN.crow,edx
						mov		CellClick,FALSE
						pushad
						invoke TestCurPos,ebx,esi
						invoke TestSync,esi
						invoke InvalidateRect,hWin,NULL,TRUE
						popad
					.endif
					.if !ecx
						mov		[esi].WIN.mcol,eax
						mov		[esi].WIN.mrow,edx
					.endif
					.if !ecx
						invoke FindCell,ebx,[esi].WIN.ccol,[esi].WIN.crow
						.if eax
							movzx	edx,[eax].COLDTA.fmt.tpe
							mov		ecx,edx
							and		edx,TPE_TYPEMASK
							and		ecx,30h
							.if edx==TPE_EXPANDED
								mov		edx,[eax].COLDTA.fmt.txtcol
								and		edx,0FFFFh
								mov		[esi].WIN.ccol,edx
								mov		[esi].WIN.mcol,edx
								mov		edx,[eax].COLDTA.fmt.txtcol
								shr		edx,16
								mov		[esi].WIN.crow,edx
								mov		[esi].WIN.mrow,edx
							.elseif edx==TPE_HYPERLINK
								mov		sprlnk.hdr.code,SPRN_HYPERLINKCLICK
								call	HyperLink
							.elseif ecx==TPE_BUTTON
								push	eax
								invoke IsOnCellButton,ebx,esi,addr pt,eax
								pop		edx
								.if eax
									mov		eax,edx
									mov		sprbtn.hdr.code,SPRN_BUTTONCLICK
									call	ButtonClick
								.endif
							.elseif ecx==TPE_WIDEBUTTON
								mov		sprbtn.hdr.code,SPRN_BUTTONCLICK
								call	ButtonClick
							.elseif edx==TPE_CHECKBOX
								;.if CellClick
									push	eax
									invoke IsOnCellButton,ebx,esi,addr pt,eax
									pop		edx
									.if eax
										invoke CheckClick,ebx,esi,edx
									.endif
								;.endif
							.elseif edx==TPE_COMBOBOX
;								.if CellClick && !hCtrl
								push	eax
								invoke IsOnCellButton,ebx,esi,addr pt,eax
								pop		edx
								.if !hCtrl && eax
									invoke ComboClick,ebx,esi,edx
								.else
									invoke ShowWindow,hCtrl,SW_HIDE
									mov		hCtrl,0
								.endif
								invoke InvalidateRect,hWin,NULL,TRUE
								xor		eax,eax
								jmp		Ex
							.endif
						.endif
					.endif
					invoke InvalidateRect,hWin,NULL,TRUE
				.endif
			.endif
			.if hCtrl
				invoke ShowWindow,hCtrl,SW_HIDE
				mov		hCtrl,0
			.endif
			invoke SetCapture,hWin
			xor		eax,eax
			jmp		Ex
		.else
			invoke ShowWindow,[ebx].SHEET.hedt,SW_HIDE
			invoke SetParent,[ebx].SHEET.hedt,[ebx].SHEET.hwnd
			or		[esi].WIN.sflag,100h
			mov		eax,pt.x
			mov		[esi].WIN.scurpt.x,eax
			mov		eax,pt.y
			mov		[esi].WIN.scurpt.y,eax
			invoke SetCursor,[esi].WIN.scur
		.endif
		.if hCtrl
			invoke ShowWindow,hCtrl,SW_HIDE
			mov		hCtrl,0
		.endif
		invoke SetCapture,hWin
	.elseif eax==WM_LBUTTONUP
		.if [esi].WIN.sflag>=100h
			mov		[esi].WIN.sflag,0
		.endif
		invoke ReleaseCapture
	.elseif eax==WM_MOUSEMOVE
		mov		eax,lParam
		and		eax,0FFFFh
		cwde
		mov		pt.x,eax
		mov		eax,lParam
		shr		eax,16
		cwde
		mov		pt.y,eax
		.if [esi].WIN.sflag<100h
			.if !wParam
				;Save current col/row
				push	[esi].WIN.ccol
				push	[esi].WIN.crow
				mov		[esi].WIN.ccol,0
				mov		[esi].WIN.crow,0
				invoke GetRealCellRect,ebx,esi,addr rect
				mov		eax,pt.x
				mov		edx,pt.y
				.if edx<rect.bottom
					;On col header
					mov		ecx,[ebx].SHEET.winst
					and		ecx,SPS_COLSIZE
					.if ecx
					  @@:
						mov		ecx,rect.right
						dec		ecx
						.if eax>=ecx && eax<=rect.right
							mov		edx,1
							mov		eax,hCurVSplit
							jmp		CurFound
						.endif
						.if sdword ptr eax>sdword ptr rect.right
							inc		[esi].WIN.ccol
							mov		eax,[esi].WIN.ccol
							.if eax>[esi].WIN.lcol && eax<[esi].WIN.tcol
								push	[esi].WIN.tcol
								pop		[esi].WIN.ccol
							.endif
							invoke GetRealCellRect,ebx,esi,addr rect
							mov		eax,pt.x
							mov		edx,pt.y
							jmp		@b
						.endif
					.endif
				.elseif eax<rect.right
					;On row header
					mov		ecx,[ebx].SHEET.winst
					and		ecx,SPS_ROWSIZE
					.if ecx
					  @@:
						mov		ecx,rect.bottom
						dec		ecx
						.if edx>=ecx && edx<=rect.bottom
							mov		edx,2
							mov		eax,hCurHSplit
							jmp		CurFound
						.endif
						.if sdword ptr edx>sdword ptr rect.bottom
							inc		[esi].WIN.crow
							mov		eax,[esi].WIN.crow
							.if eax>[esi].WIN.lrow && eax<[esi].WIN.trow
								push	[esi].WIN.trow
								pop		[esi].WIN.crow
							.endif
							invoke GetRealCellRect,ebx,esi,addr rect
							mov		eax,pt.x
							mov		edx,pt.y
							jmp		@b
						.endif
					.endif
				.endif
				mov		ecx,[ebx].SHEET.winst
				and		ecx,SPS_WINSIZE
				.if [esi].WIN.nwin && ecx
					mov		[esi].WIN.ccol,0
					mov		[esi].WIN.crow,0
					invoke GetRealCellRect,ebx,esi,addr rect
					mov		eax,rect.right
					sub		eax,rect.left
					shr		eax,1
					dec		eax
					dec		eax
					add		rect.left,eax
					sub		rect.right,eax
					mov		eax,rect.bottom
					sub		eax,rect.top
					shr		eax,1
					dec		eax
					dec		eax
					add		rect.top,eax
					sub		rect.bottom,eax
					mov		eax,pt.x
					mov		edx,pt.y
					.if eax>rect.left && eax<rect.right && edx>rect.top && edx<rect.bottom
						mov		edx,3
						mov		eax,hCurSize
						jmp		CurFound
					.endif
				.endif
				invoke GetCellFromPt,ebx,esi,addr pt
				mov		edx,eax
				shr		edx,16
				and		eax,0FFFFh
				mov		[esi].WIN.ccol,eax
				mov		[esi].WIN.crow,edx
				invoke FindCell,ebx,eax,edx
				.if eax
					movzx	edx,[eax].COLDTA.fmt.tpe
					and		edx,TPE_TYPEMASK
					.if edx==TPE_HYPERLINK
						.if eax!=lpHyperlink
							.if lpHyperlink
								push	eax
								mov		eax,lpHyperlink
								mov		ecx,OldHyperlinkCol
								mov		[eax].COLDTA.fmt.txtcol,ecx
								mov		sprlnk.hdr.code,SPRN_HYPERLINKLEAVE
								call	HyperLink
								invoke InvalidateRect,hWin,addr HyperLinkRect,TRUE
								pop		eax
							.endif
							mov		lpHyperlink,eax
							mov		ecx,[eax].COLDTA.fmt.txtcol
							mov		OldHyperlinkCol,ecx
							mov		[eax].COLDTA.fmt.txtcol,0FF0000h
							push	eax
							mov		sprlnk.hdr.code,SPRN_HYPERLINKENTER
							call	HyperLink
							pop		eax
							mov		ecx,spri.fmt.txtcol
							mov		[eax].COLDTA.fmt.txtcol,ecx
							invoke GetRealCellRect,ebx,esi,addr HyperLinkRect
							invoke InvalidateRect,hWin,addr HyperLinkRect,TRUE
						.endif
						invoke LoadCursor,0,IDC_HAND
					.else
						mov		eax,hCurArrow
					.endif
				.else
					mov		eax,hCurArrow
				.endif
				.if lpHyperlink && eax==hCurArrow
					mov		eax,lpHyperlink
					mov		ecx,OldHyperlinkCol
					mov		[eax].COLDTA.fmt.txtcol,ecx
					mov		sprlnk.hdr.code,SPRN_HYPERLINKLEAVE
					call	HyperLink
					invoke InvalidateRect,hWin,addr HyperLinkRect,TRUE
					mov		lpHyperlink,0
					mov		eax,hCurArrow
				.endif
				xor		edx,edx
			  CurFound:
				mov		[esi].WIN.sflag,edx
				mov		[esi].WIN.scur,eax
				invoke SetCursor,eax
				push	[esi].WIN.ccol
				pop		[esi].WIN.scol
				push	[esi].WIN.crow
				pop		[esi].WIN.srow
				;Restore current col/row
				pop		[esi].WIN.crow
				pop		[esi].WIN.ccol
			.elseif wParam==MK_LBUTTON
				;Multiselect
				invoke GetCapture
				mov		edx,[ebx].SHEET.winst
				and		edx,SPS_MULTISELECT
				.if eax==hWin && edx
					invoke GetClientRect,hWin,addr rect
					invoke FindRow,ebx,0
					mov		ax,[eax].ROWDTA.rowht
					cwde
					.if eax==-1
						mov		eax,[ebx].SHEET.gfmt.ghdrht
					.endif
					mov		rect.top,eax
					invoke FindCell,ebx,0,0
					mov		ax,word ptr [eax].COLDTA.fmt.tpe[1]
					cwde
					.if eax==-1
						mov		eax,[ebx].SHEET.gfmt.ghdrwt
					.endif
					mov		rect.left,eax
					mov		eax,pt.y
					.if sdword ptr eax>rect.bottom
						mov		eax,rect.bottom
						mov		pt.y,eax
						mov		eax,[ebx].SHEET.gfmt.nrows
						.if eax>[esi].WIN.trow
							inc		[esi].WIN.trow
						.endif
					.elseif sdword ptr eax<rect.top
						mov		eax,rect.top
						inc		eax
						mov		pt.y,eax
						.if [esi].WIN.trow>1
							dec		[esi].WIN.trow
						.endif
					.endif
					mov		eax,pt.x
					.if sdword ptr eax>rect.right
						mov		eax,rect.right
						mov		pt.x,eax
						mov		eax,[ebx].SHEET.gfmt.ncols
						.if eax>[esi].WIN.tcol
							inc		[esi].WIN.tcol
						.endif
					.elseif sdword ptr eax<rect.left
						mov		eax,rect.left
						inc		eax
						mov		pt.x,eax
						.if [esi].WIN.tcol>1
							dec		[esi].WIN.tcol
						.endif
					.endif
					push	[esi].WIN.ccol
					push	[esi].WIN.crow
					invoke GetCellFromPt,ebx,esi,addr pt
					pop		[esi].WIN.crow
					pop		[esi].WIN.ccol
					mov		edx,eax
					shr		edx,16
					and		eax,0FFFFh
					.if eax && edx
						.if eax!=[esi].WIN.mcol || edx!=[esi].WIN.mrow
							push	eax
							push	edx
							mov		edx,SPRN_SELCHANGE
							call	SelChange
							pop		edx
							pop		eax
							.if !sprsc.fcancel
								mov		[esi].WIN.mcol,eax
								mov		[esi].WIN.mrow,edx
							.endif
						.endif
					.endif
					invoke InvalidateRect,hWin,NULL,TRUE
				.endif
			.endif
		.elseif [esi].WIN.sflag==101h
			;Col width sizeing
			;
			;Save current col/row
			push	[esi].WIN.ccol
			push	[esi].WIN.crow

			push	[esi].WIN.scol
			pop		[esi].WIN.ccol
			mov		[esi].WIN.crow,0
			invoke GetRealCellRect,ebx,esi,addr rect
			invoke GetParent,hWin
			mov		edx,eax
			mov		eax,pt.x
			.if eax<rect.left || sword ptr ax<0
				mov		eax,rect.left
			.endif
			sub		eax,[esi].WIN.scurpt.x
			add		[esi].WIN.scurpt.x,eax
			add		eax,rect.right
			sub		eax,rect.left
			.if eax<4
				mov		eax,4
			.endif
			invoke SendMessage,edx,SPRM_SETCOLWIDTH,[esi].WIN.ccol,eax
			;Restore current col/row
			pop		[esi].WIN.crow
			pop		[esi].WIN.ccol
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif [esi].WIN.sflag==102h
			;Row height sizeing
			;
			;Save current col/row
			push	[esi].WIN.ccol
			push	[esi].WIN.crow
			push	[esi].WIN.srow
			pop		[esi].WIN.crow
			mov		[esi].WIN.ccol,0
			invoke GetRealCellRect,ebx,esi,addr rect
			invoke GetParent,hWin
			mov		edx,eax
			mov		eax,pt.y
			.if eax<rect.top || sword ptr ax<0
				mov		eax,rect.top
			.endif
			sub		eax,[esi].WIN.scurpt.y
			add		[esi].WIN.scurpt.y,eax
			add		eax,rect.bottom
			sub		eax,rect.top
			.if eax<4
				mov		eax,4
			.endif
			invoke SendMessage,edx,SPRM_SETROWHEIGHT,[esi].WIN.crow,eax
			;Restore current col/row
			pop		[esi].WIN.crow
			pop		[esi].WIN.ccol
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif [esi].WIN.sflag==103h
			;Split sizeing
			;
			;Get win button size
			invoke GetCellRect,ebx,esi,0,0,addr rect
			mov		edx,esi
			sub		edx,sizeof WIN
			mov		eax,[edx].WIN.rect.top
			.if eax==[esi].WIN.rect.top
				;VSplitt sizeing
				mov		eax,[edx].WIN.rect.left
				add		eax,50
				mov		nMin,eax
				mov		eax,[esi].WIN.rect.right
				sub		eax,50
				mov		nMax,eax
				mov		eax,[esi].WIN.nwin
				mov		nWin,eax
				mov		eax,pt.x
				mov		edx,rect.right
				sub		edx,rect.left
				shr		edx,1
				sub		eax,edx
				mov		edx,esi
				mov		ecx,[esi].WIN.rect.left
				.while nWin<WINMAX
					.if ecx==[edx].WIN.rect.left && [edx].WIN.act!=-1
						push	eax
						add		eax,[edx].WIN.rect.left
						.if sdword ptr eax<nMin
							mov		eax,nMin
						.elseif sdword ptr eax>nMax
							mov		eax,nMax
						.endif
						mov		[edx].WIN.rect.left,eax
						pop		eax
					.endif
					add		edx,sizeof WIN
					inc		nWin
				.endw
			.else
				;HSplitt sizeing
				mov		eax,[edx].WIN.rect.top
				add		eax,50
				mov		nMin,eax
				mov		eax,[esi].WIN.rect.bottom
				sub		eax,50
				mov		nMax,eax
				mov		eax,[esi].WIN.nwin
				mov		nWin,eax
				mov		eax,pt.y
				mov		edx,rect.bottom
				sub		edx,rect.top
				shr		edx,1
				sub		eax,edx
				mov		edx,esi
				mov		ecx,[esi].WIN.rect.top
				.while nWin<WINMAX
					.if ecx==[edx].WIN.rect.top && [edx].WIN.act!=-1
						push	eax
						add		eax,[edx].WIN.rect.top
						.if sdword ptr eax<nMin
							mov		eax,nMin
						.elseif sdword ptr eax>nMax
							mov		eax,nMax
						.endif
						mov		[edx].WIN.rect.top,eax
						pop		eax
					.endif
					add		edx,sizeof WIN
					inc		nWin
				.endw
			.endif
			invoke SendMessage,[ebx].SHEET.hwnd,WM_SIZE,0,0
		.endif
	.elseif eax==WM_KEYDOWN
		.if hCtrl
			invoke ShowWindow,hCtrl,SW_HIDE
			mov		hCtrl,0
		.endif
		invoke GetKeyState,VK_SHIFT
		and		eax,80h
		test	[ebx].SHEET.winst,SPS_MULTISELECT
		jne		@f
		xor		eax,eax
	  @@:
		push	eax
		invoke GetKeyState,VK_CONTROL
		pop		ecx
		and		eax,80h
		mov		ch,al
		mov		eax,wParam
		.if eax==VK_RIGHT || eax==VK_LEFT || eax==VK_DOWN || eax==VK_UP || eax==VK_PGDN || eax==VK_PGUP || eax==VK_END || eax==VK_HOME
			push	[esi].WIN.tcol
			push	[esi].WIN.trow
			push	[esi].WIN.ccol
			push	[esi].WIN.crow
			push	[esi].WIN.mcol
			push	[esi].WIN.mrow
			.if eax==VK_RIGHT
				mov		eax,[esi].WIN.ccol
				.if eax<[ebx].SHEET.gfmt.ncols
					.if ch
						mov		eax,[ebx].SHEET.gfmt.ncols
						mov		[esi].WIN.ccol,eax
						invoke CurMove,ebx,esi,0,0,ecx
					.else
						invoke CurMove,ebx,esi,1,0,ecx
					.endif
				.endif
			.elseif eax==VK_LEFT
				mov		eax,[esi].WIN.ccol
				.if eax>1
					.if ch
						mov		[esi].WIN.ccol,1
						invoke CurMove,ebx,esi,0,0,ecx
					.else
						invoke CurMove,ebx,esi,-1,0,ecx
					.endif
				.endif
			.elseif eax==VK_UP
				mov		eax,[esi].WIN.crow
				.if eax>1
					.if ch
						mov		[esi].WIN.crow,1
						invoke CurMove,ebx,esi,0,0,ecx
					.else
						invoke CurMove,ebx,esi,0,-1,ecx
					.endif
				.endif
			.elseif eax==VK_DOWN
				mov		eax,[esi].WIN.crow
				.if eax<[ebx].SHEET.gfmt.nrows
					.if ch
						mov		eax,[ebx].SHEET.gfmt.nrows
						mov		[esi].WIN.crow,eax
						sub		eax,50
						jnb		@f
						mov		eax,1
					  @@:
						mov		[esi].WIN.trow,eax
						invoke CurMove,ebx,esi,0,0,ecx
					.else
						invoke CurMove,ebx,esi,0,1,ecx
					.endif
				.endif
			.elseif eax==VK_PGDN
				mov		eax,[esi].WIN.crow
				.if eax<[ebx].SHEET.gfmt.nrows
					push	ecx
					invoke CurMove,ebx,esi,0,0,ecx
					mov		edx,[esi].WIN.crow
					mov		eax,edx
					sub		eax,[esi].WIN.trow
					push	eax
					.while edx<[ebx].SHEET.gfmt.nrows
						inc		[esi].WIN.crow
						invoke TestCurPos,ebx,esi
						mov		edx,[esi].WIN.crow
					  .break .if eax
					.endw
					mov		[esi].WIN.trow,edx
					pop		eax
					add		edx,eax
					.if edx>[ebx].SHEET.gfmt.nrows
						mov		edx,[ebx].SHEET.gfmt.nrows
					.endif
					mov		[esi].WIN.crow,edx
					pop		ecx
					.if !cl
						mov		eax,[esi].WIN.ccol
						mov		[esi].WIN.mcol,eax
						mov		eax,[esi].WIN.crow
						mov		[esi].WIN.mrow,eax
					.endif
				.endif
			.elseif eax==VK_PGUP
				mov		eax,[esi].WIN.crow
				.if eax>1
					push	ecx
					invoke CurMove,ebx,esi,0,0,ecx
					mov		edx,[esi].WIN.trow
					mov		eax,[esi].WIN.crow
					sub		eax,edx
					push	eax
					.while edx>1
						dec		[esi].WIN.trow
						invoke TestCurPos,ebx,esi
						mov		edx,[esi].WIN.trow
					  .break .if eax
					.endw
					.if edx>1
						dec		edx
					.endif
					mov		[esi].WIN.crow,edx
					pop		eax
					sub		edx,eax
					.if SDWORD ptr edx<1
						mov		edx,1
					.endif
					mov		[esi].WIN.trow,edx
					pop		ecx
					.if !cl
						mov		eax,[esi].WIN.ccol
						mov		[esi].WIN.mcol,eax
						mov		eax,[esi].WIN.crow
						mov		[esi].WIN.mrow,eax
					.endif
				.endif
			.elseif eax==VK_HOME
				.if [esi].WIN.ccol!=1 || [esi].WIN.crow!=1
					mov		[esi].WIN.ccol,1
					mov		[esi].WIN.crow,1
					.if !cl
						mov		[esi].WIN.mcol,1
						mov		[esi].WIN.mrow,1
					.endif
				.endif
			.elseif eax==VK_END
				mov		eax,[ebx].SHEET.gfmt.ncols
				mov		edx,[ebx].SHEET.gfmt.nrows
				.if eax!=[esi].WIN.crow || edx!=[esi].WIN.ccol
					mov		[esi].WIN.ccol,eax
					mov		[esi].WIN.crow,edx
					.if !cl
						mov		[esi].WIN.mcol,eax
						mov		[esi].WIN.mrow,edx
					.endif
					sub		eax,50
					jnb		@f
					mov		eax,1
				  @@:
					mov		[esi].WIN.tcol,eax
					sub		edx,50
					jnb		@f
					mov		edx,1
				  @@:
					mov		[esi].WIN.trow,edx
				.endif
			.endif
			mov		eax,[ebx].SHEET.hwnd
			mov		sprsc.hdr.hwndFrom,eax
			mov		eax,[ebx].SHEET.nid
			mov		sprsc.hdr.idFrom,eax
			mov		sprsc.hdr.code,SPRN_SELCHANGE
			mov		eax,[esi].WIN.nwin
			mov		sprsc.nwin,eax
			mov		eax,[esi].WIN.ccol
			mov		sprsc.col,eax
			mov		eax,[esi].WIN.crow
			mov		sprsc.row,eax
			mov		sprsc.fcancel,FALSE
			invoke SendMessage,[ebx].SHEET.howner,WM_NOTIFY,[ebx].SHEET.nid,addr sprsc
			.if !sprsc.fcancel
				pop		eax
				pop		eax
				pop		eax
				pop		eax
				pop		eax
				pop		eax
			.else
				pop		[esi].WIN.mrow
				pop		[esi].WIN.mcol
				pop		[esi].WIN.crow
				pop		[esi].WIN.ccol
				pop		[esi].WIN.trow
				pop		[esi].WIN.tcol
			.endif
			invoke TestCurPos,ebx,esi
			invoke TestSync,esi
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif eax==VK_TAB
			mov		eax,esi
			add		esi,sizeof WIN
			.if [esi].WIN.act==-1
				lea		esi,[ebx].SHEET.owin
			.endif
			.if eax!=esi
				push	eax
				mov		eax,[ebx].SHEET.hwnd
				mov		sprsc.hdr.hwndFrom,eax
				mov		eax,[ebx].SHEET.nid
				mov		sprsc.hdr.idFrom,eax
				mov		sprsc.hdr.code,SPRN_SELCHANGE
				mov		eax,[esi].WIN.nwin
				mov		sprsc.nwin,eax
				mov		eax,[esi].WIN.ccol
				mov		sprsc.col,eax
				mov		eax,[esi].WIN.crow
				mov		sprsc.row,eax
				mov		sprsc.fcancel,FALSE
				invoke SendMessage,[ebx].SHEET.howner,WM_NOTIFY,[ebx].SHEET.nid,addr sprsc
				.if !sprsc.fcancel
					pop		eax
					invoke SetFocus,[esi].WIN.hwin
					invoke TestCurPos,ebx,esi
					invoke TestSync,esi
					invoke InvalidateRect,hWin,NULL,TRUE
				.else
					pop		esi
				.endif
			.endif
		.elseif eax==VK_RETURN
			invoke EditCell,ebx,esi,TRUE,0
			.if eax
				mov		sprbtn.hdr.code,SPRN_BUTTONCLICK
				call	ButtonClick
			.endif
		.endif
	.elseif eax==WM_CHAR
		mov		eax,wParam
		.if eax>=' ' && eax<='z'
			invoke EditCell,ebx,esi,TRUE,eax
			.if eax
				mov		sprbtn.hdr.code,SPRN_BUTTONCLICK
				call	ButtonClick
			.endif
		.endif
	.elseif eax==WM_SETFOCUS
		invoke GetWindowLong,hWin,GWL_ID
		mov		[ebx].SHEET.nwin,eax
		mov		[esi].WIN.act,1
		invoke InvalidateRect,hWin,NULL,TRUE
	.elseif eax==WM_KILLFOCUS
		mov		[esi].WIN.act,0
		invoke InvalidateRect,hWin,NULL,TRUE
	.elseif eax==WM_VSCROLL
		.if hCtrl
			invoke ShowWindow,hCtrl,SW_HIDE
			mov		hCtrl,0
		.endif
		invoke ShowWindow,[ebx].SHEET.hedt,SW_HIDE
		invoke SetParent,[ebx].SHEET.hedt,[ebx].SHEET.hwnd
		mov		sinf.cbSize,sizeof sinf
		mov		sinf.fMask,SIF_ALL
		invoke GetScrollInfo,hWin,SB_VERT,addr sinf
		mov		eax,wParam
		and		eax,0FFFFh
		.if eax==SB_THUMBTRACK || eax==SB_THUMBPOSITION
			invoke GetRowFromY,ebx,sinf.nTrackPos
			mov		[esi].WIN.trow,eax
		.elseif eax==SB_LINEDOWN
			mov		eax,[esi].WIN.trow
			.if eax<[ebx].SHEET.gfmt.nrows
				inc		[esi].WIN.trow
			.endif
		.elseif eax==SB_LINEUP
			mov		eax,[esi].WIN.lrow
			inc		eax
			.if eax<[esi].WIN.trow
				dec		[esi].WIN.trow
			.endif
		.elseif eax==SB_PAGEDOWN
			mov		eax,sinf.nPos
			add		eax,sinf.nPage
			invoke GetRowFromY,ebx,eax
			mov		[esi].WIN.trow,eax
		.elseif eax==SB_PAGEUP
			mov		eax,sinf.nPos
			sub		eax,sinf.nPage
			jnb		@f
			mov		eax,sinf.nMin
		  @@:
			cmp		eax,sinf.nMin
			jnb		@f
			mov		eax,sinf.nMin
		  @@:
			invoke GetRowFromY,ebx,eax
			mov		[esi].WIN.trow,eax
		.endif
		invoke InvalidateRect,hWin,NULL,TRUE
		xor eax,eax
		jmp		Ex
	.elseif eax==WM_HSCROLL
		.if hCtrl
			invoke ShowWindow,hCtrl,SW_HIDE
			mov		hCtrl,0
		.endif
		invoke ShowWindow,[ebx].SHEET.hedt,SW_HIDE
		invoke SetParent,[ebx].SHEET.hedt,[ebx].SHEET.hwnd
		mov		sinf.cbSize,sizeof sinf
		mov		sinf.fMask,SIF_ALL
		invoke GetScrollInfo,hWin,SB_HORZ,addr sinf
		mov		eax,wParam
		and		eax,0FFFFh
		.if eax==SB_THUMBTRACK || eax==SB_THUMBPOSITION
			invoke GetColFromX,ebx,sinf.nTrackPos
			mov		[esi].WIN.tcol,eax
		.elseif eax==SB_LINELEFT
			mov		eax,[esi].WIN.lcol
			inc		eax
			.if eax<[esi].WIN.tcol
				dec		[esi].WIN.tcol
			.endif
		.elseif eax==SB_LINERIGHT
			mov		eax,[esi].WIN.tcol
			.if eax<[ebx].SHEET.gfmt.ncols
				inc		[esi].WIN.tcol
			.endif
		.elseif eax==SB_PAGELEFT
			mov		eax,sinf.nPos
			sub		eax,sinf.nPage
			jnb		@f
			mov		eax,sinf.nMin
		  @@:
			cmp		eax,sinf.nMin
			jnb		@f
			mov		eax,sinf.nMin
		  @@:
			invoke GetColFromX,ebx,eax
			mov		[esi].WIN.tcol,eax
		.elseif eax==SB_PAGERIGHT
			mov		eax,sinf.nPos
			add		eax,sinf.nPage
			invoke GetColFromX,ebx,eax
			mov		[esi].WIN.tcol,eax
		.endif
		invoke InvalidateRect,hWin,NULL,TRUE
		xor eax,eax
		jmp		Ex
	.elseif eax==WM_GETDLGCODE
 		mov		eax,DLGC_WANTALLKEYS or DLGC_WANTCHARS
		jmp		Ex
	.endif
  ExDef:
	invoke DefWindowProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

HyperLink:
	mov		edx,eax
	lea		edi,spri
	mov		eax,[esi].WIN.ccol
	mov		[edi].SPR_ITEM.col,eax
	mov		eax,[esi].WIN.crow
	mov		[edi].SPR_ITEM.row,eax
	mov		eax,[edx].COLDTA.fmt.bckcol
	mov		[edi].SPR_ITEM.fmt.bckcol,eax
	mov		eax,[edx].COLDTA.fmt.txtcol
	mov		[edi].SPR_ITEM.fmt.txtcol,eax
	mov		al,[edx].COLDTA.fmt.txtal
	mov		[edi].SPR_ITEM.fmt.txtal,al
	mov		al,[edx].COLDTA.fmt.imgal
	mov		[edi].SPR_ITEM.fmt.imgal,al
	mov		al,[edx].COLDTA.state
	mov		[edi].SPR_ITEM.state,al
	mov		al,[edx].COLDTA.fmt.fnt
	mov		[edi].SPR_ITEM.fmt.fnt,al
	mov		al,[edx].COLDTA.expx
	mov		[edi].SPR_ITEM.expx,al
	mov		al,[edx].COLDTA.expy
	mov		[edi].SPR_ITEM.expy,al
	mov		al,[edx].COLDTA.fmt.tpe
	mov		[edi].SPR_ITEM.fmt.tpe,al
	lea		eax,[edx].COLDTA.fmt.tpe[1]
	mov		[edi].SPR_ITEM.lpdta,eax
	mov		eax,[ebx].SHEET.hwnd
	mov		sprlnk.hdr.hwndFrom,eax
	mov		eax,[ebx].SHEET.nid
	mov		sprlnk.hdr.idFrom,eax
	mov		sprlnk.lpspri,edi
	invoke SendMessage,[ebx].SHEET.howner,WM_NOTIFY,[ebx].SHEET.nid,addr sprlnk
	retn

ButtonClick:
	mov		edx,eax
	lea		edi,spri
	mov		eax,[esi].WIN.ccol
	mov		[edi].SPR_ITEM.col,eax
	mov		eax,[esi].WIN.crow
	mov		[edi].SPR_ITEM.row,eax
	mov		eax,[edx].COLDTA.fmt.bckcol
	mov		[edi].SPR_ITEM.fmt.bckcol,eax
	mov		eax,[edx].COLDTA.fmt.txtcol
	mov		[edi].SPR_ITEM.fmt.txtcol,eax
	mov		al,[edx].COLDTA.fmt.txtal
	mov		[edi].SPR_ITEM.fmt.txtal,al
	mov		al,[edx].COLDTA.fmt.imgal
	mov		[edi].SPR_ITEM.fmt.imgal,al
	mov		al,[edx].COLDTA.state
	mov		[edi].SPR_ITEM.state,al
	mov		al,[edx].COLDTA.fmt.fnt
	mov		[edi].SPR_ITEM.fmt.fnt,al
	mov		al,[edx].COLDTA.expx
	mov		[edi].SPR_ITEM.expx,al
	mov		al,[edx].COLDTA.expy
	mov		[edi].SPR_ITEM.expy,al
	mov		al,[edx].COLDTA.fmt.tpe
	mov		[edi].SPR_ITEM.fmt.tpe,al
	lea		eax,[edx].COLDTA.fmt.tpe[1]
	mov		[edi].SPR_ITEM.lpdta,eax
	mov		eax,[ebx].SHEET.hwnd
	mov		sprbtn.hdr.hwndFrom,eax
	mov		eax,[ebx].SHEET.nid
	mov		sprbtn.hdr.idFrom,eax
	mov		sprbtn.lpspri,edi
	invoke SendMessage,[ebx].SHEET.howner,WM_NOTIFY,[ebx].SHEET.nid,addr sprbtn
	retn

SelChange:
	mov		sprsc.hdr.code,edx
	mov		eax,[ebx].SHEET.hwnd
	mov		sprsc.hdr.hwndFrom,eax
	mov		eax,[ebx].SHEET.nid
	mov		sprsc.hdr.idFrom,eax
	mov		sprsc.hdr.code,SPRN_SELCHANGE
	mov		eax,[esi].WIN.nwin
	mov		sprsc.nwin,eax
	push	[esi].WIN.ccol
	push	[esi].WIN.crow
	invoke GetCellFromPt,ebx,esi,addr pt
	pop		[esi].WIN.crow
	pop		[esi].WIN.ccol
	mov		edx,eax
	and		eax,0FFFFh
	shr		edx,16
	mov		sprsc.col,eax
	mov		sprsc.row,edx
	mov		sprsc.fcancel,FALSE
	invoke SendMessage,[ebx].SHEET.howner,WM_NOTIFY,[ebx].SHEET.nid,addr sprsc
	retn

WinProc endp

EditProc proc uses ebx esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[2048]:BYTE
	LOCAL	spredt:SPR_EDIT

	mov		eax,uMsg
	.if eax==WM_KILLFOCUS
		call SetUp
		.if !fEditCancel
			call Update
		.endif
		mov		[ebx].SHEET.fedt,FALSE
		invoke SetParent,hWin,[ebx].SHEET.hwnd
		invoke InvalidateRect,[ebx].SHEET.hwnd,NULL,FALSE
		mov		fEditCancel,FALSE
	.elseif eax==WM_KEYDOWN
		mov		eax,wParam
		.if eax==VK_RETURN
			invoke ShowWindow,hWin,SW_HIDE
			xor		eax,eax
			ret
		.endif
	.elseif eax==WM_CHAR
		mov		eax,wParam
		.if eax==VK_RETURN
			xor		eax,eax
			ret
		.elseif eax==VK_ESCAPE
			mov		fEditCancel,TRUE
			invoke ShowWindow,hWin,SW_HIDE
		.endif
	.elseif eax==WM_GETDLGCODE
 		mov		eax,DLGC_WANTALLKEYS or DLGC_WANTCHARS
		jmp		Ex
	.endif
	invoke CallWindowProc,OldEditProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

SetUp:
	invoke GetWindowLong,hWin,GWL_USERDATA
	mov		ebx,eax
	mov		edx,[ebx].SHEET.nwin
	mov		eax,sizeof WIN
	mul		edx
	lea		esi,[ebx].SHEET.owin[eax]
	retn

Update:
	invoke SendMessage,hWin,WM_GETTEXT,sizeof buffer,addr buffer
	lea		eax,buffer
	mov		[ebx].SHEET.spri.lpdta,eax
	mov		eax,[ebx].SHEET.hwnd
	mov		spredt.hdr.hwndFrom,eax
	mov		eax,[ebx].SHEET.nid
	mov		spredt.hdr.idFrom,eax
	mov		spredt.hdr.code,SPRN_AFTEREDIT
	lea		eax,[ebx].SHEET.spri
	mov		spredt.lpspri,eax
	mov		spredt.fcancel,FALSE
	invoke SendMessage,[ebx].SHEET.howner,WM_NOTIFY,[ebx].SHEET.nid,addr spredt
	.if !spredt.fcancel
		movzx	eax,[ebx].SHEET.spri.fmt.tpe
		and		eax,TPE_TYPEMASK
		.if eax==TPE_TEXT || eax==TPE_HYPERLINK || eax==TPE_TEXTMULTILINE
			invoke lstrcpy,addr buff,addr buffer
			movzx	eax,[ebx].SHEET.spri.fmt.tpe
		.elseif eax==TPE_INTEGER
			invoke Compile,ebx,addr buffer,addr buff
			.if al!=TPE_INTEGER
				retn
			.endif
			movzx	eax,[ebx].SHEET.spri.fmt.tpe
 		.elseif eax==TPE_FLOAT
			invoke Compile,ebx,addr buffer,addr buff
			.if al==TPE_INTEGER
				fild	dword ptr buff
				fstp	tbyte ptr buff
			.elseif al!=TPE_FLOAT
				retn
			.endif
			movzx	eax,[ebx].SHEET.spri.fmt.tpe
 		.else
			invoke Compile,ebx,addr buffer,addr buff
			mov		[ebx].SHEET.spri.fmt.tpe,al
		.endif
		push	eax
		lea		eax,buff
		mov		[ebx].SHEET.spri.lpdta,eax
		mov		eax,[ebx].SHEET.hwnd
		mov		spredt.hdr.hwndFrom,eax
		mov		eax,[ebx].SHEET.nid
		mov		spredt.hdr.idFrom,eax
		mov		spredt.hdr.code,SPRN_BEFOREUPDATE
		lea		eax,[ebx].SHEET.spri
		mov		spredt.lpspri,eax
		mov		spredt.fcancel,FALSE
		invoke SendMessage,[ebx].SHEET.howner,WM_NOTIFY,[ebx].SHEET.nid,addr spredt
		pop		edx
		.if !spredt.fcancel
			invoke UpdateCell,ebx,[ebx].SHEET.spri.col,[ebx].SHEET.spri.row,edx,addr buff,0
			lea		eax,buff
			mov		[ebx].SHEET.spri.lpdta,eax
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
	.endif
	retn

EditProc endp

ComboProc proc uses ebx esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	spredt:SPR_EDIT
	LOCAL	pt:POINT

	mov		eax,uMsg
	.if eax==WM_LBUTTONDOWN
		invoke GetWindowLong,hWin,GWL_USERDATA
		mov		eax,[eax].COMBO.howner
		invoke GetWindowLong,eax,0
		mov		ebx,eax
		mov		edx,[ebx].SHEET.nwin
		mov		eax,sizeof WIN
		mul		edx
		lea		esi,[ebx].SHEET.owin[eax]
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
		.if !spredt.fcancel
			invoke SendMessage,hWin,LB_GETCURSEL,0,0
			mov		edx,lpCellData
			mov		dword ptr [edx].COLDTA.fmt.tpe[1],eax
			invoke ShowWindow,hWin,SW_HIDE
			invoke SetFocus,hCurrent
			invoke RecalcSheet,ebx
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
		.endif
		xor		eax,eax
		mov		hCtrl,eax
		jmp		Ex
	.elseif eax==WM_MOUSEMOVE
		invoke SendMessage,hWin,LB_GETCURSEL,0,0
		push	eax
		invoke GetCursorPos,addr pt
		invoke LBItemFromPt,hWin,pt.x,pt.y,TRUE
		pop		edx
		.if eax!=edx
			invoke SendMessage,hWin,LB_SETCURSEL,eax,0
		.endif
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_ACTIVATE
		mov		eax,wParam
		movzx	eax,ax
		mov		edx,lParam
		.if eax!=WA_INACTIVE
			mov		hfocus,edx
			invoke SendMessage,edx,WM_NCACTIVATE,TRUE,0
		.elseif edx!=hfocus
			invoke SendMessage,hfocus,WM_NCACTIVATE,FALSE,0
			invoke ShowWindow,hWin,SW_HIDE
			xor		eax,eax
			mov		hCtrl,eax
		.else
			invoke ShowWindow,hWin,SW_HIDE
			xor		eax,eax
			mov		hCtrl,eax
		.endif
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_CHAR
		mov		eax,wParam
		.if eax==VK_ESCAPE
			invoke GetWindowLong,hWin,GWL_USERDATA
			invoke SetFocus,[eax].COMBO.howner
		.elseif eax==VK_RETURN
			invoke SendMessage,hWin,WM_LBUTTONDOWN,0,0
		.endif
	.elseif eax==WM_DESTROY
		invoke GetWindowLong,hWin,GWL_USERDATA
		invoke GlobalFree,eax
	.endif
	invoke CallWindowProc,OldComboProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

ComboProc endp

TestExpand proc uses ebx esi edi,lpSheet:DWORD,lpRect:DWORD

	mov		ebx,lpSheet
	mov		esi,lpRect
	xor		edi,edi
	mov		edx,[esi].RECT.top
	.while edx<=[esi].RECT.bottom
		mov		ecx,[esi].RECT.left
		.while ecx<=[esi].RECT.right
			push	ecx
			push	edx
			invoke FindCell,ebx,ecx,edx
			pop		edx
			pop		ecx
			.if eax
				.if [eax].COLDTA.fmt.tpe==TPE_EXPANDED
					inc		edi
				.endif
				.if edx!=[esi].RECT.top || ecx!=[esi].RECT.left
					.if [eax].COLDTA.expx || [eax].COLDTA.expy
						inc		edi
					.endif
				.endif
			.endif
			inc		ecx
		.endw
		inc		edx
	.endw
	mov		eax,edi
	ret

TestExpand endp

SheetProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	pt:POINT
	LOCAL	mDC:HDC
	LOCAL	ps:PAINTSTRUCT
	LOCAL	nWin:DWORD
	LOCAL	lf:LOGFONT
	LOCAL	wt:DWORD
	LOCAL	ht:DWORD
	LOCAL	tmp:WORD
	LOCAL	hFile:DWORD
	LOCAL	byteswr:DWORD
	LOCAL	buffer[512]:BYTE
	LOCAL	hCtl:HWND
	LOCAL	hMem:DWORD

	invoke GetWindowLong,hWin,0
	.if eax
		mov		ebx,eax
		invoke GetWinPtr,hWin
		mov		esi,eax
	.elseif uMsg!=WM_CREATE
		jmp		Ex
	.endif
	mov		eax,uMsg
	.if eax==WM_SIZE
		invoke GetWindowLong,hWin,GWL_STYLE
		mov		[ebx].SHEET.winst,eax
		invoke GetClientRect,hWin,addr rect
		mov		eax,[ebx].SHEET.winst
		mov		edx,STATUSHT
		test	eax,SPS_GRIDMODE
		je		@f
		shr		edx,1
	  @@:
		test	eax,SPS_STATUS
		je		@f
		sub		rect.bottom,edx
		jnc		@f
		mov		rect.bottom,edx
	  @@:
		lea		esi,[ebx].SHEET.owin
		xor		ecx,ecx
		.while ecx<WINMAX
			mov		eax,rect.right
			mov		[esi].WIN.rect.right,eax
			mov		eax,rect.bottom
			mov		[esi].WIN.rect.bottom,eax
			mov		edx,esi
			add		edx,sizeof WIN
		  .break .if [edx].WIN.act==-1
			mov		eax,[esi].WIN.rect.top
			.if eax==[edx].WIN.rect.top
				mov		eax,[edx].WIN.rect.left
				mov		[esi].WIN.rect.right,eax
				mov		eax,rect.right
				mov		[edx].WIN.rect.right,eax
			.endif
			mov		eax,[esi].WIN.rect.left
			.if eax==[edx].WIN.rect.left
				mov		eax,[edx].WIN.rect.top
				mov		[esi].WIN.rect.bottom,eax
				mov		eax,rect.bottom
				mov		[edx].WIN.rect.bottom,eax
			.endif
			mov		esi,edx
			inc		ecx
		.endw
		lea		esi,[ebx].SHEET.owin
		xor		ecx,ecx
		.while ecx<WINMAX
		  .break .if [esi].WIN.act==-1
			push	ecx
			mov		eax,[esi].WIN.rect.right
			sub		eax,[esi].WIN.rect.left
			mov		wt,eax
			mov		eax,[esi].WIN.rect.bottom
			sub		eax,[esi].WIN.rect.top
			mov		ht,eax
			invoke MoveWindow,[esi].WIN.hwin,[esi].WIN.rect.left,[esi].WIN.rect.top,wt,ht,FALSE
			pop		ecx
			add		esi,sizeof WIN
			inc		ecx
		.endw
		.if [ebx].SHEET.fedt
			invoke GetClientRect,hWin,addr rect
			mov		eax,rect.bottom
			sub		eax,INPHT
			mov		rect.top,eax
			mov		eax,rect.left
			sub		rect.right,eax
			invoke MoveWindow,[ebx].SHEET.hedt,0,rect.top,rect.right,INPHT,TRUE
		.endif
		invoke InvalidateRect,hWin,NULL,TRUE
	.elseif eax==WM_PAINT
		invoke DrawInput,ebx,esi
;--------------------------------------------------------------------------------
	.elseif eax==SPRM_SPLITTHOR
		invoke CreateHSplit,ebx,esi
		jmp		ExRet
	.elseif eax==SPRM_SPLITTVER
		invoke CreateVSplit,ebx,esi
		jmp		ExRet
	.elseif eax==SPRM_SPLITTCLOSE
		invoke CloseSplit,ebx,esi
		jmp		ExRet
	.elseif eax==SPRM_SPLITTSYNC
		invoke SyncSplitt,ebx,esi,lParam
		jmp		ExRet
	.elseif eax==SPRM_GETSPLITTSTATE
		jmp		ExRet
	.elseif eax==SPRM_GETCELLRECT
		invoke GetRealCellRect,ebx,esi,lParam
		mov		eax,[esi].WIN.hwin
		jmp		ExRet
	.elseif eax==SPRM_GETLOCKCOL
		mov		eax,[esi].WIN.lcol
		jmp		ExRet
	.elseif eax==SPRM_SETLOCKCOL
		mov		eax,lParam
		mov		[esi].WIN.lcol,eax
		.if eax>=[esi].WIN.tcol
			inc		eax
			mov		[esi].WIN.tcol,eax
		.endif
		invoke InvalidateRect,hWin,NULL,TRUE
		jmp		ExRet
	.elseif eax==SPRM_GETLOCKROW
		mov		eax,[esi].WIN.lrow
		jmp		ExRet
	.elseif eax==SPRM_SETLOCKROW
		mov		eax,lParam
		mov		[esi].WIN.lrow,eax
		.if eax>=[esi].WIN.trow
			inc		eax
			mov		[esi].WIN.trow,eax
		.endif
		invoke InvalidateRect,hWin,NULL,TRUE
		jmp		ExRet
	.elseif eax==SPRM_DELETECOL
		invoke UpdateExpanded,ebx,TRUE
		invoke DeleteCol,ebx,wParam
		mov		eax,[ebx].SHEET.winst
		and		eax,SPS_GRIDMODE
		.if !eax
			mov		eax,[ebx].SHEET.gfmt.ncols
			inc		eax
			invoke InsertCol,ebx,eax
		.endif
		invoke UpdateSheetRef,ebx,wParam,0,-1,0
		invoke UpdateExpanded,ebx,FALSE
		invoke InvalidateRect,hWin,NULL,FALSE
		jmp		ExRet
	.elseif eax==SPRM_INSERTCOL
		invoke UpdateExpanded,ebx,TRUE
		mov		eax,[ebx].SHEET.winst
		and		eax,SPS_GRIDMODE
		.if !eax
			mov		eax,[ebx].SHEET.gfmt.ncols
			invoke DeleteCol,ebx,eax
		.endif
		invoke InsertCol,ebx,wParam
		invoke UpdateSheetRef,ebx,wParam,0,1,0
		invoke UpdateExpanded,ebx,FALSE
		invoke InvalidateRect,hWin,NULL,FALSE
		jmp		ExRet
	.elseif eax==SPRM_DELETEROW
		invoke UpdateExpanded,ebx,TRUE
		invoke DeleteRow,ebx,wParam
		mov		eax,[ebx].SHEET.winst
		and		eax,SPS_GRIDMODE
		.if !eax
			mov		eax,[ebx].SHEET.gfmt.nrows
			inc		eax
			invoke InsertRow,ebx,eax
		.endif
		invoke UpdateSheetRef,ebx,0,wParam,0,-1
		invoke UpdateExpanded,ebx,FALSE
		invoke InvalidateRect,hWin,NULL,FALSE
		jmp		ExRet
	.elseif eax==SPRM_INSERTROW
		invoke UpdateExpanded,ebx,TRUE
		mov		eax,[ebx].SHEET.winst
		and		eax,SPS_GRIDMODE
		.if !eax
			mov		eax,[ebx].SHEET.gfmt.nrows
			invoke DeleteRow,ebx,eax
		.endif
		invoke InsertRow,ebx,wParam
		invoke UpdateSheetRef,ebx,0,wParam,0,1
		invoke UpdateExpanded,ebx,FALSE
		invoke InvalidateRect,hWin,NULL,FALSE
		jmp		ExRet
	.elseif eax==SPRM_GETCOLCOUNT
		mov		eax,[ebx].SHEET.gfmt.ncols
		jmp		ExRet
	.elseif eax==SPRM_SETCOLCOUNT
		mov		eax,wParam
		.while eax>[ebx].SHEET.gfmt.ncols
			push	eax
			mov		eax,[ebx].SHEET.gfmt.ncols
			inc		eax
			invoke InsertCol,ebx,eax
			pop		eax
		.endw
		.while eax<[ebx].SHEET.gfmt.ncols
			push	eax
			mov		eax,[ebx].SHEET.gfmt.ncols
			invoke DeleteCol,ebx,eax
			pop		eax
		.endw
		invoke InvalidateRect,hWin,NULL,FALSE
		jmp		ExRet
	.elseif eax==SPRM_GETROWCOUNT
		mov		eax,[ebx].SHEET.gfmt.nrows
		jmp		ExRet
	.elseif eax==SPRM_SETROWCOUNT
		mov		eax,wParam
		.if eax>65500
			mov		eax,65500
		.endif
		.while eax>[ebx].SHEET.gfmt.nrows
			push	eax
			mov		eax,[ebx].SHEET.gfmt.nrows
			inc		eax
			invoke InsertRow,ebx,eax
			pop		eax
		.endw
		.while eax<[ebx].SHEET.gfmt.nrows
			push	eax
			mov		eax,[ebx].SHEET.gfmt.nrows
			invoke DeleteRow,ebx,eax
			pop		eax
		.endw
		invoke InvalidateRect,hWin,NULL,FALSE
		jmp		ExRet
	.elseif eax==SPRM_RECALC
		invoke RecalcSheet,ebx
		invoke InvalidateRect,hWin,NULL,FALSE
		jmp		ExRet
	.elseif eax==SPRM_BLANKCELL
		invoke BlankCell,ebx,wParam,lParam
		invoke InvalidateRect,hWin,NULL,FALSE
		jmp		ExRet
	.elseif eax==SPRM_GETCURRENTWIN
		mov		eax,[ebx].SHEET.nwin
		jmp		ExRet
	.elseif eax==SPRM_SETCURRENTWIN
		push	[ebx].SHEET.nwin
		mov		eax,lParam
		mov		[ebx].SHEET.nwin,eax
		invoke GetWinPtr,hWin
		.if [eax].WIN.act!=-1
			mov		[esi].WIN.act,0
			mov		[eax].WIN.act,1
			invoke SetFocus,[eax].WIN.hwin
			pop		eax
			xor		eax,eax
		.else
			pop	[ebx].SHEET.nwin
			xor		eax,eax
			dec		eax
		.endif
		jmp		ExRet
	.elseif eax==SPRM_GETCURRENTCELL
		mov		edx,[esi].WIN.ccol
		mov		eax,[esi].WIN.crow
		shl		eax,16
		or		eax,edx
		jmp		ExRet
	.elseif eax==SPRM_SETCURRENTCELL
		mov		eax,wParam
		.if eax>[ebx].SHEET.gfmt.ncols
			mov		eax,[ebx].SHEET.gfmt.ncols
		.endif
		mov		[esi].WIN.ccol,eax
		mov		[esi].WIN.mcol,eax
		mov		eax,lParam
		.if eax>[ebx].SHEET.gfmt.nrows
			mov		eax,[ebx].SHEET.gfmt.nrows
		.endif
		mov		[esi].WIN.crow,eax
		mov		[esi].WIN.mrow,eax
		invoke InvalidateRect,hWin,NULL,TRUE
		jmp		ExRet
	.elseif eax==SPRM_GETCELLSTRING
		invoke FindCell,ebx,[esi].WIN.ccol,[esi].WIN.crow
		.if eax
			movzx	edx,[eax].COLDTA.fmt.tpe
			and		edx,TPE_TYPEMASK
			.if edx==TPE_TEXT || edx==TPE_TEXTMULTILINE || edx==TPE_HYPERLINK
				lea		eax,[eax].COLDTA.fmt.tpe[1]
			.elseif edx==TPE_INTEGER
				mov		eax,dword ptr [eax].COLDTA.fmt.tpe[1]
				invoke DwToAscii,eax,offset buff
				mov		eax,offset buff
			.elseif edx==TPE_FLOAT
				invoke FpToAscii,addr [eax].COLDTA.fmt.tpe[1],offset buff,FALSE
				mov		eax,offset buff
			.else
				xor		eax,eax
			.endif
		.endif
		jmp		ExRet
	.elseif eax==SPRM_SETCELLSTRING
		invoke UpdateCell,ebx,[esi].WIN.ccol,[esi].WIN.crow,wParam,lParam,0
		jmp		ExRet
	.elseif eax==SPRM_GETCOLWIDTH
		invoke FindCell,ebx,wParam,0
		.if eax
			mov		ax,word ptr [eax].COLDTA.fmt.tpe[1]
			cwde
		.endif
		jmp		ExRet
	.elseif eax==SPRM_SETCOLWIDTH
		invoke FindCell,ebx,wParam,0
		.if eax
			mov		edx,lParam
			mov		word ptr [eax].COLDTA.fmt.tpe[1],dx
			invoke InvalidateRect,hWin,NULL,TRUE
			xor		eax,eax
		.else
			dec		eax
		.endif
		jmp		ExRet
	.elseif eax==SPRM_GETROWHEIGHT
		invoke FindRow,ebx,wParam
		mov		edx,wParam
		.if dx==[eax].ROWDTA.rown && [eax].ROWDTA.len
			mov		ax,[eax].ROWDTA.rowht
			cwde
		.else
			mov		eax,-1
		.endif
		jmp		ExRet
	.elseif eax==SPRM_SETROWHEIGHT
		invoke FindRow,ebx,wParam
		mov		edx,wParam
		.if dx==[eax].ROWDTA.rown && [eax].ROWDTA.len
			mov		edx,lParam
			mov		[eax].ROWDTA.rowht,dx
			invoke InvalidateRect,hWin,NULL,TRUE
			xor		eax,eax
		.else
			mov		eax,-1
		.endif
		jmp		ExRet
	.elseif eax==SPRM_GETCELLDATA
		mov		eax,lParam
		.if [eax].SPR_ITEM.row<=65000
			invoke GetCellData,ebx,esi,lParam
		.endif
		jmp		ExRet
	.elseif eax==SPRM_SETCELLDATA
		mov		eax,lParam
		.if [eax].SPR_ITEM.row<=65000
			invoke SetCellData,ebx,lParam
			push	eax
			invoke InvalidateRect,hWin,NULL,TRUE
			pop		eax
		.endif
		jmp		ExRet
	.elseif eax==SPRM_GETMULTISEL
		mov		edx,lParam
		mov		eax,[esi].WIN.ccol
		.if eax<=[esi].WIN.mcol
			mov		[edx].RECT.left,eax
			mov		eax,[esi].WIN.mcol
			mov		[edx].RECT.right,eax
		.else
			mov		[edx].RECT.right,eax
			mov		eax,[esi].WIN.mcol
			mov		[edx].RECT.left,eax
		.endif
		mov		eax,[esi].WIN.crow
		.if eax<=[esi].WIN.mrow
			mov		[edx].RECT.top,eax
			mov		eax,[esi].WIN.mrow
			mov		[edx].RECT.bottom,eax
		.else
			mov		[edx].RECT.bottom,eax
			mov		eax,[esi].WIN.mrow
			mov		[edx].RECT.top,eax
		.endif
		mov		eax,[esi].WIN.hwin
		jmp		ExRet
	.elseif eax==SPRM_SETMULTISEL
		mov		edx,lParam
		mov		eax,[edx].RECT.left
		mov		[esi].WIN.ccol,eax
		mov		eax,[edx].RECT.top
		mov		[esi].WIN.crow,eax
		mov		eax,[edx].RECT.right
		mov		[esi].WIN.mcol,eax
		mov		eax,[edx].RECT.bottom
		mov		[esi].WIN.mrow,eax
		invoke InvalidateRect,hWin,NULL,TRUE
		xor		eax,eax
		jmp		ExRet
	.elseif eax==SPRM_GETFONT
		mov		eax,wParam
		mov		edi,lParam
		.if eax<FONTMAX
			mov		ecx,sizeof FONT
			mul		ecx
			lea		esi,[ebx].SHEET.ofont[eax]
			mov		eax,[esi].FONT.hfont
			rep movsb
		.else
			mov		eax,-1
		.endif
		jmp		ExRet
	.elseif eax==SPRM_SETFONT
		mov		eax,wParam
		.if eax<FONTMAX
			mov		edx,sizeof FONT
			mul		edx
			lea		edi,[ebx].SHEET.ofont[eax]
			mov		eax,[edi].FONT.hfont
			.if eax
				invoke DeleteObject,eax
			.endif
			mov		esi,lParam
			mov		ecx,sizeof FONT
			push	edi
			rep movsb
			pop		edi
			invoke MakeFont,edi
			invoke InvalidateRect,hWin,NULL,TRUE
			mov		eax,[edi].FONT.hfont
		.else
			mov		eax,-1
		.endif
		jmp		ExRet
	.elseif eax==SPRM_GETGLOBAL
		mov		edi,lParam
		lea		esi,[ebx].SHEET.gfmt
		mov		ecx,sizeof GLOBAL
		rep movsb
		xor		eax,eax
		jmp		ExRet
	.elseif eax==SPRM_SETGLOBAL
		mov		eax,lParam
		.if [eax].GLOBAL.nrows<1
			mov		[eax].GLOBAL.nrows,1
		.elseif [eax].GLOBAL.nrows>65000
			mov		[eax].GLOBAL.nrows,65000
		.endif
		invoke SendMessage,hWin,SPRM_SETROWCOUNT,[eax].GLOBAL.nrows,0
		mov		eax,lParam
		.if [eax].GLOBAL.ncols<1
			mov		[eax].GLOBAL.ncols,1
		.elseif [eax].GLOBAL.ncols>600
			mov		[eax].GLOBAL.ncols,600
		.endif
		invoke SendMessage,hWin,SPRM_SETCOLCOUNT,[eax].GLOBAL.ncols,0
		mov		esi,lParam
		lea		edi,[ebx].SHEET.gfmt
		mov		ecx,sizeof GLOBAL
		rep movsb
		invoke InvalidateRect,hWin,NULL,TRUE
		xor		eax,eax
		jmp		ExRet
	.elseif eax==SPRM_IMPORTLINE
		test	[ebx].SHEET.winst,SPS_GRIDMODE
		je		@f
		mov		edx,[ebx].SHEET.gfmt.nrows
		inc		edx
		.if edx>65000
			jmp		ExRet
		.endif
		push	edx
		invoke InsertRow,ebx,edx
		pop		edx
		mov		[esi].WIN.crow,edx
	  @@:
		mov		[esi].WIN.ccol,1
		mov		edi,lParam
	  @@:
		invoke GetImpData,addr buffer,edi,wParam
		.if eax
			add		edi,eax
			invoke ConvInt,addr buffer
			.if eax
				invoke UpdateCell,ebx,[esi].WIN.ccol,[esi].WIN.crow,TPE_INTEGER,addr buffer,0
			.else
				invoke UpdateCell,ebx,[esi].WIN.ccol,[esi].WIN.crow,TPE_TEXT,addr buffer,0
			.endif
			inc		[esi].WIN.ccol
			jmp		@b
		.endif
		mov		[esi].WIN.ccol,1
		invoke InvalidateRect,hWin,NULL,TRUE
		jmp		ExRet
	.elseif eax==SPRM_LOADFILE
		invoke CreateFile,lParam,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			invoke SetParent,[ebx].SHEET.hedt,hWin
			invoke DestroyFonts,ebx
			invoke DestroyWindows,ebx
			invoke DestroyRowMem,ebx
			invoke GetFileSize,hFile,NULL
			push	eax
			invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
			mov		hMem,eax
			pop		eax
			mov		edx,eax
			invoke ReadFile,hFile,hMem,edx,addr byteswr,NULL
			invoke CloseHandle,hFile
			mov		esi,hMem
			lea		edi,[ebx].SHEET.gfmt
			mov		ecx,sizeof SHEET-offset SHEET.gfmt-8-32
			rep movsb
			mov		ecx,FONTMAX
			lea		edi,[ebx].SHEET.ofont
			.while ecx
				push	ecx
				mov		eax,[edi].FONT.hfont
				.if eax
					invoke MakeFont,edi
				.endif
				pop		ecx
				add		edi,sizeof FONT
				dec		ecx
			.endw
			mov		ecx,WINMAX
			lea		edi,[ebx].SHEET.owin
			.while ecx
				push	ecx
				.if [edi].WIN.act!=-1
					invoke CreateWin,ebx,edi
				.endif
				pop		ecx
				add		edi,sizeof WIN
				dec		ecx
			.endw
			add		byteswr,esi
			sub		byteswr,(sizeof SHEET-offset SHEET.gfmt-8)
			mov		edi,[ebx].SHEET.lprowmem
			.while esi<byteswr && [esi].ROWDTA.len!=0
				mov		eax,[esi-4].ROWDTA.len
				shr		eax,12
				inc		eax
				shl		eax,12
				push	eax
				invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
				mov		[edi],eax
				pop		ecx
				push	edi
				mov		edi,eax
				mov		[edi].ROWDTA.maxlen,ecx
				mov		ecx,[esi-4].ROWDTA.len
				mov		edx,edi
				lea		edi,[edi+4]
				rep movsb
				add		[edx].ROWDTA.len,4
				pop		edi
				lea		edi,[edi+4]
			.endw
			invoke GlobalFree,hMem
			mov		[ebx].SHEET.lpcol,0
			mov		[ebx].SHEET.lprow,0
			invoke SendMessage,hWin,WM_SIZE,0,0
		.endif
		jmp		ExRet
	.elseif eax==SPRM_SAVEFILE
		invoke CreateFile,lParam,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			lea		esi,[ebx].SHEET.gfmt
			mov		ecx,sizeof SHEET-offset SHEET.gfmt-8-32
			invoke WriteFile,hFile,esi,ecx,addr byteswr,NULL
			mov		esi,[ebx].SHEET.lprowmem
			.while dword ptr [esi]
				mov		edx,[esi]
				push	edx
				sub		[edx].ROWDTA.len,4
				mov		ecx,[edx].ROWDTA.len
				lea		edx,[edx+4]
				invoke WriteFile,hFile,edx,ecx,addr byteswr,NULL
				pop		edx
				add		[edx].ROWDTA.len,4
				lea		esi,[esi+4]
			.endw
			invoke CloseHandle,hFile
		.endif
		jmp		ExRet
	.elseif eax==SPRM_NEWSHEET
		invoke DestroyFonts,ebx
		invoke DestroyWindows,ebx
		invoke DestroyWindow,[ebx].SHEET.hedt
		invoke DestroyRowMem,ebx
		invoke GlobalFree,[ebx].SHEET.lprowmem
		invoke GlobalFree,ebx
		invoke SetWindowLong,hWin,0,0
		invoke SendMessage,hWin,WM_CREATE,0,0
		invoke SendMessage,hWin,WM_SIZE,0,0
		jmp		ExRet
	.elseif eax==SPRM_EXPANDCELL
		invoke TestExpand,ebx,lParam
		.if !eax
			invoke CopyRect,addr rect,lParam
			mov		eax,rect.left
			.if eax>rect.right
				xchg	eax,rect.right
				mov		rect.left,eax
			.endif
			mov		eax,rect.top
			.if eax>rect.bottom
				xchg	eax,rect.bottom
				mov		rect.top,eax
			.endif
			invoke FindCell,ebx,rect.left,rect.top
			.if eax
				mov		edi,eax
				invoke DeleteExpanded,ebx,edi,addr rect
			.else
				invoke MakeNewCell,ebx,rect.left,rect.top
				mov		edi,eax
			.endif
			invoke MakeExpanded,ebx,edi,addr rect
			invoke InvalidateRect,hWin,NULL,TRUE
		.endif
		jmp		ExRet
	.elseif eax==SPRM_GETCELLTYPE
		invoke FindCell,ebx,wParam,lParam
		.if eax
			movzx	eax,[eax].COLDTA.fmt.tpe
		.else
			mov		eax,TPE_EMPTY
		.endif
		jmp		ExRet
	.elseif eax==SPRM_ADJUSTCELLREF
		mov		eax,lParam
		invoke UpdateCellRef,wParam,0,0,[eax].RECT.right,[eax].RECT.bottom
		jmp		ExRet
	.elseif eax==SPRM_CREATECOMBO
		invoke CreateWindowEx,WS_EX_TOOLWINDOW,offset szListBox,NULL,WS_CHILD or WS_BORDER or WS_VSCROLL or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or LBS_HASSTRINGS,0,0,0,0,hWin,NULL,hInstance,0
		mov		hCtl,eax
		invoke SetWindowLong,hCtl,GWL_WNDPROC,offset ComboProc
		mov		OldComboProc,eax
		invoke GlobalAlloc,GMEM_FIXED,sizeof COMBO
		mov		edx,hWin
		mov		[eax].COMBO.howner,edx
		mov		edx,wParam
		.if !edx
			mov		edx,150
		.endif
		mov		[eax].COMBO.height,edx
		invoke SetWindowLong,hCtl,GWL_USERDATA,eax
		invoke GetDesktopWindow
		invoke SetParent,hCtl,eax
		invoke SetWindowLong,hCtl,GWL_STYLE,WS_POPUP or WS_BORDER or WS_VSCROLL or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or LBS_HASSTRINGS
		mov		eax,hCtl
		jmp		ExRet
	.elseif eax==SPRM_SCROLLCELL
		invoke TestCurPos,ebx,esi
		invoke TestSync,esi
		invoke InvalidateRect,[esi].WIN.hwin,NULL,TRUE
		jmp		ExRet
	.elseif eax==SPRM_DELETECELL
		invoke UpdateExpanded,ebx,TRUE
		invoke DeleteCell,ebx,wParam,lParam
		invoke UpdateExpanded,ebx,FALSE
		invoke InvalidateRect,[esi].WIN.hwin,NULL,TRUE
		jmp		ExRet
	.elseif eax==SPRM_GETDATEFORMAT
		lea		eax,[ebx].SHEET.szDateFormat
		jmp		ExRet
	.elseif eax==SPRM_SETDATEFORMAT
		invoke StrCpy,addr [ebx].SHEET.szDateFormat,lParam
		xor		eax,eax
		jmp		ExRet
;--------------------------------------------------------------------------------
	.elseif eax==WM_LBUTTONDOWN
		invoke GetClientRect,hWin,addr rect
		mov		eax,rect.bottom
		sub		eax,INPHT
		mov		rect.top,eax
		mov		eax,lParam
		shr		eax,16
		.if eax>=rect.top
			invoke EditCell,ebx,esi,FALSE,addr rect
		.endif
	.elseif eax==WM_SETFOCUS
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		invoke SetFocus,[esi].WIN.hwin
		invoke InvalidateRect,hWin,NULL,TRUE
		xor		eax,eax
		jmp		ExRet
	.elseif eax==WM_KILLFOCUS
		invoke InvalidateRect,hWin,NULL,TRUE
	.elseif eax==WM_CREATE
		; Initialize the floating point unit.
		mov		tmp,037fh
		fldcw	tmp
		fclex
		invoke InitSheetMem,hWin
		mov		ebx,eax
		invoke GetWindowLong,hWin,GWL_ID
		mov		[ebx].SHEET.nid,eax
		invoke GetParent,hWin
		mov		[ebx].SHEET.howner,eax
		lea		esi,[ebx].SHEET.owin
		invoke CreateWindowEx,NULL,offset szClassNameEdit,NULL,WS_CHILD or WS_BORDER or ES_AUTOHSCROLL or ES_WANTRETURN,0,0,0,0,hWin,0,hInstance,0
		mov		edi,eax
		mov		[ebx].SHEET.hedt,edi
		invoke SetWindowLong,edi,GWL_USERDATA,ebx
		invoke SetWindowLong,edi,GWL_WNDPROC,offset EditProc
		mov		OldEditProc,eax
		invoke GetClientRect,hWin,addr [esi].WIN.rect
		invoke CreateWin,ebx,esi
		invoke SetFocus,eax
		invoke StrCpy,addr [ebx].SHEET.szDateFormat,addr szDefDateFormat
	.elseif eax==WM_DESTROY
		invoke DestroyFonts,ebx
		invoke DestroyRowMem,ebx
		invoke GlobalFree,[ebx].SHEET.lprowmem
		invoke GlobalFree,ebx
		invoke SetWindowLong,hWin,0,0
	.elseif eax==WM_USER+9999
		invoke SendMessage,hWin,SPRM_SETCELLSTRING,TPE_TEXT,addr szToolTip
		xor		eax,eax
		jmp		ExRet
	.endif
  Ex:
	invoke DefWindowProc,hWin,uMsg,wParam,lParam
  ExRet:
	ret

SheetProc endp

;--------------------------------------------------------------------------------

IFDEF DLL
	include SprShtDll.asm
ELSE
	include SprShtLib.asm
ENDIF

