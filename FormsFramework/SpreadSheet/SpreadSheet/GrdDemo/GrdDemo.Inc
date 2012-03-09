include windows.inc
include user32.inc
include kernel32.inc
include shell32.inc
include comctl32.inc
include comdlg32.inc
include gdi32.inc

include ..\SpreadSheet.inc

include masm32.inc
include \RadASM\masm\inc\debug.inc

includelib user32.lib
includelib kernel32.lib
includelib shell32.lib
includelib comctl32.lib
includelib comdlg32.lib
includelib gdi32.lib

includelib masm32.lib
includelib \RadASM\masm\lib\debug.lib

WinMain				PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc				PROTO :DWORD,:DWORD,:DWORD,:DWORD

.const

MAXROWS									equ 66000

IDD_DLG1								equ 1000
IDC_SPR1								equ 1001
IDR_MENU								equ 10000

IDM_FILE_EXIT							equ 10001

.data

ClassName			db 'DLGCLASS',0
szLibName			db 'SprSht.dll',0
szClassNameSheet	db 'SPREAD_SHEET',0

szCol1				db 'Name',0
szCol2				db 'Number1',0
szCol3				db 'Number2',0
szCol4				db 'Text1',0
szCol5				db 'Text2',0
szDataLine			db 'This is a test;0;456;abc;def',0

.data?

hInstance			dd ?
CommandLine			dd ?
hSprShtDLL			dd ?
hWnd				dd ?
hSpr				dd ?
