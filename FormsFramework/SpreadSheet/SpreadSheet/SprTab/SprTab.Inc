include windows.inc
include user32.inc
include kernel32.inc
include comctl32.inc


includelib user32.lib
includelib kernel32.lib
includelib comctl32.lib

;Debug macros
;include masm32.inc
;include debug.inc
;includelib masm32.lib
;includelib debug.lib
;
DlgProc			PROTO :DWORD,:DWORD,:DWORD,:DWORD

IDD_TABTEST		equ 1000
IDC_TAB1		equ 1001

IDD_TAB1		equ 2000

IDD_TAB2		equ 3000

IDD_TAB3		equ 4000

.const

szLibName		db 'SprSht.dll',0
TabTitle1       db "Tab1",0
TabTitle2       db "Tab2",0
TabTitle3       db "Tab3",0
TabTitle4       db "Tab4",0

.data?

hInstance		dd ?
hTab			dd ?
hTabDlg			dd 4 dup(?)
SelTab			dd ?
hSprShtDLL		dd ?
