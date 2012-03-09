
include windows.inc
include kernel32.inc
include user32.inc
include Comctl32.inc
include shell32.inc
include gdi32.inc
include ..\SpreadSheet.inc

includelib kernel32.lib
includelib user32.lib
includelib Comctl32.lib
includelib shell32.lib
includelib gdi32.lib
includelib ..\lib\sprsht.lib

include masm32.inc
include \radasm\masm\inc\debug.inc
includelib \radasm\masm\lib\debug.lib

DlgProc			PROTO	:HWND,:UINT,:WPARAM,:LPARAM
SprShtInstall	PROTO	:HINSTANCE
SprShtUninstall	PROTO

IDD_DIALOG1			equ 101
IDC_SPR1			equ 1001
IDC_LST1			equ 1002

;#########################################################################

.data

szSomeText1			db 'Some text#1',0
szSomeText2			db 'Some text#2',0
szForcedText		db 'Forced text cell',0
szHyperlink			db 'http://www.radasm.com/',0
szCellRef1			db 'AA7',0
szCellRef2			db 'AA8',0
CellData1			dd 1
CellData2			dd 1
CellData3			dd 2
blob				dw 4
				db 'Test'

Float1				tbyte 1.5

szOpen				db 'Open',0

szCheck				dd 0
					db 'CheckBox',0

szCheckChecked		dd 1
					db 'CheckBox',0

dtCombo				dd 1			;index
hCombo				dd 0			;Handle

cbdata				db 'abc',0
					db 'bcd',0
					db 'cde',0
					db 'def',0
					db 'efg',0
					db 'fgh',0,0

.data?

hInstance			dd ?
hSpr				dd ?

;#########################################################################
