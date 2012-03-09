
.const

IDD_TABTEST		equ 1200
IDC_TAB1		equ 1201

;Misc
IDD_TAB1		equ 1300
IDC_STC7		equ 1301
IDC_STC8		equ 1303
IDC_STC2		equ 1302
IDC_STC9		equ 1304
IDC_STC11		equ 1306
IDC_STC13		equ 1308
IDC_STC15		equ 1311
IDC_STC17		equ 1313
IDC_EDT2		equ 1305
IDC_EDT3		equ 1307

;Column header
IDD_TAB2		equ 1400
IDC_CHK9		equ 1403
IDC_STC16		equ 1404
IDC_STC12		equ 1402
IDC_EDT5		equ 1405
IDC_EDT4		equ 1401
IDC_RBN14		equ 1406
IDC_RBN15		equ 1407
IDC_RBN16		equ 1408
IDC_RBN17		equ 1409
IDC_RBN18		equ 1410
IDC_RBN19		equ 1411
IDC_RBN20		equ 1412
IDC_RBN24		equ 1417
IDC_RBN25		equ 1418
IDC_RBN26		equ 1419
IDC_RBN21		equ 1413
IDC_RBN22		equ 1414
IDC_RBN23		equ 1415

;Row header
IDD_TAB3		equ 1500
IDC_CHK10		equ 1505
IDC_STC10		equ 1501
IDC_STC19		equ 1504
IDC_EDT7		equ 1503
IDC_EDT6		equ 1502
IDC_RBN36		equ 1515
IDC_RBN37		equ 1516
IDC_RBN38		equ 1517
IDC_RBN39		equ 1518
IDC_RBN33		equ 1512
IDC_RBN34		equ 1513
IDC_RBN35		equ 1514
IDC_RBN27		equ 1506
IDC_RBN28		equ 1507
IDC_RBN29		equ 1508
IDC_RBN30		equ 1509
IDC_RBN31		equ 1510
IDC_RBN32		equ 1511

;Window header
IDD_TAB4		equ 1600
IDC_CHK11		equ 1602
IDC_STC20		equ 1601
IDC_STC23		equ 1603
IDC_RBN49		equ 1613
IDC_RBN50		equ 1614
IDC_RBN51		equ 1615
IDC_RBN52		equ 1616
IDC_RBN46		equ 1610
IDC_RBN47		equ 1611
IDC_RBN48		equ 1612
IDC_RBN40		equ 1604
IDC_RBN41		equ 1605
IDC_RBN42		equ 1606
IDC_RBN43		equ 1607
IDC_RBN44		equ 1608
IDC_RBN45		equ 1609

;Cell
IDD_TAB5		equ 1700
IDC_STC24		equ 1701
IDC_STC27		equ 1702
IDC_RBN62		equ 1712
IDC_RBN63		equ 1713
IDC_RBN64		equ 1714
IDC_RBN65		equ 1715
IDC_RBN59		equ 1709
IDC_RBN60		equ 1710
IDC_RBN61		equ 1711
IDC_CHK13		equ 1719
IDC_CHK12		equ 1718
IDC_EDT8		equ 1717
IDC_UDN2		equ 1716
IDC_RBN53		equ 1703
IDC_RBN54		equ 1704
IDC_RBN55		equ 1705
IDC_RBN56		equ 1706
IDC_RBN57		equ 1707
IDC_RBN58		equ 1708

.data

TabTitle1       db "Misc",0
TabTitle2       db "Col Header",0
TabTitle3       db "Row Header",0
TabTitle4       db "Win Header",0
TabTitle5       db "Cells",0

.data?

hTab			dd ?
hTabDlg			dd 5 dup(?)
SelTab			dd ?
fNoUpdate		dd ?

.code

Tab1Proc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SetDlgItemInt,hWin,IDC_EDT2,gfmt.ncols,FALSE
		invoke SetDlgItemInt,hWin,IDC_EDT3,gfmt.nrows,FALSE
	.elseif eax==WM_CTLCOLORSTATIC
		invoke GetWindowLong,lParam,GWL_ID
		.if eax==IDC_STC7
			invoke DeleteObject,hBrTmp
			invoke CreateSolidBrush,gfmt.lockcol
			mov		hBrTmp,eax
			ret
		.elseif eax==IDC_STC8
			invoke DeleteObject,hBrTmp
			invoke CreateSolidBrush,gfmt.bckfocol
			mov		hBrTmp,eax
			ret
		.elseif eax==IDC_STC9
			invoke DeleteObject,hBrTmp
			invoke CreateSolidBrush,gfmt.bcknfcol
			mov		hBrTmp,eax
			ret
		.elseif eax==IDC_STC13
			invoke DeleteObject,hBrTmp
			invoke CreateSolidBrush,gfmt.txtfocol
			mov		hBrTmp,eax
			ret
		.elseif eax==IDC_STC11
			invoke DeleteObject,hBrTmp
			invoke CreateSolidBrush,gfmt.txtnfcol
			mov		hBrTmp,eax
			ret
		.elseif eax==IDC_STC17
			invoke DeleteObject,hBrTmp
			invoke CreateSolidBrush,gfmt.hdrgrdcol
			mov		hBrTmp,eax
			ret
		.elseif eax==IDC_STC15
			invoke DeleteObject,hBrTmp
			invoke CreateSolidBrush,gfmt.grdcol
			mov		hBrTmp,eax
			ret
		.endif
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDC_STC7
				invoke GetColor,hWin,gfmt.lockcol
				.if eax!=-1
					mov		gfmt.lockcol,eax
					invoke InvalidateRect,hWin,0,TRUE
				.endif
			.elseif eax==IDC_STC8
				invoke GetColor,hWin,gfmt.bckfocol
				.if eax!=-1
					mov		gfmt.bckfocol,eax
					invoke InvalidateRect,hWin,0,TRUE
				.endif
			.elseif eax==IDC_STC9
				invoke GetColor,hWin,gfmt.bcknfcol
				.if eax!=-1
					mov		gfmt.bcknfcol,eax
					invoke InvalidateRect,hWin,0,TRUE
				.endif
			.elseif eax==IDC_STC13
				invoke GetColor,hWin,gfmt.txtfocol
				.if eax!=-1
					mov		gfmt.txtfocol,eax
					invoke InvalidateRect,hWin,0,TRUE
				.endif
			.elseif eax==IDC_STC11
				invoke GetColor,hWin,gfmt.txtnfcol
				.if eax!=-1
					mov		gfmt.txtnfcol,eax
					invoke InvalidateRect,hWin,0,TRUE
				.endif
			.elseif eax==IDC_STC17
				invoke GetColor,hWin,gfmt.hdrgrdcol
				.if eax!=-1
					mov		gfmt.hdrgrdcol,eax
					invoke InvalidateRect,hWin,0,TRUE
				.endif
			.elseif eax==IDC_STC15
				invoke GetColor,hWin,gfmt.grdcol
				.if eax!=-1
					mov		gfmt.grdcol,eax
					invoke InvalidateRect,hWin,0,TRUE
				.endif
			.endif
		.elseif edx==EN_CHANGE
			.if eax==IDC_EDT2
				invoke GetDlgItemInt,hWin,IDC_EDT2,NULL,FALSE
				mov		gfmt.ncols,eax
			.elseif eax==IDC_EDT3
				invoke GetDlgItemInt,hWin,IDC_EDT3,NULL,FALSE
				mov		gfmt.nrows,eax
			.endif
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

Tab1Proc endp

Tab2Proc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,gfmt.colhdrbtn
		.if eax
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHK9,eax
		mov		al,gfmt.colhdr.txtal
		and		al,FMTA_XMASK
		.if al==FMTA_AUTO
			invoke CheckRadioButton,hWin,IDC_RBN14,IDC_RBN17,IDC_RBN14
		.elseif al==FMTA_LEFT
			invoke CheckRadioButton,hWin,IDC_RBN14,IDC_RBN17,IDC_RBN15
		.elseif al==FMTA_CENTER
			invoke CheckRadioButton,hWin,IDC_RBN14,IDC_RBN17,IDC_RBN16
		.elseif al==FMTA_RIGHT
			invoke CheckRadioButton,hWin,IDC_RBN14,IDC_RBN17,IDC_RBN17
		.endif
		mov		al,gfmt.colhdr.txtal
		and		al,FMTA_YMASK
		.if al==FMTA_TOP
			invoke CheckRadioButton,hWin,IDC_RBN18,IDC_RBN20,IDC_RBN18
		.elseif al==FMTA_MIDDLE
			invoke CheckRadioButton,hWin,IDC_RBN18,IDC_RBN20,IDC_RBN19
		.elseif al==FMTA_BOTTOM
			invoke CheckRadioButton,hWin,IDC_RBN18,IDC_RBN20,IDC_RBN20
		.endif
		invoke SetDlgItemInt,hWin,IDC_EDT5,gfmt.gcellwt,FALSE
		invoke SetDlgItemInt,hWin,IDC_EDT4,gfmt.ghdrht,FALSE

		mov		al,gfmt.colhdr.imgal
		and		al,FMTA_XMASK
		.if al==FMTA_LEFT
			invoke CheckRadioButton,hWin,IDC_RBN24,IDC_RBN26,IDC_RBN24
		.elseif al==FMTA_CENTER
			invoke CheckRadioButton,hWin,IDC_RBN24,IDC_RBN26,IDC_RBN25
		.elseif al==FMTA_RIGHT
			invoke CheckRadioButton,hWin,IDC_RBN24,IDC_RBN26,IDC_RBN26
		.endif
		mov		al,gfmt.colhdr.imgal
		and		al,FMTA_YMASK
		.if al==FMTA_TOP
			invoke CheckRadioButton,hWin,IDC_RBN21,IDC_RBN23,IDC_RBN21
		.elseif al==FMTA_MIDDLE
			invoke CheckRadioButton,hWin,IDC_RBN21,IDC_RBN23,IDC_RBN22
		.elseif al==FMTA_BOTTOM
			invoke CheckRadioButton,hWin,IDC_RBN21,IDC_RBN23,IDC_RBN23
		.endif
	.elseif eax==WM_CTLCOLORSTATIC
		invoke GetWindowLong,lParam,GWL_ID
		.if eax==IDC_STC16
			invoke DeleteObject,hBrTmp
			invoke CreateSolidBrush,gfmt.colhdr.bckcol
			mov		hBrTmp,eax
			ret
		.elseif eax==IDC_STC12
			invoke DeleteObject,hBrTmp
			invoke CreateSolidBrush,gfmt.colhdr.txtcol
			mov		hBrTmp,eax
			ret
		.endif
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDC_STC16
				invoke GetColor,hWin,gfmt.colhdr.bckcol
				.if eax!=-1
					mov		gfmt.colhdr.bckcol,eax
					invoke InvalidateRect,hWin,0,TRUE
				.endif
			.elseif eax==IDC_STC12
				invoke GetColor,hWin,gfmt.colhdr.txtcol
				.if eax!=-1
					mov		gfmt.colhdr.txtcol,eax
					invoke InvalidateRect,hWin,0,TRUE
				.endif
			.elseif eax==IDC_CHK9
				invoke IsDlgButtonChecked,hWin,IDC_CHK9
				mov		gfmt.colhdrbtn,eax
			.elseif eax==IDC_RBN14
				mov		al,gfmt.colhdr.txtal
				and		al,FMTA_YMASK
				or		al,FMTA_AUTO
				mov		gfmt.colhdr.txtal,al
			.elseif eax==IDC_RBN15
				mov		al,gfmt.colhdr.txtal
				and		al,FMTA_YMASK
				or		al,FMTA_LEFT
				mov		gfmt.colhdr.txtal,al
			.elseif eax==IDC_RBN16
				mov		al,gfmt.colhdr.txtal
				and		al,FMTA_YMASK
				or		al,FMTA_CENTER
				mov		gfmt.colhdr.txtal,al
			.elseif eax==IDC_RBN17
				mov		al,gfmt.colhdr.txtal
				and		al,FMTA_YMASK
				or		al,FMTA_RIGHT
				mov		gfmt.colhdr.txtal,al
			.elseif eax==IDC_RBN18
				mov		al,gfmt.colhdr.txtal
				and		al,FMTA_XMASK
				or		al,FMTA_TOP
				mov		gfmt.colhdr.txtal,al
			.elseif eax==IDC_RBN19
				mov		al,gfmt.colhdr.txtal
				and		al,FMTA_XMASK
				or		al,FMTA_MIDDLE
				mov		gfmt.colhdr.txtal,al
			.elseif eax==IDC_RBN20
				mov		al,gfmt.colhdr.txtal
				and		al,FMTA_XMASK
				or		al,FMTA_BOTTOM
				mov		gfmt.colhdr.txtal,al
			.elseif eax==IDC_RBN24
				mov		al,gfmt.colhdr.imgal
				and		al,FMTA_YMASK
				or		al,FMTA_LEFT
				mov		gfmt.colhdr.imgal,al
			.elseif eax==IDC_RBN25
				mov		al,gfmt.colhdr.imgal
				and		al,FMTA_YMASK
				or		al,FMTA_CENTER
				mov		gfmt.colhdr.imgal,al
			.elseif eax==IDC_RBN26
				mov		al,gfmt.colhdr.imgal
				and		al,FMTA_YMASK
				or		al,FMTA_RIGHT
				mov		gfmt.colhdr.imgal,al
			.elseif eax==IDC_RBN21
				mov		al,gfmt.colhdr.imgal
				and		al,FMTA_XMASK
				or		al,FMTA_TOP
				mov		gfmt.colhdr.imgal,al
			.elseif eax==IDC_RBN22
				mov		al,gfmt.colhdr.imgal
				and		al,FMTA_XMASK
				or		al,FMTA_MIDDLE
				mov		gfmt.colhdr.imgal,al
			.elseif eax==IDC_RBN23
				mov		al,gfmt.colhdr.imgal
				and		al,FMTA_XMASK
				or		al,FMTA_BOTTOM
				mov		gfmt.colhdr.imgal,al
			.endif
		.elseif edx==EN_CHANGE
			.if eax==IDC_EDT5
				invoke GetDlgItemInt,hWin,IDC_EDT5,NULL,FALSE
				mov		gfmt.gcellwt,eax
			.elseif eax==IDC_EDT4
				invoke GetDlgItemInt,hWin,IDC_EDT4,NULL,FALSE
				mov		gfmt.ghdrht,eax
			.endif
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

Tab2Proc endp

Tab3Proc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,gfmt.rowhdrbtn
		.if eax
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHK10,eax
		mov		al,gfmt.rowhdr.txtal
		and		al,FMTA_XMASK
		.if al==FMTA_AUTO
			invoke CheckRadioButton,hWin,IDC_RBN36,IDC_RBN39,IDC_RBN36
		.elseif al==FMTA_LEFT
			invoke CheckRadioButton,hWin,IDC_RBN36,IDC_RBN39,IDC_RBN37
		.elseif al==FMTA_CENTER
			invoke CheckRadioButton,hWin,IDC_RBN36,IDC_RBN39,IDC_RBN38
		.elseif al==FMTA_RIGHT
			invoke CheckRadioButton,hWin,IDC_RBN36,IDC_RBN39,IDC_RBN39
		.endif
		mov		al,gfmt.rowhdr.txtal
		and		al,FMTA_YMASK
		.if al==FMTA_TOP
			invoke CheckRadioButton,hWin,IDC_RBN33,IDC_RBN35,IDC_RBN33
		.elseif al==FMTA_MIDDLE
			invoke CheckRadioButton,hWin,IDC_RBN33,IDC_RBN35,IDC_RBN34
		.elseif al==FMTA_BOTTOM
			invoke CheckRadioButton,hWin,IDC_RBN33,IDC_RBN35,IDC_RBN35
		.endif
		invoke SetDlgItemInt,hWin,IDC_EDT7,gfmt.ghdrwt,FALSE
		invoke SetDlgItemInt,hWin,IDC_EDT6,gfmt.gcellht,FALSE
		mov		al,gfmt.rowhdr.imgal
		and		al,FMTA_XMASK
		.if al==FMTA_LEFT
			invoke CheckRadioButton,hWin,IDC_RBN27,IDC_RBN29,IDC_RBN27
		.elseif al==FMTA_CENTER
			invoke CheckRadioButton,hWin,IDC_RBN27,IDC_RBN29,IDC_RBN28
		.elseif al==FMTA_RIGHT
			invoke CheckRadioButton,hWin,IDC_RBN27,IDC_RBN29,IDC_RBN29
		.endif
		mov		al,gfmt.rowhdr.imgal
		and		al,FMTA_YMASK
		.if al==FMTA_TOP
			invoke CheckRadioButton,hWin,IDC_RBN30,IDC_RBN32,IDC_RBN30
		.elseif al==FMTA_MIDDLE
			invoke CheckRadioButton,hWin,IDC_RBN30,IDC_RBN32,IDC_RBN31
		.elseif al==FMTA_BOTTOM
			invoke CheckRadioButton,hWin,IDC_RBN30,IDC_RBN32,IDC_RBN32
		.endif
	.elseif eax==WM_CTLCOLORSTATIC
		invoke GetWindowLong,lParam,GWL_ID
		.if eax==IDC_STC19
			invoke DeleteObject,hBrTmp
			invoke CreateSolidBrush,gfmt.rowhdr.bckcol
			mov		hBrTmp,eax
			ret
		.elseif eax==IDC_STC10
			invoke DeleteObject,hBrTmp
			invoke CreateSolidBrush,gfmt.rowhdr.txtcol
			mov		hBrTmp,eax
			ret
		.endif
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDC_STC19
				invoke GetColor,hWin,gfmt.rowhdr.bckcol
				.if eax!=-1
					mov		gfmt.rowhdr.bckcol,eax
					invoke InvalidateRect,hWin,0,TRUE
				.endif
			.elseif eax==IDC_STC10
				invoke GetColor,hWin,gfmt.rowhdr.txtcol
				.if eax!=-1
					mov		gfmt.rowhdr.txtcol,eax
					invoke InvalidateRect,hWin,0,TRUE
				.endif
			.elseif eax==IDC_CHK10
				invoke IsDlgButtonChecked,hWin,IDC_CHK10
				mov		gfmt.rowhdrbtn,eax
			.elseif eax==IDC_RBN36
				mov		al,gfmt.rowhdr.txtal
				and		al,FMTA_YMASK
				or		al,FMTA_AUTO
				mov		gfmt.rowhdr.txtal,al
			.elseif eax==IDC_RBN37
				mov		al,gfmt.rowhdr.txtal
				and		al,FMTA_YMASK
				or		al,FMTA_LEFT
				mov		gfmt.rowhdr.txtal,al
			.elseif eax==IDC_RBN38
				mov		al,gfmt.rowhdr.txtal
				and		al,FMTA_YMASK
				or		al,FMTA_CENTER
				mov		gfmt.rowhdr.txtal,al
			.elseif eax==IDC_RBN39
				mov		al,gfmt.rowhdr.txtal
				and		al,FMTA_YMASK
				or		al,FMTA_RIGHT
				mov		gfmt.rowhdr.txtal,al
			.elseif eax==IDC_RBN33
				mov		al,gfmt.rowhdr.txtal
				and		al,FMTA_XMASK
				or		al,FMTA_TOP
				mov		gfmt.rowhdr.txtal,al
			.elseif eax==IDC_RBN34
				mov		al,gfmt.rowhdr.txtal
				and		al,FMTA_XMASK
				or		al,FMTA_MIDDLE
				mov		gfmt.rowhdr.txtal,al
			.elseif eax==IDC_RBN35
				mov		al,gfmt.rowhdr.txtal
				and		al,FMTA_XMASK
				or		al,FMTA_BOTTOM
				mov		gfmt.rowhdr.txtal,al
			.elseif eax==IDC_RBN27
				mov		al,gfmt.rowhdr.imgal
				and		al,FMTA_YMASK
				or		al,FMTA_LEFT
				mov		gfmt.rowhdr.imgal,al
			.elseif eax==IDC_RBN28
				mov		al,gfmt.rowhdr.imgal
				and		al,FMTA_YMASK
				or		al,FMTA_CENTER
				mov		gfmt.rowhdr.imgal,al
			.elseif eax==IDC_RBN29
				mov		al,gfmt.rowhdr.imgal
				and		al,FMTA_YMASK
				or		al,FMTA_RIGHT
				mov		gfmt.rowhdr.imgal,al
			.elseif eax==IDC_RBN30
				mov		al,gfmt.rowhdr.imgal
				and		al,FMTA_XMASK
				or		al,FMTA_TOP
				mov		gfmt.rowhdr.imgal,al
			.elseif eax==IDC_RBN31
				mov		al,gfmt.rowhdr.imgal
				and		al,FMTA_XMASK
				or		al,FMTA_MIDDLE
				mov		gfmt.rowhdr.imgal,al
			.elseif eax==IDC_RBN32
				mov		al,gfmt.rowhdr.imgal
				and		al,FMTA_XMASK
				or		al,FMTA_BOTTOM
				mov		gfmt.rowhdr.imgal,al
			.endif
		.elseif edx==EN_CHANGE
			.if eax==IDC_EDT7
				invoke GetDlgItemInt,hWin,IDC_EDT7,NULL,FALSE
				mov		gfmt.ghdrwt,eax
			.elseif eax==IDC_EDT6
				invoke GetDlgItemInt,hWin,IDC_EDT6,NULL,FALSE
				mov		gfmt.gcellht,eax
			.endif
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

Tab3Proc endp

Tab4Proc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,gfmt.winhdrbtn
		.if eax
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHK11,eax
		mov		al,gfmt.winhdr.txtal
		and		al,FMTA_XMASK
		.if al==FMTA_AUTO
			invoke CheckRadioButton,hWin,IDC_RBN49,IDC_RBN52,IDC_RBN49
		.elseif al==FMTA_LEFT
			invoke CheckRadioButton,hWin,IDC_RBN49,IDC_RBN52,IDC_RBN50
		.elseif al==FMTA_CENTER
			invoke CheckRadioButton,hWin,IDC_RBN49,IDC_RBN52,IDC_RBN51
		.elseif al==FMTA_RIGHT
			invoke CheckRadioButton,hWin,IDC_RBN49,IDC_RBN52,IDC_RBN52
		.endif
		mov		al,gfmt.winhdr.txtal
		and		al,FMTA_YMASK
		.if al==FMTA_TOP
			invoke CheckRadioButton,hWin,IDC_RBN46,IDC_RBN48,IDC_RBN46
		.elseif al==FMTA_MIDDLE
			invoke CheckRadioButton,hWin,IDC_RBN46,IDC_RBN48,IDC_RBN47
		.elseif al==FMTA_BOTTOM
			invoke CheckRadioButton,hWin,IDC_RBN46,IDC_RBN48,IDC_RBN48
		.endif
		mov		al,gfmt.winhdr.imgal
		and		al,FMTA_XMASK
		.if al==FMTA_LEFT
			invoke CheckRadioButton,hWin,IDC_RBN40,IDC_RBN42,IDC_RBN40
		.elseif al==FMTA_CENTER
			invoke CheckRadioButton,hWin,IDC_RBN40,IDC_RBN42,IDC_RBN41
		.elseif al==FMTA_RIGHT
			invoke CheckRadioButton,hWin,IDC_RBN40,IDC_RBN42,IDC_RBN42
		.endif
		mov		al,gfmt.winhdr.imgal
		and		al,FMTA_YMASK
		.if al==FMTA_TOP
			invoke CheckRadioButton,hWin,IDC_RBN43,IDC_RBN45,IDC_RBN43
		.elseif al==FMTA_MIDDLE
			invoke CheckRadioButton,hWin,IDC_RBN43,IDC_RBN45,IDC_RBN44
		.elseif al==FMTA_BOTTOM
			invoke CheckRadioButton,hWin,IDC_RBN43,IDC_RBN45,IDC_RBN45
		.endif
	.elseif eax==WM_CTLCOLORSTATIC
		invoke GetWindowLong,lParam,GWL_ID
		.if eax==IDC_STC23
			invoke DeleteObject,hBrTmp
			invoke CreateSolidBrush,gfmt.winhdr.bckcol
			mov		hBrTmp,eax
			ret
		.elseif eax==IDC_STC20
			invoke DeleteObject,hBrTmp
			invoke CreateSolidBrush,gfmt.winhdr.txtcol
			mov		hBrTmp,eax
			ret
		.endif
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDC_STC23
				invoke GetColor,hWin,gfmt.winhdr.bckcol
				.if eax!=-1
					mov		gfmt.winhdr.bckcol,eax
					invoke InvalidateRect,hWin,0,TRUE
				.endif
			.elseif eax==IDC_STC20
				invoke GetColor,hWin,gfmt.winhdr.txtcol
				.if eax!=-1
					mov		gfmt.winhdr.txtcol,eax
					invoke InvalidateRect,hWin,0,TRUE
				.endif
			.elseif eax==IDC_CHK11
				invoke IsDlgButtonChecked,hWin,IDC_CHK11
				mov		gfmt.winhdrbtn,eax
			.elseif eax==IDC_RBN49
				mov		al,gfmt.winhdr.txtal
				and		al,FMTA_YMASK
				or		al,FMTA_AUTO
				mov		gfmt.winhdr.txtal,al
			.elseif eax==IDC_RBN50
				mov		al,gfmt.winhdr.txtal
				and		al,FMTA_YMASK
				or		al,FMTA_LEFT
				mov		gfmt.winhdr.txtal,al
			.elseif eax==IDC_RBN51
				mov		al,gfmt.winhdr.txtal
				and		al,FMTA_YMASK
				or		al,FMTA_CENTER
				mov		gfmt.winhdr.txtal,al
			.elseif eax==IDC_RBN52
				mov		al,gfmt.winhdr.txtal
				and		al,FMTA_YMASK
				or		al,FMTA_RIGHT
				mov		gfmt.winhdr.txtal,al
			.elseif eax==IDC_RBN46
				mov		al,gfmt.winhdr.txtal
				and		al,FMTA_XMASK
				or		al,FMTA_TOP
				mov		gfmt.winhdr.txtal,al
			.elseif eax==IDC_RBN47
				mov		al,gfmt.winhdr.txtal
				and		al,FMTA_XMASK
				or		al,FMTA_MIDDLE
				mov		gfmt.winhdr.txtal,al
			.elseif eax==IDC_RBN48
				mov		al,gfmt.winhdr.txtal
				and		al,FMTA_XMASK
				or		al,FMTA_BOTTOM
				mov		gfmt.winhdr.txtal,al
			.elseif eax==IDC_RBN40
				mov		al,gfmt.winhdr.imgal
				and		al,FMTA_YMASK
				or		al,FMTA_LEFT
				mov		gfmt.winhdr.imgal,al
			.elseif eax==IDC_RBN41
				mov		al,gfmt.winhdr.imgal
				and		al,FMTA_YMASK
				or		al,FMTA_CENTER
				mov		gfmt.winhdr.imgal,al
			.elseif eax==IDC_RBN42
				mov		al,gfmt.winhdr.imgal
				and		al,FMTA_YMASK
				or		al,FMTA_RIGHT
				mov		gfmt.winhdr.imgal,al
			.elseif eax==IDC_RBN43
				mov		al,gfmt.winhdr.imgal
				and		al,FMTA_XMASK
				or		al,FMTA_TOP
				mov		gfmt.winhdr.imgal,al
			.elseif eax==IDC_RBN44
				mov		al,gfmt.winhdr.imgal
				and		al,FMTA_XMASK
				or		al,FMTA_MIDDLE
				mov		gfmt.winhdr.imgal,al
			.elseif eax==IDC_RBN45
				mov		al,gfmt.winhdr.imgal
				and		al,FMTA_XMASK
				or		al,FMTA_BOTTOM
				mov		gfmt.winhdr.imgal,al
			.endif
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

Tab4Proc endp

SetGState proc hWin:HWND

	movzx	eax,gfmt.cell.txtal
	and		al,FMTD_MASK
	.if al==FMTD_ALL || al==FMTD_SCI
		.if al==FMTD_ALL
			invoke CheckDlgButton,hWin,IDC_CHK13,BST_UNCHECKED
			invoke CheckDlgButton,hWin,IDC_CHK12,BST_CHECKED
		.else
			invoke CheckDlgButton,hWin,IDC_CHK13,BST_CHECKED
			invoke CheckDlgButton,hWin,IDC_CHK12,BST_UNCHECKED
		.endif
		invoke GetDlgItem,hWin,IDC_EDT8
		invoke EnableWindow,eax,FALSE
		invoke GetDlgItem,hWin,IDC_UDN2
		invoke EnableWindow,eax,FALSE
		inc		fNoUpdate
		invoke SetDlgItemInt,hWin,IDC_EDT8,2,FALSE
		dec		fNoUpdate
	.else
		push	eax
		invoke GetDlgItem,hWin,IDC_EDT8
		invoke EnableWindow,eax,TRUE
		invoke GetDlgItem,hWin,IDC_UDN2
		invoke EnableWindow,eax,TRUE
		pop		eax
		inc		fNoUpdate
		invoke SetDlgItemInt,hWin,IDC_EDT8,eax,FALSE
		dec		fNoUpdate
	.endif
	mov		al,gfmt.cell.txtal
	and		al,FMTD_MASK
	mov		edx,BST_UNCHECKED
	.if al==FMTD_ALL
		mov		edx,BST_CHECKED
	.endif
	invoke CheckDlgButton,hWin,IDC_CHK12,edx
	mov		al,gfmt.cell.txtal
	and		al,FMTD_MASK
	mov		edx,BST_UNCHECKED
	.if al==FMTD_SCI
		mov		edx,BST_CHECKED
	.endif
	invoke CheckDlgButton,hWin,IDC_CHK13,edx
	ret

SetGState endp

Tab5Proc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		al,gfmt.cell.txtal
		and		al,FMTA_XMASK
		.if al==FMTA_AUTO
			invoke CheckRadioButton,hWin,IDC_RBN62,IDC_RBN65,IDC_RBN62
		.elseif al==FMTA_LEFT
			invoke CheckRadioButton,hWin,IDC_RBN62,IDC_RBN65,IDC_RBN63
		.elseif al==FMTA_CENTER
			invoke CheckRadioButton,hWin,IDC_RBN62,IDC_RBN65,IDC_RBN64
		.elseif al==FMTA_RIGHT
			invoke CheckRadioButton,hWin,IDC_RBN62,IDC_RBN65,IDC_RBN65
		.endif
		mov		al,gfmt.cell.txtal
		and		al,FMTA_YMASK
		.if al==FMTA_TOP
			invoke CheckRadioButton,hWin,IDC_RBN59,IDC_RBN61,IDC_RBN59
		.elseif al==FMTA_MIDDLE
			invoke CheckRadioButton,hWin,IDC_RBN59,IDC_RBN61,IDC_RBN60
		.elseif al==FMTA_BOTTOM
			invoke CheckRadioButton,hWin,IDC_RBN59,IDC_RBN61,IDC_RBN61
		.endif
		invoke SendDlgItemMessage,hWin,IDC_UDN2,UDM_SETRANGE,0,0000000Ch	;Set range
		invoke SetGState,hWin
		mov		al,gfmt.cell.imgal
		and		al,FMTA_XMASK
		.if al==FMTA_LEFT
			invoke CheckRadioButton,hWin,IDC_RBN53,IDC_RBN55,IDC_RBN53
		.elseif al==FMTA_CENTER
			invoke CheckRadioButton,hWin,IDC_RBN53,IDC_RBN55,IDC_RBN54
		.elseif al==FMTA_RIGHT
			invoke CheckRadioButton,hWin,IDC_RBN53,IDC_RBN55,IDC_RBN55
		.endif
		mov		al,gfmt.cell.imgal
		and		al,FMTA_YMASK
		.if al==FMTA_TOP
			invoke CheckRadioButton,hWin,IDC_RBN56,IDC_RBN58,IDC_RBN56
		.elseif al==FMTA_MIDDLE
			invoke CheckRadioButton,hWin,IDC_RBN56,IDC_RBN58,IDC_RBN57
		.elseif al==FMTA_BOTTOM
			invoke CheckRadioButton,hWin,IDC_RBN56,IDC_RBN58,IDC_RBN58
		.endif
	.elseif eax==WM_CTLCOLORSTATIC
		invoke GetWindowLong,lParam,GWL_ID
		.if eax==IDC_STC27
			invoke DeleteObject,hBrTmp
			invoke CreateSolidBrush,gfmt.cell.bckcol
			mov		hBrTmp,eax
			ret
		.elseif eax==IDC_STC24
			invoke DeleteObject,hBrTmp
			invoke CreateSolidBrush,gfmt.cell.txtcol
			mov		hBrTmp,eax
			ret
		.endif
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDC_STC27
				invoke GetColor,hWin,gfmt.cell.bckcol
				.if eax!=-1
					mov		gfmt.cell.bckcol,eax
					invoke InvalidateRect,hWin,0,TRUE
				.endif
			.elseif eax==IDC_STC24
				invoke GetColor,hWin,gfmt.cell.txtcol
				.if eax!=-1
					mov		gfmt.cell.txtcol,eax
					invoke InvalidateRect,hWin,0,TRUE
				.endif
			.elseif eax==IDC_RBN62
				mov		al,gfmt.cell.txtal
				and		al,FMTA_YMASK or FMTD_MASK
				or		al,FMTA_AUTO
				mov		gfmt.cell.txtal,al
			.elseif eax==IDC_RBN63
				mov		al,gfmt.cell.txtal
				and		al,FMTA_YMASK or FMTD_MASK
				or		al,FMTA_LEFT
				mov		gfmt.cell.txtal,al
			.elseif eax==IDC_RBN64
				mov		al,gfmt.cell.txtal
				and		al,FMTA_YMASK or FMTD_MASK
				or		al,FMTA_CENTER
				mov		gfmt.cell.txtal,al
			.elseif eax==IDC_RBN65
				mov		al,gfmt.cell.txtal
				and		al,FMTA_YMASK or FMTD_MASK
				or		al,FMTA_RIGHT
				mov		gfmt.cell.txtal,al
			.elseif eax==IDC_RBN59
				mov		al,gfmt.cell.txtal
				and		al,FMTA_XMASK or FMTD_MASK
				or		al,FMTA_TOP
				mov		gfmt.cell.txtal,al
			.elseif eax==IDC_RBN60
				mov		al,gfmt.cell.txtal
				and		al,FMTA_XMASK or FMTD_MASK
				or		al,FMTA_MIDDLE
				mov		gfmt.cell.txtal,al
			.elseif eax==IDC_RBN61
				mov		al,gfmt.cell.txtal
				and		al,FMTA_XMASK or FMTD_MASK
				or		al,FMTA_BOTTOM
				mov		gfmt.cell.txtal,al
			.elseif eax==IDC_CHK13
				invoke IsDlgButtonChecked,hWin,IDC_CHK13
				mov		dl,gfmt.cell.txtal
				and		dl,FMTA_MASK
				.if eax
					or		dl,FMTD_SCI
				.else
					or		dl,FMTD_2
				.endif
				mov		gfmt.cell.txtal,dl
				invoke SetGState,hWin
			.elseif eax==IDC_CHK12
				invoke IsDlgButtonChecked,hWin,IDC_CHK12
				mov		dl,gfmt.cell.txtal
				and		dl,FMTA_MASK
				.if eax
					or		dl,FMTD_ALL
				.else
					or		dl,FMTD_2
				.endif
				mov		gfmt.cell.txtal,dl
				invoke SetGState,hWin
			.elseif eax==IDC_RBN53
				mov		al,gfmt.cell.imgal
				and		al,FMTA_YMASK
				or		al,FMTA_LEFT
				mov		gfmt.cell.imgal,al
			.elseif eax==IDC_RBN54
				mov		al,gfmt.cell.imgal
				and		al,FMTA_YMASK
				or		al,FMTA_CENTER
				mov		gfmt.cell.imgal,al
			.elseif eax==IDC_RBN55
				mov		al,gfmt.cell.imgal
				and		al,FMTA_YMASK
				or		al,FMTA_RIGHT
				mov		gfmt.cell.imgal,al
			.elseif eax==IDC_RBN56
				mov		al,gfmt.cell.imgal
				and		al,FMTA_XMASK
				or		al,FMTA_TOP
				mov		gfmt.cell.imgal,al
			.elseif eax==IDC_RBN57
				mov		al,gfmt.cell.imgal
				and		al,FMTA_XMASK
				or		al,FMTA_MIDDLE
				mov		gfmt.cell.imgal,al
			.elseif eax==IDC_RBN58
				mov		al,gfmt.cell.imgal
				and		al,FMTA_XMASK
				or		al,FMTA_BOTTOM
				mov		gfmt.cell.imgal,al
			.endif
		.elseif edx==EN_CHANGE
			.if eax==IDC_EDT8 && !fNoUpdate
				invoke GetDlgItemInt,hWin,IDC_EDT8,NULL,FALSE
				mov		ah,gfmt.cell.txtal
				and		ah,FMTA_MASK
				or		al,ah
				mov		gfmt.cell.txtal,al
			.endif
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

Tab5Proc endp

GlobalFmtProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ts:TCITEM

	mov		eax,uMsg
	.if eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		and		eax,0FFFFh
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,0,0
			.elseif eax==IDOK
				;Set global spread sheet data
				invoke SendMessage,hSht,SPRM_SETGLOBAL,0,offset gfmt
				invoke SendMessage,hWin,WM_CLOSE,0,0
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		mov		eax,lParam
		mov		eax,[eax].NMHDR.code
		.if eax==TCN_SELCHANGE
			;Tab selection
			invoke SendMessage,hTab,TCM_GETCURSEL,0,0
			.if eax!=SelTab
				push	eax
				mov		eax,SelTab
				invoke ShowWindow,[hTabDlg+eax*4],SW_HIDE
				pop		eax
				mov		SelTab,eax
				invoke ShowWindow,[hTabDlg+eax*4],SW_SHOWDEFAULT
			.endif
		.endif
	.elseif eax==WM_INITDIALOG
		;Create a brush
		invoke CreateSolidBrush,0
		mov		hBrTmp,eax
		;Get global spread sheet data
		invoke SendMessage,hSht,SPRM_GETGLOBAL,0,offset gfmt
		mov		fNoUpdate,TRUE
		;Create the tabs
		invoke GetDlgItem,hWin,IDC_TAB1
		mov		hTab,eax
		mov		ts.imask,TCIF_TEXT
;		mov		ts.lpReserved1,0
;		mov		ts.lpReserved2,0
		mov		ts.iImage,-1
		mov		ts.lParam,0
		mov		ts.pszText,offset TabTitle1
		mov		ts.cchTextMax,sizeof TabTitle1
		invoke SendMessage,hTab,TCM_INSERTITEM,0,addr ts
		mov		ts.pszText,offset TabTitle2
		mov		ts.cchTextMax,sizeof TabTitle2
		invoke SendMessage,hTab,TCM_INSERTITEM,1,addr ts
		mov		ts.pszText,offset TabTitle3
		mov		ts.cchTextMax,sizeof TabTitle3
		invoke SendMessage,hTab,TCM_INSERTITEM,2,addr ts
		mov		ts.pszText,offset TabTitle4
		mov		ts.cchTextMax,sizeof TabTitle4
		invoke SendMessage,hTab,TCM_INSERTITEM,3,addr ts
		mov		ts.pszText,offset TabTitle5
		mov		ts.cchTextMax,sizeof TabTitle5
		invoke SendMessage,hTab,TCM_INSERTITEM,4,addr ts
		;Create the tab dialogs
		invoke CreateDialogParam,hInstance,IDD_TAB1,hTab,addr Tab1Proc,0
		mov hTabDlg,eax
		invoke CreateDialogParam,hInstance,IDD_TAB2,hTab,addr Tab2Proc,0
		mov hTabDlg[4],eax
		invoke CreateDialogParam,hInstance,IDD_TAB3,hTab,addr Tab3Proc,0
		mov hTabDlg[8],eax
		invoke CreateDialogParam,hInstance,IDD_TAB4,hTab,addr Tab4Proc,0
		mov hTabDlg[12],eax
		invoke CreateDialogParam,hInstance,IDD_TAB5,hTab,addr Tab5Proc,0
		mov		hTabDlg[16],eax
		mov		SelTab,0
		mov		fNoUpdate,FALSE
	.elseif eax==WM_CLOSE
		invoke DeleteObject,hBrTmp
		mov		hBrTmp,0
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

GlobalFmtProc endp

