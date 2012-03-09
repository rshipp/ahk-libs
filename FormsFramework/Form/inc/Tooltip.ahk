/* Function: Tooltip
			 Add tooltips to GUI controls.
 
 Dependencies:
			 <Win>

 Parameters:
			 HCtrl	- Handle of the control.
			 Text	- Tooltip text.

 Configuration:
			 TimeIn		- Time to pass before tooltip is shown, by default 800ms.
 			 TimeOut	- Time to pass to close the tooltip, by default 0 (don't close).
			 Num		- Tooltip number to use, by default 17.

 Remarks:
	Tooltip uses Form storage if present for configuration. If Form module is not present, it will use defaults.
	Some controls have its own child controls covering entire client space of the parent control (SpreadSheet, ReBar etc...).
	In that case you need to set-up tooltip for the topmost child control.
			 
 About:
	o 1.0 by majkinetor.
	o Licensed under BSD <http://creativecommons.org/licenses/BSD/>.
 */
Ext_Tooltip(HCtrl, Text){
	static SS_NOTIFY=0x100		;, adrWndProc="Ext_Tooltip_WndProc"

	WinGetClass, cls, ahk_id %HCtrl%
	if cls = Static
		WinSet, Style, +%SS_NOTIFY%, ahk_id %HCtrl%		; static control doesn't report WM_MOUSEMOVE without this flag.
	else if cls = ComboBox
		ControlGet, HCtrl, HWND,,Edit1, ahk_id %HCtrl%	; while in combo, it happens in edit owned by the combo

;	Form_SubClass(HCtrl, adrWndProc, "", adrWndProc)	;subclassing with the same function all the time makes problem when instantiated bunch of times...
	Win_SubClass(HCtrl, "Ext_Tooltip_WndProc")

	Ext_Tooltip_wndProc(0, 0, Text, HCtrl)
	return 1
}

Ext_Tooltip_wndProc(Hwnd, UMsg, WParam, LParam){	
	static
	static WM_MOUSEHOVER = 0x2A1, WM_MOUSELEAVE = 0x2A3, WM_MOUSEMOVE = 0x200, TM_HOVERLEAVE=3, Form = "Form"

	if !hwnd {
		%LParam% := WParam,  %Form%("", "Tooltip_)TimeIn TimeOut Num", timeIn, timeOut, num)
		timeIn .= timeIn = "" ? 800 : "", 	 num .= num = "" ? 17 : ""
		return
	}
	
	if (UMsg = WM_MOUSEMOVE) and (last != Hwnd)
		  VarSetCapacity(TME, 16)
		 ,NumPut(16,			TME, 0)
		 ,NumPut(TM_HOVERLEAVE, TME, 4)  
		 ,NumPut(Hwnd,			TME, 8)
		 ,NumPut(timeIn,		TME, 12) 
		 ,DllCall("TrackMouseEvent", "uint", &TME),   last := Hwnd

	if (umsg = WM_MOUSEHOVER) {
		s := %HWND%
		Tooltip, %s%,,,%num%
		if timeOut
			SetTimer, %A_ThisFunc%, -%timeOut%
	}
	
	if (umsg = WM_MOUSELEAVE){
		last =
		Tooltip,,,,%num%
	}

	return DllCall("CallWindowProcA", "UInt", A_EventInfo, "UInt", hwnd, "UInt", uMsg, "UInt", wParam, "UInt", lParam)
 
 Ext_Tooltip_WndProc:
		Tooltip,,,, %num%
 return
}

#include *i Win.ahk