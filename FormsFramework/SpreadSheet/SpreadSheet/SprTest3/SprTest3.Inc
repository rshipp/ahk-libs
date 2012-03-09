
include		windows.inc
include		kernel32.inc
include		user32.inc
include		Comctl32.inc
include		shell32.inc

include ..\SpreadSheet.inc

includelib	kernel32.lib
includelib	user32.lib
includelib	Comctl32.lib
includelib	shell32.lib

include masm32.inc
include \radasm\masm\inc\debug.inc
includelib \radasm\masm\lib\debug.lib

DlgProc			PROTO	:HWND,:UINT,:WPARAM,:LPARAM

.const

szNotExist			db 'Cell does not exist',0
IDD_MAIN			equ 101
szLibName			db 'SprSht.dll',0

szData				db 'One',0
					db 'Two',0
					db 'Three',0
					db 'Four',0
					db 'Five',0
					db 'Six',0
					db 0
szFile				db 'myspr.spr',0

;#########################################################################

.data?

hInstance			dd ?
hSprShtDLL			dd ?
hSht				dd ?
spri				SPR_ITEM <>

;#########################################################################
