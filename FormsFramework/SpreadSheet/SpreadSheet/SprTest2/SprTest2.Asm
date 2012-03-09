.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include SprTest2.inc

.code

start:
	invoke	GetModuleHandle,NULL
	mov	hInstance,eax
	invoke	InitCommonControls
    invoke LoadLibrary,offset szLibName
	.if eax
		mov		hSprShtDLL,eax
		invoke	DialogBoxParam,hInstance,IDD_MAIN,NULL,addr DlgProc,NULL
		invoke FreeLibrary,hSprShtDLL
	.endif
	invoke	ExitProcess,0

;########################################################################

DlgProc	proc	hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	buffer[256]:BYTE
	LOCAL	cbo:COMBOBOX_DATA

	mov	eax,uMsg
	.if	eax==WM_INITDIALOG
		;initialization here
		invoke GetDlgItem,hWin,1001
		mov		hSht,eax

		;Create ComboBox
		invoke SendMessage,hSht,SPRM_CREATECOMBO,80,0
		mov		cbo.hcbo,eax
		;Set ComboBox font
		invoke SendMessage,hWin,WM_GETFONT,0,0
		invoke SendMessage,cbo.hcbo,WM_SETFONT,eax,FALSE
		;Put some data into the ComboBox
		push	esi
		mov		esi,offset cbdata
		.while byte ptr [esi]
			invoke SendMessage,cbo.hcbo,LB_ADDSTRING,0,esi
			invoke lstrlen,esi
			lea		esi,[esi+eax+1]
		.endw
		pop		esi

		;Create expanded cell
		mov		rect.left,2
		mov		rect.top,2
		mov		rect.right,4
		mov		rect.bottom,4
		invoke SendMessage,hSht,SPRM_EXPANDCELL,0,addr rect
		;Create some text cells
		push	esi
		push	edi
		mov		esi,offset szData
		mov		edi,5
		.while byte ptr [esi]
			mov		spri.flag,SPRIF_TYPE or SPRIF_DATA
			mov		spri.col,2
			mov		spri.row,edi
			mov		spri.fmt.tpe,TPE_TEXT
			mov		spri.lpdta,esi
			invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
			invoke lstrlen,esi
			lea		esi,[esi+eax+1]
			inc		edi
		.endw
		pop		edi
		pop		esi
		;Create a date cell
		mov		spri.flag,SPRIF_TYPE or SPRIF_DATA
		mov		spri.col,1
		mov		spri.row,1
		mov		spri.fmt.tpe,TPE_INTEGER or TPE_DATE
		mov		spri.lpdta,offset Date
		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
		;Create a CDate() cell, note the SPRIF_COMPILE
		mov		spri.flag,SPRIF_TYPE or SPRIF_DATA or SPRIF_COMPILE
		mov		spri.col,1
		mov		spri.row,2
		mov		spri.fmt.tpe,TPE_FORMULA
		mov		spri.lpdta,offset szCDate
		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
		;Create a Sum() cell, note the SPRIF_COMPILE
		mov		spri.flag,SPRIF_TYPE or SPRIF_DATA or SPRIF_COMPILE
		mov		spri.col,1
		mov		spri.row,3
		mov		spri.fmt.tpe,TPE_FORMULA
		mov		spri.lpdta,offset szSum
		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
		;CheckBox - Checked
		mov		spri.flag,SPRIF_DATA or SPRIF_TYPE or SPRIF_IMAGEALIGN or SPRIF_TEXTALIGN
		mov		spri.fmt.imgal,FMTA_RIGHT or FMTA_MIDDLE
		mov		spri.fmt.txtal,FMTA_LEFT
		mov		spri.fmt.tpe,TPE_CHECKBOX or TPE_FIXEDSIZE
		;Col 1
		mov		spri.col,1
		;Row 7
		mov		spri.row,7
		;And a pointer to text
		mov		spri.lpdta,offset szCheckChecked
		;Insert the item
		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri

		;ComboBox
		mov		spri.fmt.tpe,TPE_COMBOBOX or TPE_FIXEDSIZE
		;Col 1
		mov		spri.col,1
		;Row 8
		mov		spri.row,8
		;And a pointer to data
		lea		eax,cbo
		mov		spri.lpdta,eax
		;Set the initial combo index
		mov		cbo.ninx,2
		;Insert the item
		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
		;Button
		mov		spri.flag,SPRIF_DATA or SPRIF_TYPE or SPRIF_STATE; or SPRIF_IMAGEALIGN or SPRIF_TEXTALIGN
		mov		spri.fmt.tpe,TPE_BUTTON or TPE_TEXTMULTILINE or TPE_FORCETYPE or TPE_FIXEDSIZE
		;mov		spri.fmt.imgal,FMTA_RIGHT or FMTA_MIDDLE
		;Col 1
		mov		spri.col,1
		;Row 9
		mov		spri.row,9
		mov		spri.state,STATE_LOCKED
		;And a pointer to data
		mov		spri.lpdta,offset szSomeText1
		;Insert the item
		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
		;Hyperlink
		mov		spri.flag,SPRIF_DATA or SPRIF_TYPE
		mov		spri.fmt.tpe,TPE_HYPERLINK or TPE_FORCETYPE
		;Col 1
		mov		spri.col,1
		;Row 10
		mov		spri.row,10
		;And a pointer to text
		mov		spri.lpdta,offset szHyperlink
		;Insert the item
		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
		;Hyperlink
		mov		spri.flag,SPRIF_DATA or SPRIF_TYPE
		mov		spri.fmt.tpe,TPE_HYPERLINK or TPE_FORCETYPE
		;Col 1
		mov		spri.col,1
		;Row 11
		mov		spri.row,11
		;And a pointer to text
		mov		spri.lpdta,offset szHyperlink
		;Insert the item
		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
		;Set column header text
		mov		spri.flag,SPRIF_TEXTALIGN Or SPRIF_DATA Or SPRIF_WIDTH Or SPRIF_HEIGHT
		mov		spri.col,1
		mov		spri.row,0
		mov		spri.fmt.txtal,FMTA_CENTER Or FMTA_MIDDLE
		mov		spri.wt,80
		mov		spri.ht,42
		mov		spri.lpdta,offset szColhdr
		invoke SendMessage,hSht,SPRM_SETCELLDATA,0,addr spri
		;Set row header width
		invoke SendMessage,hSht,SPRM_SETCOLWIDTH,0,30
		;Recalculate the sheet
		invoke SendMessage,hSht,SPRM_RECALC,0,0
		mov	eax,FALSE
		ret
	.elseif	eax==WM_COMMAND
		mov edx,wParam
		movzx eax,dx
		shr edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke SendMessage,hSht,SPRM_GETCELLSTRING,0,0
				.if eax
					invoke MessageBox,hWin,eax,eax,MB_OK
				.else
					invoke MessageBox,hWin,addr szNotExist,addr szLibName,MB_OK
				.endif
			.elseif eax==IDCANCEL
				invoke	SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==1002
				invoke SendMessage,hSht,SPRM_GETCURRENTCELL,0,0
				mov		ecx,eax
				shr		ecx,16
				movzx	eax,ax
				invoke SendMessage,hSht,SPRM_DELETECELL,eax,ecx
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		mov		edx,lParam
		mov		eax,[edx].NMHDR.hwndFrom
		.if eax==hSht
			mov		eax,[edx].NMHDR.code
			.if eax==SPRN_SELCHANGE
				PrintText "SPRN_SELCHANGE"
				mov		eax,[edx].SPR_SELCHANGE.col
				PrintDec eax
				mov		eax,[edx].SPR_SELCHANGE.row
				PrintDec eax
				;Cancel the selection change
				;mov		[edx].SPR_SELCHANGE.fcancel,TRUE
			.elseif eax==SPRN_BEFOREEDIT
				PrintText "SPRN_BEFOREEDIT"
				;Get pointer to SPR_ITEM
				mov		ecx,[edx].SPR_EDIT.lpspri
				;Get the cell type
				movzx	eax,[ecx].SPR_ITEM.fmt.tpe
				.if eax==TPE_HYPERLINK
					;Cancel the edit operation
					;mov		[edx].SPR_EDIT.fcancel,TRUE
				.endif
			.elseif eax==SPRN_HYPERLINKENTER
				PrintText "SPRN_HYPERLINKENTER"
				;Get pointer to SPR_ITEM
				mov		ecx,[edx].SPR_HYPERLINK.lpspri
				;Change the cell text color from the default blue
				mov		[ecx].SPR_ITEM.fmt.txtcol,008000h
			.elseif eax==SPRN_HYPERLINKLEAVE
				PrintText "SPRN_HYPERLINKLEAVE"
			.elseif eax==SPRN_HYPERLINKCLICK
				PrintText "SPRN_HYPERLINKCLICK"
				;Get pointer to SPR_ITEM
				mov		ecx,[edx].SPR_HYPERLINK.lpspri
				;Get pointer to text
				mov		eax,[ecx].SPR_ITEM.lpdta
				invoke ShellExecute,hWin,offset szOpen,eax,NULL,NULL,SW_SHOWDEFAULT
			.elseif eax==SPRN_BUTTONCLICK
				PrintText "SPRN_BUTTONCLICK"
				mov		ecx,[edx].SPR_BUTTON.lpspri
				mov		eax,[ecx].SPR_ITEM.row
				PrintDec eax
				mov		eax,[ecx].SPR_ITEM.col
				PrintDec eax
				mov		eax,[ecx].SPR_ITEM.lpdta
				PrintStringByAddr eax
			.elseif eax==SPRN_BEFOREUPDATE
				PrintText "SPRN_BEFOREUPDATE"
				mov		edx,lParam
				mov		ecx,[edx].SPR_EDIT.lpspri
				;Get the cell type
				movzx	eax,[ecx].SPR_ITEM.fmt.tpe
				PrintHex eax
				and		eax,TPE_TYPEMASK
				.if eax==TPE_COMBOBOX || eax==TPE_CHECKBOX
					mov		eax,[ecx].SPR_ITEM.col
					PrintDec eax
					mov		eax,[ecx].SPR_ITEM.row
					PrintDec eax
					mov		eax,[ecx].SPR_ITEM.lpdta
					mov		eax,[eax]
					PrintHex eax
					;Cancel the edit change
					;mov		[edx].SPR_EDIT.fcancel,TRUE
				.endif
			.elseif eax==SPRN_AFTERUPDATE
				PrintText "SPRN_AFTERUPDATE"
				mov		edx,lParam
				mov		ecx,[edx].SPR_EDIT.lpspri
				;Get the cell type
				movzx	eax,[ecx].SPR_ITEM.fmt.tpe
				and		eax,TPE_TYPEMASK
				.if eax==TPE_COMBOBOX || eax==TPE_CHECKBOX
					mov		eax,[ecx].SPR_ITEM.col
					PrintDec eax
					mov		eax,[ecx].SPR_ITEM.row
					PrintDec eax
					mov		eax,[ecx].SPR_ITEM.lpdta
					mov		eax,[eax]
					PrintHex eax
				.endif
			.endif
		.endif
	.elseif	eax==WM_CLOSE
		invoke	EndDialog,hWin,0
	.else
		mov	eax,FALSE
		ret
	.endif
	mov	eax,TRUE
	ret
DlgProc endp

end start
