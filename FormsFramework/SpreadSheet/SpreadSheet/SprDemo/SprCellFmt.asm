
.const

;SprShtCellFmt.dlg

IDC_CHK6			equ 1128
IDC_CHK7			equ 1109
IDC_STC3			equ 1116
IDC_STC4			equ 1117
IDC_STC5			equ 1118
IDC_STC6			equ 1119

IDC_CHK1			equ 1101
IDC_RBN1			equ 1102
IDC_RBN2			equ 1103
IDC_RBN3			equ 1104
IDC_RBN4			equ 1105
IDC_RBN5			equ 1106
IDC_RBN6			equ 1107
IDC_RBN7			equ 1108

IDC_CHK5			equ 1129
IDC_RBN8			equ 1122
IDC_RBN9			equ 1123
IDC_RBN10			equ 1124
IDC_RBN11			equ 1125
IDC_RBN12			equ 1126
IDC_RBN13			equ 1127

IDC_CHK2			equ 1112
IDC_CHK3			equ 1113
IDC_CHK4			equ 1111
IDC_EDT1			equ 1114
IDC_UDN1			equ 1115

;Font
IDC_CHK8			equ 1130
IDC_CBO1			equ 1110
IDC_STC1			equ 1120
IDC_BTN1			equ 1121

;Size
IDC_CHK14			equ 1132
IDC_CHK15			equ 1134
IDC_STC14			equ 1135
IDC_STC18			equ 1136
IDC_EDT9			equ 1131
IDC_EDT10			equ 1133

.data?

bckcol				dd ?
txtcol				dd ?
txtal				db ?
imgal				db ?
decimal				db ?
cwt					dd ?
rht					dd ?

.code

SetCState proc uses ebx esi,hWin:DWORD
	LOCAL	fnt:FONT

	;Back color
	invoke IsDlgButtonChecked,hWin,IDC_CHK6
	xor		eax,1
	mov		ebx,eax
	invoke GetDlgItem,hWin,IDC_STC3
	invoke EnableWindow,eax,ebx
	invoke GetDlgItem,hWin,IDC_STC5
	invoke EnableWindow,eax,ebx
	mov		eax,spri.fmt.bckcol
	.if !ebx || eax==-1
		mov		eax,gfmt.cell.bckcol
	.endif
	mov		bckcol,eax
	;Text color
	invoke IsDlgButtonChecked,hWin,IDC_CHK7
	xor		eax,1
	mov		ebx,eax
	invoke GetDlgItem,hWin,IDC_STC4
	invoke EnableWindow,eax,ebx
	invoke GetDlgItem,hWin,IDC_STC6
	invoke EnableWindow,eax,ebx
	mov		eax,spri.fmt.txtcol
	.if !ebx || eax==-1
		mov		eax,gfmt.cell.txtcol
	.endif
	mov		txtcol,eax
	;Text alignment
	invoke IsDlgButtonChecked,hWin,IDC_CHK1
	xor		eax,1
	mov		ebx,eax
	invoke GetDlgItem,hWin,IDC_RBN1
	invoke EnableWindow,eax,ebx
	invoke GetDlgItem,hWin,IDC_RBN2
	invoke EnableWindow,eax,ebx
	invoke GetDlgItem,hWin,IDC_RBN3
	invoke EnableWindow,eax,ebx
	invoke GetDlgItem,hWin,IDC_RBN4
	invoke EnableWindow,eax,ebx
	invoke GetDlgItem,hWin,IDC_RBN5
	invoke EnableWindow,eax,ebx
	invoke GetDlgItem,hWin,IDC_RBN6
	invoke EnableWindow,eax,ebx
	invoke GetDlgItem,hWin,IDC_RBN7
	invoke EnableWindow,eax,ebx
	mov		al,spri.fmt.txtal
	mov		dl,al
	and		dl,FMTA_MASK
	.if !ebx || dl==FMTA_GLOBAL
		mov		al,gfmt.cell.txtal
	.endif
	and		al,FMTA_MASK
	and		txtal,FMTD_MASK
	or		txtal,al
	and		al,FMTA_XMASK
	.if al==FMTA_AUTO
		invoke CheckRadioButton,hWin,IDC_RBN1,IDC_RBN4,IDC_RBN1
	.elseif al==FMTA_LEFT
		invoke CheckRadioButton,hWin,IDC_RBN1,IDC_RBN4,IDC_RBN2
	.elseif al==FMTA_CENTER
		invoke CheckRadioButton,hWin,IDC_RBN1,IDC_RBN4,IDC_RBN3
	.elseif al==FMTA_RIGHT
		invoke CheckRadioButton,hWin,IDC_RBN1,IDC_RBN4,IDC_RBN4
	.endif
	mov		al,txtal
	and		al,FMTA_YMASK
	.if al==FMTA_TOP
		invoke CheckRadioButton,hWin,IDC_RBN5,IDC_RBN7,IDC_RBN5
	.elseif al==FMTA_MIDDLE
		invoke CheckRadioButton,hWin,IDC_RBN5,IDC_RBN7,IDC_RBN6
	.elseif al==FMTA_BOTTOM
		invoke CheckRadioButton,hWin,IDC_RBN5,IDC_RBN7,IDC_RBN7
	.endif
	;Image alignment
	invoke IsDlgButtonChecked,hWin,IDC_CHK5
	xor		eax,1
	mov		ebx,eax
	invoke GetDlgItem,hWin,IDC_RBN8
	invoke EnableWindow,eax,ebx
	invoke GetDlgItem,hWin,IDC_RBN9
	invoke EnableWindow,eax,ebx
	invoke GetDlgItem,hWin,IDC_RBN10
	invoke EnableWindow,eax,ebx
	invoke GetDlgItem,hWin,IDC_RBN11
	invoke EnableWindow,eax,ebx
	invoke GetDlgItem,hWin,IDC_RBN12
	invoke EnableWindow,eax,ebx
	invoke GetDlgItem,hWin,IDC_RBN13
	invoke EnableWindow,eax,ebx
	mov		al,spri.fmt.imgal
	and		al,FMTA_MASK
	.if !ebx || al==FMTA_GLOBAL
		mov		al,gfmt.cell.imgal
	.endif
	mov		imgal,al
	and		al,FMTA_XMASK
	.if al==FMTA_LEFT
		invoke CheckRadioButton,hWin,IDC_RBN8,IDC_RBN10,IDC_RBN8
	.elseif al==FMTA_CENTER
		invoke CheckRadioButton,hWin,IDC_RBN8,IDC_RBN10,IDC_RBN9
	.elseif al==FMTA_RIGHT
		invoke CheckRadioButton,hWin,IDC_RBN8,IDC_RBN10,IDC_RBN10
	.endif
	mov		al,imgal
	and		al,FMTA_YMASK
	.if al==FMTA_TOP
		invoke CheckRadioButton,hWin,IDC_RBN11,IDC_RBN13,IDC_RBN11
	.elseif al==FMTA_MIDDLE
		invoke CheckRadioButton,hWin,IDC_RBN11,IDC_RBN13,IDC_RBN12
	.elseif al==FMTA_BOTTOM
		invoke CheckRadioButton,hWin,IDC_RBN11,IDC_RBN13,IDC_RBN13
	.endif
	;Decimals
	invoke IsDlgButtonChecked,hWin,IDC_CHK2
	xor		eax,1
	mov		ebx,eax
	invoke GetDlgItem,hWin,IDC_CHK3
	invoke EnableWindow,eax,ebx
	invoke GetDlgItem,hWin,IDC_CHK4
	invoke EnableWindow,eax,ebx
	invoke GetDlgItem,hWin,IDC_EDT1
	invoke EnableWindow,eax,ebx
	invoke GetDlgItem,hWin,IDC_UDN1
	invoke EnableWindow,eax,ebx
	.if ebx
		invoke IsDlgButtonChecked,hWin,IDC_CHK3
		xor		eax,1
		mov		ebx,eax
		invoke GetDlgItem,hWin,IDC_EDT1
		invoke EnableWindow,eax,ebx
		invoke GetDlgItem,hWin,IDC_UDN1
		invoke EnableWindow,eax,ebx
		.if !ebx
			and		txtal,FMTA_MASK
			or		txtal,FMTD_SCI
		.endif
	.endif
	.if ebx
		invoke IsDlgButtonChecked,hWin,IDC_CHK4
		xor		eax,1
		mov		ebx,eax
		invoke GetDlgItem,hWin,IDC_EDT1
		invoke EnableWindow,eax,ebx
		invoke GetDlgItem,hWin,IDC_UDN1
		invoke EnableWindow,eax,ebx
		.if !ebx
			and		txtal,FMTA_MASK
			or		txtal,FMTD_ALL
		.endif
	.endif
	;Font
	invoke IsDlgButtonChecked,hWin,IDC_CHK8
	xor		eax,1
	mov		ebx,eax
	invoke GetDlgItem,hWin,IDC_CBO1
	invoke EnableWindow,eax,ebx
	invoke GetDlgItem,hWin,IDC_BTN1
	invoke EnableWindow,eax,ebx
	movzx	esi,spri.fmt.fnt
	.if !ebx || esi==0FFh
		movzx	esi,gfmt.cell.fnt
	.endif
	invoke SendDlgItemMessage,hWin,IDC_CBO1,CB_SETCURSEL,esi,0
	invoke SendMessage,hSht,SPRM_GETFONT,esi,addr fnt
	mov		eax,fnt.hfont
	invoke SendDlgItemMessage,hWin,IDC_STC1,WM_SETFONT,eax,TRUE
	;Size
	invoke IsDlgButtonChecked,hWin,IDC_CHK14
	xor		eax,1
	mov		ebx,eax
	invoke GetDlgItem,hWin,IDC_STC14
	invoke EnableWindow,eax,ebx
	invoke GetDlgItem,hWin,IDC_EDT9
	invoke EnableWindow,eax,ebx
	mov		eax,cwt
	.if !ebx
		mov		eax,gfmt.gcellwt
	.endif
	invoke SetDlgItemInt,hWin,IDC_EDT9,eax,FALSE
	invoke IsDlgButtonChecked,hWin,IDC_CHK15
	xor		eax,1
	mov		ebx,eax
	invoke GetDlgItem,hWin,IDC_STC18
	invoke EnableWindow,eax,ebx
	invoke GetDlgItem,hWin,IDC_EDT10
	invoke EnableWindow,eax,ebx
	mov		eax,rht
	.if !ebx
		mov		eax,gfmt.gcellht
	.endif
	invoke SetDlgItemInt,hWin,IDC_EDT10,eax,FALSE
	invoke InvalidateRect,hWin,NULL,FALSE
	ret

SetCState endp

InitFonts proc uses ebx,hWin:DWORD
	LOCAL	fnt:FONT
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE

	invoke SendDlgItemMessage,hWin,IDC_CBO1,CB_RESETCONTENT,0,0
	xor		ecx,ecx
	.while ecx<16
		push	ecx
		invoke SendMessage,hSht,SPRM_GETFONT,ecx,addr fnt
		mov		al,fnt.face
		.if al
			invoke lstrcpy,addr buffer,addr fnt.face
			mov		dword ptr buffer1,' ,'
			invoke wsprintfA,addr buffer1[2],offset fmtStr,fnt.fsize
			invoke lstrcat,addr buffer,addr buffer1
			lea		eax,buffer
		.else
			mov		eax,offset szNONE
		.endif
		invoke SendDlgItemMessage,hWin,IDC_CBO1,CB_ADDSTRING,0,eax
		pop		ecx
		inc		ecx
	.endw
	ret

InitFonts endp

GetFont proc hWin:DWORD
	LOCAL	nInx:DWORD
	LOCAL	fnt:FONT
	LOCAL	cf:CHOOSEFONT
	LOCAL	lf:LOGFONT

	invoke RtlZeroMemory,addr cf,sizeof cf
	invoke RtlZeroMemory,addr lf,sizeof lf
	movzx	edx,spri.fmt.fnt
	.if dl==-1
		movzx	edx,gfmt.cell.fnt
	.endif
	invoke SendMessage,hSht,SPRM_GETFONT,edx,addr fnt
	mov		eax,fnt.ht
	mov		lf.lfHeight,eax
	mov		al,fnt.bold
	mov		edx,200
	.if al
		shl		edx,1
	.endif
	mov		lf.lfWeight,edx
	invoke lstrcpy,addr lf.lfFaceName,addr fnt.face
	mov		cf.lStructSize,sizeof cf
	mov		eax,hWin
	mov		cf.hwndOwner,eax
	lea		eax,lf
	mov		cf.lpLogFont,eax
	mov		cf.Flags,CF_SCREENFONTS or CF_INITTOLOGFONTSTRUCT
	invoke ChooseFont,addr cf
	.if eax
		invoke lstrcpy,addr fnt.face,addr lf.lfFaceName
		mov		eax,cf.iPointSize
		xor		edx,edx
		mov		ecx,10
		div		ecx
		mov		fnt.fsize,eax
		mov		eax,lf.lfHeight
		mov		fnt.ht,eax
		mov		eax,lf.lfWeight
		.if eax>=700
			mov		fnt.bold,TRUE
		.endif
		movzx	eax,lf.lfItalic
		mov		fnt.italic,al
		movzx	eax,lf.lfUnderline
		mov		fnt.underline,al
		movzx	eax,lf.lfStrikeOut
		mov		fnt.strikeout,al
		movzx	edx,spri.fmt.fnt
		.if dl==-1
			movzx	edx,gfmt.cell.fnt
		.endif
		invoke SendMessage,hSht,SPRM_SETFONT,edx,addr fnt
		invoke InitFonts,hWin
	.else
		mov		eax,-1
	.endif
	ret

GetFont endp

CellFmtProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		;Create a brush
		invoke CreateSolidBrush,0
		mov		hBrTmp,eax
		;Get global spread sheet data
		invoke SendMessage,hSht,SPRM_GETGLOBAL,0,offset gfmt
		;Get cell data
		lea		ebx,spri
		invoke SendMessage,hSht,SPRM_GETCURRENTCELL,0,0
		mov		edx,eax
		and		eax,0FFFFh
		shr		edx,16
		mov		[ebx].SPR_ITEM.flag,SPRIF_BACKCOLOR or SPRIF_TEXTCOLOR or SPRIF_TEXTALIGN or SPRIF_IMAGEALIGN or SPRIF_FONT or SPRIF_WIDTH or SPRIF_HEIGHT
		mov		[ebx].SPR_ITEM.col,eax
		mov		[ebx].SPR_ITEM.row,edx
		invoke SendMessage,hSht,SPRM_GETCELLDATA,0,ebx
		mov		eax,[ebx].SPR_ITEM.fmt.bckcol
		;Color
		.if eax==-1
			invoke CheckDlgButton,hWin,IDC_CHK6,BST_CHECKED
		.endif
		mov		eax,[ebx].SPR_ITEM.fmt.txtcol
		.if eax==-1
			invoke CheckDlgButton,hWin,IDC_CHK7,BST_CHECKED
		.endif
		;Alignment
		mov		al,[ebx].SPR_ITEM.fmt.txtal
		and		al,FMTA_MASK
		.if al==FMTA_GLOBAL
			invoke CheckDlgButton,hWin,IDC_CHK1,BST_CHECKED
		.endif
		mov		al,[ebx].SPR_ITEM.fmt.imgal
		and		al,FMTA_MASK
		.if al==FMTA_GLOBAL
			invoke CheckDlgButton,hWin,IDC_CHK5,BST_CHECKED
		.endif
		;Decimals
		invoke SendDlgItemMessage,hWin,IDC_UDN1,UDM_SETRANGE,0,0000000Ch	;Set range
		movzx	eax,[ebx].SPR_ITEM.fmt.txtal
		and		al,FMTD_MASK
		.if al==FMTD_GLOBAL
			invoke CheckDlgButton,hWin,IDC_CHK2,BST_CHECKED
			invoke CheckDlgButton,hWin,IDC_CHK3,BST_UNCHECKED
			invoke CheckDlgButton,hWin,IDC_CHK4,BST_UNCHECKED
			movzx	eax,gfmt.cell.txtal
			and		al,FMTD_MASK
		.elseif al==FMTD_SCI
			invoke CheckDlgButton,hWin,IDC_CHK3,BST_CHECKED
			invoke CheckDlgButton,hWin,IDC_CHK4,BST_UNCHECKED
			mov		eax,2
		.elseif al==FMTD_ALL
			invoke CheckDlgButton,hWin,IDC_CHK4,BST_CHECKED
			invoke CheckDlgButton,hWin,IDC_CHK3,BST_UNCHECKED
			mov		eax,2
		.endif
		invoke SendDlgItemMessage,hWin,IDC_UDN1,UDM_SETPOS,0,eax				;Set default value
		;Fonts
		invoke InitFonts,hWin
		mov		al,spri.fmt.fnt
		.if al==-1
			invoke CheckDlgButton,hWin,IDC_CHK8,BST_CHECKED
		.endif
		;Size
		mov		eax,spri.wt
		.if eax==-1
			invoke CheckDlgButton,hWin,IDC_CHK14,BST_CHECKED
			mov		eax,gfmt.gcellwt
		.endif
		mov		cwt,eax
		invoke SetDlgItemInt,hWin,IDC_EDT9,eax,FALSE
		mov		eax,spri.ht
		.if eax==-1
			invoke CheckDlgButton,hWin,IDC_CHK15,BST_CHECKED
			mov		eax,gfmt.gcellht
		.endif
		mov		rht,eax
		invoke SetDlgItemInt,hWin,IDC_EDT10,eax,FALSE
		invoke SetCState,hWin
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDOK
				;Back color
				invoke IsDlgButtonChecked,hWin,IDC_CHK6
				.if eax
					mov		spri.fmt.bckcol,-1
				.endif
				;Text color
				invoke IsDlgButtonChecked,hWin,IDC_CHK7
				.if eax
					mov		spri.fmt.txtcol,-1
				.endif
				;Text alignment
				invoke IsDlgButtonChecked,hWin,IDC_CHK1
				.if eax
					mov		al,FMTA_GLOBAL
				.else
					mov		al,txtal
				.endif
				and			al,FMTA_MASK
				mov		spri.fmt.txtal,al
				;Decimals
				invoke IsDlgButtonChecked,hWin,IDC_CHK2
				.if eax
					mov		al,FMTD_GLOBAL
				.else
					mov		al,txtal
				.endif
				and			al,FMTD_MASK
				and		spri.fmt.txtal,FMTA_MASK
				or		spri.fmt.txtal,al
				;Image alignment
				invoke IsDlgButtonChecked,hWin,IDC_CHK5
				.if eax
					mov		al,FMTA_GLOBAL
				.else
					mov		al,imgal
				.endif
				and			al,FMTA_MASK
				mov		spri.fmt.imgal,al
				;Image list index
				mov		al,imgal
				and		al,FMTD_MASK
				or		spri.fmt.imgal,al
				;Font
				invoke IsDlgButtonChecked,hWin,IDC_CHK8
				.if eax
					mov		spri.fmt.fnt,-1
				.endif
				;Size
				invoke IsDlgButtonChecked,hWin,IDC_CHK14
				.if eax
					mov		spri.wt,-1
				.else
					mov		eax,cwt
					mov		spri.wt,eax
				.endif
				invoke IsDlgButtonChecked,hWin,IDC_CHK15
				.if eax
					mov		spri.ht,-1
				.else
					mov		eax,rht
					mov		spri.ht,eax
				.endif
				invoke SendMessage,hSht,SPRM_GETMULTISEL,0,addr rect
				mov		edx,rect.top
				.while edx<=rect.bottom
					mov		ecx,rect.left
					.while ecx<=rect.right
						push	ecx
						push	edx
						mov		spri.col,ecx
						mov		spri.row,edx
						invoke SendMessage,hSht,SPRM_SETCELLDATA,0,offset spri
						pop		edx
						pop		ecx
						inc		ecx
					.endw
					inc		edx
				.endw
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_CHK6
				invoke SetCState,hWin
			.elseif eax==IDC_CHK7
				invoke SetCState,hWin
			.elseif eax==IDC_STC3
				invoke GetColor,hWin,bckcol
				.if eax!=-1
					mov		spri.fmt.bckcol,eax
					invoke SetCState,hWin
				.endif
			.elseif eax==IDC_STC4
				invoke GetColor,hWin,txtcol
				.if eax!=-1
					mov		spri.fmt.txtcol,eax
					invoke SetCState,hWin
				.endif
			.elseif eax==IDC_CHK1
				invoke SetCState,hWin
			.elseif eax>=IDC_RBN1 && eax<=IDC_RBN4
				sub		eax,IDC_RBN1
				shl		al,4
				mov		dl,txtal
				and		dl,FMTA_YMASK or FMTD_MASK
				or		al,dl
				mov		spri.fmt.txtal,al
				invoke SetCState,hWin
			.elseif eax>=IDC_RBN5 && eax<=IDC_RBN7
				sub		eax,IDC_RBN5
				shl		al,6
				mov		dl,txtal
				and		dl,FMTA_XMASK or FMTD_MASK
				or		al,dl
				mov		spri.fmt.txtal,al
				invoke SetCState,hWin
			.elseif eax==IDC_CHK5
				invoke SetCState,hWin
			.elseif eax==IDC_CHK2
				invoke CheckDlgButton,hWin,IDC_CHK3,BST_UNCHECKED
				invoke CheckDlgButton,hWin,IDC_CHK4,BST_UNCHECKED
				invoke SetCState,hWin
			.elseif eax==IDC_CHK3
				invoke CheckDlgButton,hWin,IDC_CHK4,BST_UNCHECKED
				invoke SetCState,hWin
			.elseif eax==IDC_CHK4
				invoke CheckDlgButton,hWin,IDC_CHK3,BST_UNCHECKED
				invoke SetCState,hWin
			.elseif eax==IDC_CHK8
				invoke SetCState,hWin
			.elseif eax==IDC_BTN1
				invoke GetFont,hWin
				invoke SetCState,hWin
			.elseif eax==IDC_CHK14
				invoke SetCState,hWin
			.elseif eax==IDC_CHK15
				invoke SetCState,hWin
			.endif
		.elseif edx==EN_CHANGE
			.if eax==IDC_EDT9
				invoke IsDlgButtonChecked,hWin,IDC_CHK14
				.if !eax
					invoke GetDlgItemInt,hWin,IDC_EDT9,NULL,FALSE
					mov		cwt,eax
				.endif
			.elseif eax==IDC_EDT10
				invoke IsDlgButtonChecked,hWin,IDC_CHK15
				.if !eax
					invoke GetDlgItemInt,hWin,IDC_EDT10,NULL,FALSE
					mov		rht,eax
				.endif
			.elseif eax==IDC_EDT1
				invoke IsDlgButtonChecked,hWin,IDC_CHK2
				.if !eax
					invoke IsDlgButtonChecked,hWin,IDC_CHK3
					.if !eax
						invoke IsDlgButtonChecked,hWin,IDC_CHK4
						.if !eax
							invoke GetDlgItemInt,hWin,IDC_EDT1,NULL,FALSE
							mov		ah,txtal
							and		ah,FMTA_MASK
							or		al,ah
							mov		txtal,al
						.endif
					.endif
				.endif
			.endif
		.elseif edx==CBN_SELCHANGE
			invoke SendDlgItemMessage,hWin,IDC_CBO1,CB_GETCURSEL,0,0
			mov		spri.fmt.fnt,al
			invoke SetCState,hWin
		.endif
	.elseif eax==WM_CTLCOLORSTATIC
		invoke GetWindowLong,lParam,GWL_ID
		.if eax==IDC_STC3
			invoke DeleteObject,hBrTmp
			invoke CreateSolidBrush,bckcol
			mov		hBrTmp,eax
			ret
		.elseif eax==IDC_STC4
			invoke DeleteObject,hBrTmp
			invoke CreateSolidBrush,txtcol
			mov		hBrTmp,eax
			ret
		.endif
	.elseif eax==WM_CLOSE
		invoke DeleteObject,hBrTmp
		mov		hBrTmp,0
		invoke EndDialog,hWin,NULL
	.else
		mov eax,FALSE
		ret
	.endif
	mov  eax,TRUE
	ret

CellFmtProc endp
