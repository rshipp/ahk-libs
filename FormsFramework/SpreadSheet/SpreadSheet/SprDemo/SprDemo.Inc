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
include \RadASM\masm\inc\radbg.inc

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

IDD_DLG1								equ 1000
IDC_SPR1								equ 1001
IDR_MENU								equ 10000

;SprSht.mnu
IDM_FILE_OPEN							equ 10001
IDM_FILE_SAVE							equ 10002
IDM_FILE_SAVE_AS						equ 10003
IDM_FILE_NEW							equ 10039
IDM_FILE_EXIT							equ 10004

IDM_EDIT_CUT							equ 10005
IDM_EDIT_COPY							equ 10006
IDM_EDIT_PASTE							equ 10007
IDM_EDIT_DELETE_ROW						equ 10008
IDM_EDIT_DELETE_COL						equ 10035
IDM_EDIT_INSERT_ROW						equ 10009
IDM_EDIT_INSERT_COL						equ 10010
IDM_EDIT_COPY_CELL						equ 10019
IDM_EDIT_BLANK_CELLS					equ 10037
IDM_EDIT_EXPAND_CELL					equ 10038

IDM_FORMAT_GLOBAL						equ 10011
IDM_FORMAT_CELLS						equ 10012
IDM_FORMAT_LOCK_YES						equ 10020
IDM_FORMAT_LOCK_NO						equ 10040
IDM_FORMAT_HIDE_YES						equ 10041
IDM_FORMAT_HIDE_NO						equ 10042

IDM_WINDOW_SPLIT_HOR					equ 10014
IDM_WINDOW_SPLIT_VER					equ 10015
IDM_WINDOW_CLOSE_SPLITT					equ 10016
IDM_WINDOW_SPLITT_SYNC_YES				equ 10021
IDM_WINDOW_SPLITT_SYNC_NO				equ 10030
IDM_WINDOW_LOCK_ROW_YES					equ 10017
IDM_WINDOW_LOCK_ROW_NO					equ 10031
IDM_WINDOW_LOCK_COL_YES					equ 10018
IDM_WINDOW_LOCK_COL_NO					equ 10032
IDM_WINDOW_HEAD_COL_YES					equ 10023
IDM_WINDOW_HEAD_COL_NO					equ 10024
IDM_WINDOW_HEAD_ROW_YES					equ 10033
IDM_WINDOW_HEAD_ROW_NO					equ 10034

IDM_STYLE_VSCROLL						equ 10025
IDM_STYLE_HSCROLL						equ 10026
IDM_STYLE_STATUS						equ 10027
IDM_STYLE_GRID							equ 10028
IDM_STYLE_ROWSEL						equ 10029
IDM_STYLE_CELLEDIT						equ 10013
IDM_STYLE_GRIDMODE						equ 10036
IDM_STYLE_COLSIZE						equ 10043
IDM_STYLE_ROWSIZE						equ 10044
IDM_STYLE_WINSIZE						equ 10045
IDM_STYLE_MULTISEL						equ 10046

IDM_HELP_ABOUT							equ 10022

.data

ClassName			db 'DLGCLASS',0
AppName				db 'Spread Sheet Demo',0
AboutMsg			db 'RadASM Spread Sheet Demo',13,10,'Copyright © KetilO 2002-2007',0
szLibName			db 'SprSht.dll',0
fmtStr				db '%lu',0

szNONE				db '(None)',0

szCellText			db 'Color',0
szCellTextMultiLine	db 'This is a test of multiline text.',0
szCellTextAlign		db 'Align',0
szCellTextFont		db 'Font',0

szTahoma			db 'Tahoma',0
szAutoLoad			db 'Test2.spr',0

szFilter			db 'Spread Sheet (*.spr)',0,'*.spr',0,0
szSprExt			db 'spr',0

ddCellInteger		dd 12345
dtCellFloat			dt 1.2345
szCellFormula1		db '(AA6+AA7+2)*3',0
szCellFormula2		db 'Sin(Rad(45))',0
szCellGraph			db 'Grp(T(-1,0,0,Rgb(0,0,0),"Graph Demo"),X(0,PI()*4,0,1,Rgb(0,0,255),1,"x-axis"),Y(-1.1,1.1,0,0.5,Rgb(255,0,0),1,"y-axis"),gx(AJ1:AJ13,Rgb(0,0,0),"Cell values"),fx(Sin(x()),0.1,Rgb(255,0,255),"Sin(x)"),fx(x()^3-x()^2-x(),0.1,Rgb(0,128,0),"x^3-x^2-x"))',0

dtAJ1				dt -0.9
					dt 0.2
					dt 0.5
					dt 0.1
					dt 0.7
					dt 0.4
					dt -0.2
					dt 0.1
					dt 0.9
					dt 0.2
					dt 0.4
					dt 0.8
					dt -0.1

.data?

hInstance			dd ?
CommandLine			dd ?
hWnd				dd ?
hSprShtDLL			dd ?
hSht				dd ?
hBrTmp				dd ?
gfmt				GLOBAL <>
spri				SPR_ITEM <>
CustColors			dd 16 dup(?)
ofn					OPENFILENAME <>
FileName			db MAX_PATH dup(?)
AltFileName			db MAX_PATH dup(?)
localdata			db 4096 dup(?)
