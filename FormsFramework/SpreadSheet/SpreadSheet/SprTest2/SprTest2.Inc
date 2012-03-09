
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

szNotExist			db 'Cell does not exist,',0Dh,0Ah,'is empty or of wrong type.',0
IDD_MAIN			equ 101
szLibName			db 'SprSht.dll',0

szData				db 'One',0
					db 'Two',0
					db 'Three',0
					db 'Four',0
					db 'Five',0
					db 'Six',0
					db 0
Date				dd 1000
szCDate				db 'CDate("2008-04-04")',0
szSum				db 'Sum(AA1:AB1)',0

szCheckChecked		dd 1
					db 'CheckBox',0

szOpen				db 'Open',0

cbdata				db 'abc',0
					db 'bcd',0
					db 'cde',0
					db 'def',0
					db 'efg',0
					db 'fgh',0,0

szSomeText1			db 'Some text#1',0
szHyperlink			db 'http://www.radasm.com/',0
szColhdr			db 'This is a multiline column header test.',0

;#########################################################################

.data?

hInstance			dd ?
hSprShtDLL			dd ?
hSht				dd ?
spri				SPR_ITEM <>

;#########################################################################
