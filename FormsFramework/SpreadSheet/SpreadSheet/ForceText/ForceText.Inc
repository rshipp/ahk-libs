
include windows.inc
include kernel32.inc
include user32.inc
include Comctl32.inc
include shell32.inc
include ..\SpreadSheet.inc

includelib kernel32.lib
includelib user32.lib
includelib Comctl32.lib
includelib shell32.lib
includelib ..\sprsht.lib

include \radasm\masm\inc\debug.inc
includelib \radasm\masm\lib\debug.lib

DlgProc			PROTO	:HWND,:UINT,:WPARAM,:LPARAM
GetDef			PROTO	:DWORD

IDD_DIALOG1			equ 101
IDC_SPR1			equ 1001
IDC_LST1			equ 1002

;#########################################################################

.data

szSomeText1			db 'Some text#1',0

.data?

hInstance			dd ?
hSpr				dd ?

;#########################################################################
