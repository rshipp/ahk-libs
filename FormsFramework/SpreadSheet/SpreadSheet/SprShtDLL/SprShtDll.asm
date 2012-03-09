
PROP_STYLETRUEFALSE		equ 1
PROP_EXSTYLETRUEFALSE	equ 2
PROP_STYLEMULTI			equ 3

;Used by RadASM 1.2.0.5
CCDEF struct dword
	ID			dd ?						;Controls uniqe ID
	lptooltip	dd ?						;Pointer to tooltip text
	hbmp		dd ?						;Handle of bitmap
	lpcaption	dd ?						;Pointer to default caption text
	lpname		dd ?						;Pointer to default id-name text
	lpclass		dd ?						;Pointer to class text
	style		dd ?						;Default style
	exstyle		dd ?						;Default ex-style
	flist1		dd ?						;Property listbox 1
	flist2		dd ?						;Property listbox 2
	disable		dd ?						;Disable controls child windows. 0=No, 1=Use method 1, 2=Use method 2
CCDEF ends

;Used by RadASM 2.1.0.4
CCDEFEX struct dword
	ID				dd ?					;Controls uniqe ID
	lptooltip		dd ?					;Pointer to tooltip text
	hbmp			dd ?					;Handle of bitmap
	lpcaption		dd ?					;Pointer to default caption text
	lpname			dd ?					;Pointer to default id-name text
	lpclass			dd ?					;Pointer to class text
	style			dd ?					;Default style
	exstyle			dd ?					;Default ex-style
	flist1			dd ?					;Property listbox 1
	flist2			dd ?					;Property listbox 2
	flist3			dd ?					;Property listbox 3
	flist4			dd ?					;Property listbox 4
	lpproperty		dd ?					;Pointer to properties text to add
	lpmethod		dd ?					;Pointer to property methods
CCDEFEX ends

STYLE				equ WS_CHILD or WS_VISIBLE or SPS_VSCROLL or SPS_HSCROLL or SPS_STATUS or SPS_GRIDLINES or SPS_CELLEDIT
EXSTYLE				equ WS_EX_CLIENTEDGE

.const

szCap				db 0
szName				db 'IDC_SPR',0

.data

szProperty			db 'ScrollBar,Status,GridLines,RowSelect,GridMode,CellEdit,ColSize,RowSize,WinSize,MultiSelect',0
PropertyScrollBar	db 'None,Horizontal,Vertical,Both',0
					dd -1 xor (SPS_HSCROLL or SPS_VSCROLL),0
					dd -1,0
					dd -1 xor (SPS_HSCROLL or SPS_VSCROLL),SPS_HSCROLL
					dd -1,0
					dd -1 xor (SPS_HSCROLL or SPS_VSCROLL),SPS_VSCROLL
					dd -1,0
					dd -1 xor (SPS_HSCROLL or SPS_VSCROLL),SPS_HSCROLL or SPS_VSCROLL
					dd -1,0
PropertyStatus		dd -1 xor SPS_STATUS,0
					dd -1 xor SPS_STATUS,SPS_STATUS
PropertyGridLines	dd -1 xor SPS_GRIDLINES,0
					dd -1 xor SPS_GRIDLINES,SPS_GRIDLINES
PropertyRowSelect	dd -1 xor SPS_ROWSELECT,0
					dd -1 xor SPS_ROWSELECT,SPS_ROWSELECT
PropertyGridMode	dd -1 xor SPS_GRIDMODE,0
					dd -1 xor SPS_GRIDMODE,SPS_GRIDMODE
PropertyCellEdit	dd -1 xor SPS_CELLEDIT,0
					dd -1 xor SPS_CELLEDIT,SPS_CELLEDIT
PropertyColSize		dd -1 xor SPS_COLSIZE,0
					dd -1 xor SPS_COLSIZE,SPS_COLSIZE
PropertyRowSize		dd -1 xor SPS_ROWSIZE,0
					dd -1 xor SPS_ROWSIZE,SPS_ROWSIZE
PropertyWinSize		dd -1 xor SPS_WINSIZE,0
					dd -1 xor SPS_WINSIZE,SPS_WINSIZE
PropertyMultiSelect	dd -1 xor SPS_MULTISELECT,0
					dd -1 xor SPS_MULTISELECT,SPS_MULTISELECT

Methods				dd PROP_STYLEMULTI,offset PropertyScrollBar
					dd PROP_STYLETRUEFALSE,offset PropertyStatus
					dd PROP_STYLETRUEFALSE,offset PropertyGridLines
					dd PROP_STYLETRUEFALSE,offset PropertyRowSelect
					dd PROP_STYLETRUEFALSE,offset PropertyGridMode
					dd PROP_STYLETRUEFALSE,offset PropertyCellEdit
					dd PROP_STYLETRUEFALSE,offset PropertyColSize
					dd PROP_STYLETRUEFALSE,offset PropertyRowSize
					dd PROP_STYLETRUEFALSE,offset PropertyWinSize
					dd PROP_STYLETRUEFALSE,offset PropertyMultiSelect

ccdef				CCDEF <256,offset szToolTip,0,offset szCap,offset szName,offset szClassNameSheet,STYLE,EXSTYLE,11111101000111000000000001000000b,00010000000000011000000000000000b,1>
ccdefex				CCDEFEX <256,offset szToolTip,0,offset szCap,offset szName,offset szClassNameSheet,STYLE,EXSTYLE,11111101000111000000000001000000b,00010000000000011000000000000000b,0,0,offset szProperty,offset Methods>

.code

DllEntry proc public hInst:HINSTANCE, reason:DWORD, reserved1:DWORD

	.if reason==DLL_PROCESS_ATTACH
		invoke SprShtInstall,hInst
	.elseif reason==DLL_PROCESS_DETACH
		invoke SprShtUninstall
	.endif
    mov     eax,TRUE
    ret

DllEntry Endp

;NOTE: RadASM 1.2.0.5 uses this method.
;In RadASM.ini section [CustCtrl], x=CustCtrl.dll,y
;x is next free number.
;y is number of controls in the dll. In this case there is only one control.
;
;x=SprSht.dll,1
;Copy SprSht.dll to c:\windows\system
;
GetDef proc public nInx:DWORD

	mov		eax,nInx
	.if !eax
		;Get the toolbox bitmap
		invoke LoadBitmap,hInstance,IDB_BMP
		mov		ccdef.hbmp,eax
		;Return pointer to inited struct
		mov		eax,offset ccdef
	.else
		xor		eax,eax
	.endif
	ret

GetDef endp

GetDefEx proc public nInx:DWORD

	mov		eax,nInx
	.if !eax
		;Get the toolbox bitmap
		invoke LoadBitmap,hInstance,IDB_BMP
		mov		ccdefex.hbmp,eax
		;Return pointer to inited struct
		mov		eax,offset ccdefex
	.else
		xor		eax,eax
	.endif
	ret

GetDefEx endp

ENDIF

End DllEntry
