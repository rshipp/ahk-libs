
include windows.inc
include kernel32.inc
include user32.inc
include Comctl32.inc
include shell32.inc
include odbc32.inc
include odbccp32.inc

include ..\SpreadSheet.inc


includelib kernel32.lib
includelib user32.lib
includelib Comctl32.lib
includelib shell32.lib
includelib odbc32.lib
includelib odbccp32.lib

;Debug
include masm32.inc
include \RadASM\Masm\Inc\Debug.Inc
includelib masm32.lib
includelib \RadASM\Masm\Lib\Debug.lib

DlgProc				PROTO	:HWND,:UINT,:WPARAM,:LPARAM

IDD_MAIN			equ 101
IDC_SPR1			equ 1001
IDC_BTNCREATE		equ 1002
IDC_BTNOPEN			equ 1003
IDC_BTNADD			equ 1004
IDC_BTNDELETE		equ 1005

.const

szLibName			db 'SprSht.dll',0

szColumns			dd 40
					db 'ID',0
					dd 140
					db 'Last name',0
					dd 140
					db 'First name',0
					dd 140
					db 'Address',0
					dd 80
					db 'Phone',0
					dd 0
					db 0

szExists			db 'Database mydb.mdb already exists.',0
szNotExists			db 'Database mydb.mdb not found.',0
szNotOpen			db 'Database not opened.',0

;#########################################################################

.data?

hInstance			dd ?
hSprShtDLL			dd ?
hWnd				HWND ?
hSpr				HWND ?
spri				SPR_ITEM <>

;#########################################################################
