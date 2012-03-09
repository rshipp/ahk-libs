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

CreateClass				PROTO
DrawCell				PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
Compile					PROTO :DWORD,:DWORD,:DWORD
FindCell				PROTO :DWORD,:DWORD,:DWORD
IsDate					PROTO :DWORD,:DWORD

IDB_BMP					equ 100
IDR_HSPLIT				equ	101
IDR_VSPLIT				equ 102

TPE_CELLREF				equ 080h			;Cell reference, internaly used
TPE_AREAREF				equ 081h			;Area reference, internaly used
TPE_SUMFUNCTION			equ 082h			;Function 'Sum(', internaly used
TPE_CNTFUNCTION			equ 083h			;Function 'Cnt(', internaly used
TPE_AVGFUNCTION			equ 084h			;Function 'Avg(', internaly used
TPE_MINFUNCTION			equ 085h			;Function 'Min(', internaly used
TPE_MAXFUNCTION			equ 086h			;Function 'Max(', internaly used
TPE_VARFUNCTION			equ 087h			;Function 'Var(', internaly used
TPE_STDFUNCTION			equ 088h			;Function 'Std(', internaly used
TPE_SQTFUNCTION			equ 089h			;Function 'Sqt(', internaly used
TPE_SINFUNCTION			equ 08Ah			;Function 'Sin(', internaly used
TPE_COSFUNCTION			equ 08Bh			;Function 'Cos(', internaly used
TPE_TANFUNCTION			equ 08Ch			;Function 'Tan(', internaly used
TPE_RADFUNCTION			equ 08Dh			;Function 'Rad(', internaly used
TPE_PIFUNCTION			equ 08Eh			;Function 'PI()', internaly used
TPE_IIFFUNCTION			equ 08Fh			;Function 'IIf(', internaly used
TPE_ONFUNCTION			equ 090h			;Function 'On(', internaly used
TPE_ABSFUNCTION			equ 091h			;Function 'Abs(', internaly used
TPE_SGNFUNCTION			equ 092h			;Function 'Sgn(', internaly used
TPE_INTFUNCTION			equ 093h			;Function 'Int(', internaly used
TPE_LOGFUNCTION			equ 094h			;Function 'Log(', internaly used
TPE_LNFUNCTION			equ 095h			;Function 'Ln(', internaly used
TPE_EFUNCTION			equ 096h			;Function 'e()', internaly used
TPE_ASINFUNCTION		equ 097h			;Function 'Asin()', internaly used
TPE_ACOSFUNCTION		equ 098h			;Function 'Acos()', internaly used
TPE_ATANFUNCTION		equ 099h			;Function 'Atan()', internaly used
TPE_GRDFUNCTION			equ 09Ah			;Function 'Grd(', internaly used
TPE_RGBFUNCTION			equ 09Bh			;Function 'Rgb(', internaly used
TPE_XFUNCTION			equ 09Ch			;Function 'x()', internaly used
TPE_RELCELLREF			equ 09Dh			;Relative cell reference, internaly used
TPE_CDATEFUNCTION		equ 09Eh			;Function 'CDate()', internally used
TPE_STRING				equ 0D0h			;Immediate string

TPE_NOTEQU				equ 0F0h			;Operator <>, internaly used
TPE_GTOREQU				equ 0F1h			;Operator >=, internaly used
TPE_LEOREQU				equ 0F2h			;Operator <=, internaly used
TPE_GT					equ 0F3h			;Operator >, internaly used
TPE_EQU					equ 0F4h			;Operator =, internaly used
TPE_LE					equ 0F5h			;Operator <, internaly used

TPE_AND					equ 0F7h			;Logical operator And, internaly used
TPE_OR					equ 0F8h			;Logical operator Or, internaly used
TPE_XOR					equ 0F9h			;Logical operator Xor, internaly used

TPE_GRPFUNCTION			equ 0FAh			;Graph Grp(
TPE_GRPTFUNCTION		equ 0FBh			;Graph T(
TPE_GRPXFUNCTION		equ 0FCh			;Graph X(
TPE_GRPYFUNCTION		equ 0FDh			;Graph Y(
TPE_GRPGXFUNCTION		equ 0FEh			;Graph G(
TPE_GRPFXFUNCTION		equ 0FFh			;Graph fx(

MAXROWMEM			equ 1024*2
COLMAX				equ 255
ROWMAX				equ 255
WINMAX				equ 8
FONTMAX				equ 16

HDRWT				equ 23
HDRHT				equ 17
CELLWT				equ 75
CELLHT				equ 17

STATUSHT			equ 17*2
INPHT				equ 17
SBSIZE				equ 16

WIN struct dword
	hwin			dd ?
	nwin			dd ?
	rect			RECT <?>
	hdc				dd ?
	mdc				dd ?
	act				dd ?
	tcol			dd ?
	trow			dd ?
	ccol			dd ?
	crow			dd ?
	mcol			dd ?
	mrow			dd ?
	lcol			dd ?
	lrow			dd ?
	sflag			dd ?
	scur			dd ?
	scurpt			POINT <?>
	scol			dd ?
	srow			dd ?
	sync			dd ?
WIN ends

SHEET struct dword
	hwnd			dd ?
	winst			dd ?
	nid				dd ?
	howner			dd ?
	lprowmem		dd ?
	lpcol			dd ?
	lprow			dd ?
	hedt			dd ?
	fedt			dd ?
	spri			SPR_ITEM <>
	gfmt			GLOBAL <>
	ofont			FONT FONTMAX dup(<?>)
	nwin			dd ?
	owin			WIN WINMAX+1 dup(<?>)
	tr				dd ?
	ty				dd ?
	szDateFormat	db 32 dup(?)
SHEET ends

COLDTA struct
	len				dw ?
	coln			dw ?
	expx			db ?					;Expanded columns
	expy			db ?					;Expanded rows
	state			db ?
	fmt				FORMAT <?>
COLDTA ends

ROWDTA struct
	maxlen			dd ?
	len				dd ?
	rown			dw ?
	rowht			dw ?
	colend			dd ?
ROWDTA ends

GAXIS struct
	min				dt ?
	max				dt ?
	origo			dt ?
	factor			dt ?
	porigo			dd ?
	tick			dt ?
	fnt				dd ?
	color			dd ?
	lpcap			dd ?
	ftickval		dd ?
GAXIS ends

GTEXT struct
	x				dd ?
	y				dd ?
	rotate			dd ?
	fnt				dd ?
	color			dd ?
	lpcap			dd ?
GTEXT ends

GGX struct
	fcol			dd ?
	frow			dd ?
	tcol			dd ?
	trow			dd ?
	fnt				dd ?
	color			dd ?
	lpcap			dd ?
GGX ends

GFX struct
	lpfun			dd ?
	step			dt ?
	fnt				dd ?
	color			dd ?
	lpcap			dd ?
GFX ends

GRAPH struct
	rc				RECT <?>
	grc				RECT <?>
	x				GAXIS <?>
	y				GAXIS <?>
GRAPH ends

COMBO struct
	howner			HWND ?
	height			dd ?
COMBO ends

.const

szToolTip			db 'SpreadSheet',0

szClassNameSheet	db 'SPREAD_SHEET',0
szClassNameSheetWin	db 'SHEET_WIN',0
szClassNameEdit		db 'EDIT',0
szNULL				db 0
szFont				db 'MS Sans Serif',0
szListBox			db 'LISTBOX',0
szBlob				db 'Blob(%d)',0
szDots				db '...',0

flpe				dt 2.7182818284590452353602874713527
iL2e				dt 3FFEB17217F7D1CF79ACh
flpten				dt 10.0
szDefDateFormat		db 'yyyy-MM-dd',0

.data?

hInstance			dd ?
strHex				db 16 dup(?)
OldEditProc			dd ?
hCurArrow			dd ?
hCurSize			dd ?
hCurVSplit			dd ?
hCurHSplit			dd ?

nCalcCol			dd ?					;Used by relative cell reference
nCalcRow			dd ?					;Used by relative cell reference
nCalcCells			dd ?					;Used by RecalcSheet
acmltr0				dt ?
funx				dt ?
buff				db 4096 dup(?)
lpHyperlink			dd ?
OldHyperlinkCol		dd ?
HyperLinkRect		RECT <?>
hCtrl				dd ?
hCurrent			dd ?
lpCellData			dd ?
double				qword ?
single				dword ?
exdouble			tbyte ?
fEditCancel			dd ?
OldComboProc		dd ?
hfocus				dd ?
