.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include SprTest.inc

.code

start:

	invoke GetModuleHandle,NULL
	mov		hInstance,eax

    invoke InitCommonControls
	invoke SprShtInstall,hInstance
	invoke DialogBoxParam,hInstance,IDD_DIALOG1,NULL,addr DlgProc,NULL
	invoke SprShtUninstall
	invoke ExitProcess,0

;########################################################################

DlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	spri:SPR_ITEM
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		;Get spread sheet window handle
		invoke GetDlgItem,hWin,IDC_SPR1
		mov		hSpr,eax
		invoke SendMessage,hWin,WM_GETFONT,0,0
		invoke SendMessage,hSpr,WM_SETFONT,eax,FALSE
		;Create ComboBox
		invoke SendMessage,hSpr,SPRM_CREATECOMBO,80,0
		mov		hCombo,eax
		;Set ComboBox font
		invoke SendMessage,hWin,WM_GETFONT,0,0
		invoke SendMessage,hCombo,WM_SETFONT,eax,FALSE
		;Put some data into the ComboBox
		push	esi
		mov		esi,offset cbdata
		.while byte ptr [esi]
			invoke SendMessage,hCombo,LB_ADDSTRING,0,esi
			invoke lstrlen,esi
			lea		esi,[esi+eax+1]
		.endw
		pop		esi
;		;Set up an item struct
;		;flag specify valid struct items
;		mov		spri.flag,SPRIF_DATA or SPRIF_TYPE or SPRIF_WIDTH or SPRIF_IMAGEALIGN or SPRIF_TEXTALIGN
;		mov		spri.fmt.imgal,FMTA_LEFT
;		mov		spri.fmt.txtal,FMTA_LEFT
;		;Plain text
;		mov		spri.fmt.tpe,TPE_TEXT
;		;Col 1
;		mov		spri.col,1
;		;Row 1
;		mov		spri.row,1
;		;And a pointer to text
;		mov		spri.lpdta,offset szSomeText1
;		;Width
;		mov		spri.wt,200
;		;Insert the item
;		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
;		;Col 1
;		mov		spri.col,1
;		;Row 2
;		mov		spri.row,2
;		;And a pointer to text
;		mov		spri.lpdta,offset szSomeText2
;		;Insert the item
;		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
;
		;Hyperlink
		mov		spri.flag,SPRIF_DATA or SPRIF_TYPE
		mov		spri.fmt.tpe,TPE_HYPERLINK or TPE_FORCETYPE
		;Col 1
		mov		spri.col,1
		;Row 3
		mov		spri.row,3
		;And a pointer to text
		mov		spri.lpdta,offset szHyperlink
		;Insert the item
		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
		;Hyperlink
		mov		spri.flag,SPRIF_DATA or SPRIF_TYPE
		mov		spri.fmt.tpe,TPE_HYPERLINK or TPE_FORCETYPE
		;Col 1
		mov		spri.col,1
		;Row 3
		mov		spri.row,4
		;And a pointer to text
		mov		spri.lpdta,offset szHyperlink
		;Insert the item
		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
		;Hyperlink
		mov		spri.flag,SPRIF_DATA or SPRIF_TYPE
		mov		spri.fmt.tpe,TPE_HYPERLINK or TPE_FORCETYPE
		;Col 1
		mov		spri.col,1
		;Row 3
		mov		spri.row,5
		;And a pointer to text
		mov		spri.lpdta,offset szHyperlink
		;Insert the item
		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
		;Hyperlink
		mov		spri.flag,SPRIF_DATA or SPRIF_TYPE
		mov		spri.fmt.tpe,TPE_HYPERLINK or TPE_FORCETYPE
		;Col 1
		mov		spri.col,2
		;Row 3
		mov		spri.row,5
		;And a pointer to text
		mov		spri.lpdta,offset szHyperlink
		;Insert the item
		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
;
;		;Button
;		mov		spri.fmt.tpe,TPE_BUTTON or TPE_TEXT
;		;Col 1
;		mov		spri.col,1
;		;Row 4
;		mov		spri.row,4
;		;And a pointer to text
;		mov		spri.lpdta,offset szHyperlink
;		;Insert the item
;		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
;
;		;Wide button
;		mov		spri.fmt.tpe,TPE_WIDEBUTTON or TPE_TEXT
;		;Col 1
;		mov		spri.col,1
;		;Row 5
;		mov		spri.row,5
;		;And a pointer to text
;		mov		spri.lpdta,offset szHyperlink
;		;Insert the item
;		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
;
;		;CheckBox
;		mov		spri.fmt.tpe,TPE_CHECKBOX
;		;Col 1
;		mov		spri.col,1
;		;Row 6
;		mov		spri.row,6
;		;And a pointer to data+text
;		mov		spri.lpdta,offset szCheck
;		;Insert the item
;		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
;
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
		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri

		;ComboBox
		mov		spri.fmt.tpe,TPE_COMBOBOX or TPE_FIXEDSIZE
		;Col 1
		mov		spri.col,1
		;Row 8
		mov		spri.row,8
		;And a pointer to data
		mov		spri.lpdta,offset dtCombo
		;Insert the item
		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri

		;Button
		mov		spri.flag,SPRIF_DATA or SPRIF_TYPE; or SPRIF_IMAGEALIGN or SPRIF_TEXTALIGN
		mov		spri.fmt.tpe,TPE_BUTTON or TPE_TEXTMULTILINE or TPE_FORCETYPE or TPE_FIXEDSIZE
		;mov		spri.fmt.imgal,FMTA_RIGHT or FMTA_MIDDLE
		;Col 1
		mov		spri.col,1
		;Row 9
		mov		spri.row,9
		;And a pointer to data
		mov		spri.lpdta,offset szSomeText1
		;Insert the item
		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
		;Button
		mov		spri.flag,SPRIF_DATA or SPRIF_TYPE; or SPRIF_IMAGEALIGN or SPRIF_TEXTALIGN
		mov		spri.fmt.tpe,TPE_BUTTON or TPE_TEXTMULTILINE or TPE_FORCETYPE or TPE_FIXEDSIZE
		;mov		spri.fmt.imgal,FMTA_RIGHT or FMTA_MIDDLE
		;Col 1
		mov		spri.col,1
		;Row 9
		mov		spri.row,10
		;And a pointer to data
		mov		spri.lpdta,offset szSomeText2
		;Insert the item
		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
;
;		;ComboBox
;		;flag specify valid struct items
;		mov		spri.fmt.tpe,TPE_COMBOBOX
;		mov		spri.fmt.imgal,FMTA_RIGHT
;		mov		spri.fmt.txtal,FMTA_RIGHT
;		;Col 2
;		mov		spri.col,2
;		;Row 8
;		mov		spri.row,8
;		;And a pointer to data
;		mov		spri.lpdta,offset dtCombo
;		;Insert the item
;		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
;
;		;Force text
;		mov		spri.fmt.tpe,TPE_FORCETEXT
;		mov		spri.fmt.imgal,FMTA_AUTO
;		mov		spri.fmt.txtal,FMTA_AUTO
;		;Col 1
;		mov		spri.col,1
;		;Row 9
;		mov		spri.row,9
;		;And a pointer to text
;		mov		spri.lpdta,offset szForcedText
;		;Insert the item
;		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
;
;		;Force text
;		mov		spri.fmt.tpe,TPE_FORCETEXT
;		;Col 1
;		mov		spri.col,1
;		;Row 9
;		mov		spri.row,10
;		;And a pointer to text
;		mov		spri.lpdta,offset szForcedText
;		;Insert the item
;		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
;
;		;Cell ref to CheckBox
;		mov		spri.flag,SPRIF_DATA or SPRIF_TYPE or SPRIF_COMPILE
;		mov		spri.fmt.tpe,TPE_FORMULA
;		;Col 1
;		mov		spri.col,1
;		;Row 11
;		mov		spri.row,11
;		;And a pointer to text
;		mov		spri.lpdta,offset szCellRef1
;		;Insert the item
;		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
;
;		;Cell ref to ComboBox
;		mov		spri.flag,SPRIF_DATA or SPRIF_TYPE or SPRIF_COMPILE
;		mov		spri.fmt.tpe,TPE_FORMULA
;		;Col 1
;		mov		spri.col,1
;		;Row 12
;		mov		spri.row,12
;		;And a pointer to text
;		mov		spri.lpdta,offset szCellRef2
;		;Insert the item
;		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri

		invoke GetTickCount
		push	eax
;		push	ebx
;		push	esi
;		mov		esi,1
;		.while esi<256
;			mov		ebx,1
;			.while ebx<256
;				mov		spri.flag,SPRIF_DATA or SPRIF_TYPE; or SPRIF_COMPILE
;				mov		spri.fmt.tpe,TPE_INTEGER
;				;Col
;				mov		spri.col,ebx
;				;Row
;				mov		spri.row,esi
;				;And a pointer to data
;				mov		spri.lpdta,offset CellData1
;				;Insert the item
;				invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
;				inc		CellData1
;				inc		ebx
;			.endw
;			inc		esi
;		.endw
;		pop		esi
;		pop		ebx
		invoke GetTickCount
		pop		edx
		sub		eax,edx
		mov		CellData1,eax

		mov		spri.flag,SPRIF_DATA or SPRIF_TYPE; or SPRIF_COMPILE
		mov		spri.fmt.tpe,TPE_FLOAT or TPE_FORCETYPE
		;Col
		mov		spri.col,1
		;Row
		mov		spri.row,1
		;And a pointer to data
		mov		spri.lpdta,offset Float1
		;Insert the item
		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri

		mov		spri.flag,SPRIF_DATA or SPRIF_TYPE; or SPRIF_COMPILE
		mov		spri.fmt.tpe,TPE_OWNERDRAWBLOB
		;Col
		mov		spri.col,4
		;Row
		mov		spri.row,2
		;And a pointer to data
		mov		spri.lpdta,offset blob
		;Insert the item
		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri

		mov		spri.flag,SPRIF_DATA or SPRIF_TYPE or SPRIF_HEIGHT; or SPRIF_COMPILE
		mov		spri.fmt.tpe,TPE_OWNERDRAWINTEGER
		mov		spri.ht,48
		;Col
		mov		spri.col,1
		;Row
		mov		spri.row,2
		;And a pointer to data
		mov		spri.lpdta,offset CellData2
		;Insert the item
		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri

		mov		spri.flag,SPRIF_DATA or SPRIF_TYPE; or SPRIF_COMPILE
		mov		spri.fmt.tpe,TPE_OWNERDRAWINTEGER
		;Col
		mov		spri.col,2
		;Row
		mov		spri.row,2
		;And a pointer to data
		mov		spri.lpdta,offset CellData3
		;Insert the item
		invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri

;
;		;Recalculate sheet
;		invoke SendMessage,hSpr,SPRM_RECALC,0,0
;
;		invoke SendMessage,hSpr,SPRM_SETCURRENTCELL,5,20
;		invoke SendMessage,hSpr,SPRM_SCROLLCELL,0,0
;		invoke SendMessage,hSpr,SPRM_SETCURRENTCELL,1,1
;		invoke SendMessage,hSpr,SPRM_SCROLLCELL,0,0

	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,0
	.elseif eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		invoke MoveWindow,hSpr,0,0,rect.right,rect.bottom,TRUE
	.elseif eax==WM_DRAWITEM
		push	ebx
		mov		ebx,lParam
		mov		edx,[ebx].DRAWITEMSTRUCT.itemData
		.if [edx].SPR_ITEM.fmt.tpe==TPE_OWNERDRAWBLOB
			mov		edx,[edx].SPR_ITEM.lpdta
			movzx	eax,word ptr [edx]
			add		edx,2
			invoke TextOut,[ebx].DRAWITEMSTRUCT.hdc,[ebx].DRAWITEMSTRUCT.rcItem.left,[ebx].DRAWITEMSTRUCT.rcItem.top,edx,eax
		.else
			mov		eax,[ebx].DRAWITEMSTRUCT.rcItem.right
			sub		eax,[ebx].DRAWITEMSTRUCT.rcItem.left
			shr		eax,1
			sub		eax,16
			add		[ebx].DRAWITEMSTRUCT.rcItem.left,eax
			mov		eax,[ebx].DRAWITEMSTRUCT.rcItem.bottom
			sub		eax,[ebx].DRAWITEMSTRUCT.rcItem.top
			shr		eax,1
			sub		eax,16
			add		[ebx].DRAWITEMSTRUCT.rcItem.top,eax
			mov		eax,[edx].SPR_ITEM.lpdta
			mov		eax,[eax]
			invoke LoadIcon,hInstance,eax
			push	eax
			invoke DrawIcon,[ebx].DRAWITEMSTRUCT.hdc,[ebx].DRAWITEMSTRUCT.rcItem.left,[ebx].DRAWITEMSTRUCT.rcItem.top,eax
			pop		eax
			invoke DestroyIcon,eax
		.endif
		pop		ebx
	.elseif eax==WM_NOTIFY
		mov		edx,lParam
		mov		eax,[edx].NMHDR.hwndFrom
		.if eax==hSpr
			mov		eax,[edx].NMHDR.code
;.if eax==SPRN_SELCHANGE
;	PrintText "SPRN_SELCHANGE"
;.elseif eax==SPRN_BEFOREEDIT
;	PrintText "SPRN_BEFOREEDIT"
;.elseif eax==SPRN_AFTEREDIT
;	PrintText "SPRN_AFTEREDIT"
;.elseif eax==SPRN_BEFOREUPDATE
;	PrintText "SPRN_BEFOREUPDATE"
;.elseif eax==SPRN_AFTERUPDATE
;	PrintText "SPRN_AFTERUPDATE"
;.endif
			.if eax!=SPRN_SELCHANGE
				mov		ecx,[edx].SPR_EDIT.lpspri
				;Get the cell type
				movzx	eax,[ecx].SPR_ITEM.fmt.tpe
;				.if eax==TPE_COMBOBOX
					mov		eax,[ecx].SPR_ITEM.col
;PrintDec eax
					mov		eax,[ecx].SPR_ITEM.row
;PrintDec eax
;				.endif
			.else
				mov		eax,[edx].SPR_SELCHANGE.col
;PrintDec eax
				mov		eax,[edx].SPR_SELCHANGE.row
;PrintDec eax
			.endif
			mov		eax,[edx].NMHDR.code
			.if eax==SPRN_BEFOREEDIT
				;Get pointer to SPR_ITEM
				mov		ecx,[edx].SPR_EDIT.lpspri
				;Get the cell type
				movzx	eax,[ecx].SPR_ITEM.fmt.tpe
				.if eax==TPE_HYPERLINK
					;Cancel the edit operation
;					mov		[edx].SPR_EDIT.fcancel,TRUE
				.endif
			.elseif eax==SPRN_HYPERLINKENTER
				;Get pointer to SPR_ITEM
				mov		ecx,[edx].SPR_HYPERLINK.lpspri
				;Change the cell text color from the default blue
				mov		[ecx].SPR_ITEM.fmt.txtcol,008000h
			.elseif eax==SPRN_HYPERLINKCLICK
				;Get pointer to SPR_ITEM
				mov		ecx,[edx].SPR_HYPERLINK.lpspri
				;Get pointer to text
				mov		eax,[ecx].SPR_ITEM.lpdta
				invoke ShellExecute,hWin,offset szOpen,eax,NULL,NULL,SW_SHOWDEFAULT
			.elseif eax==SPRN_BUTTONCLICK
				PrintText "Button click"
				mov		ecx,[edx].SPR_BUTTON.lpspri
				mov		eax,[ecx].SPR_ITEM.row
				PrintDec eax
				mov		eax,[ecx].SPR_ITEM.col
				PrintDec eax
				mov		eax,[ecx].SPR_ITEM.lpdta
				PrintStringByAddr eax
			.elseif eax==SPRN_BEFOREUPDATE
;PrintText "SPRN_BEFOREUPDATE"
				mov		edx,lParam
				mov		ecx,[edx].SPR_EDIT.lpspri
				;Get the cell type
				movzx	eax,[ecx].SPR_ITEM.fmt.tpe
				.if eax==TPE_COMBOBOX || eax==TPE_CHECKBOX
					mov		eax,[ecx].SPR_ITEM.col
;PrintDec eax
					mov		eax,[ecx].SPR_ITEM.row
;PrintDec eax
					mov		eax,[ecx].SPR_ITEM.lpdta
					mov		eax,[eax]
;PrintHex eax
				.endif
			.elseif eax==SPRN_AFTERUPDATE
;PrintText "SPRN_AFTERUPDATE"
				mov		edx,lParam
				mov		ecx,[edx].SPR_EDIT.lpspri
				;Get the cell type
				movzx	eax,[ecx].SPR_ITEM.fmt.tpe
				.if eax==TPE_COMBOBOX || eax==TPE_CHECKBOX
					mov		eax,[ecx].SPR_ITEM.col
;PrintDec eax
					mov		eax,[ecx].SPR_ITEM.row
;PrintDec eax
					mov		eax,[ecx].SPR_ITEM.lpdta
					mov		eax,[eax]
;PrintHex eax
				.endif
			.endif
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DlgProc endp

end start
