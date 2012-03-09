/**************************************************************************************************************
title: ITaskbar functions
wrapped by maul.esel

Credits:
			- Lexikos for making an example (<http://www.autohotkey.com/forum/topic50817.html>)
				 and helping me a lot (<http://www.autohotkey.com/forum/topic69001.html>)
			- fincs for correction on converting HRESULT to BOOL.

NOTE:
	Some of these functions require Windows Vista or even Windows7 (tested on Windows 7 32bit).
	All functions require AHK_L (tested with Unicode version) or the COM standard library by Sean.
***************************************************************************************************************	
*/

/**************************************************************************************************************
group: general

Function: ITaskbarList_Finish()
releases all ITaskbarList interfaces. You may call this when you finished your work with ITaskBarList.

params:
	[opt] int Interface - the interface to release. By default all interfaces (1-4)
***************************************************************************************************************	
*/
ITaskbarList_Finish(Interface = "all"){
static func1 := "ObjRelease", func2 := "COM_Release"

if interface is integer
	{
	if (interface > 0 && interface < 5) {
		if IsFunc(func1) {
			return %func1%(ITaskbarList(Interface))
		} else if IsFunc(func2) {
			return %func2%(ITaskbarList(Interface))
		} else {
			MsgBox 16, %A_ThisFunc%, This script is neither running AHK_L/2 nor is the COM library available.`nAs at least one of them is required, this script will exit.
			ExitApp
			}
		}
	}
	
Loop 4
	if IsFunc(func1) {
		%func1%(ITaskbarList(A_Index))
	} else if IsFunc(func2) {
		%func2%(ITaskbarList(A_Index))
	} else {
		MsgBox 16, %A_ThisFunc%, This script is neither running AHK_L/2 nor is the COM library available.`nAs at least one of them is required, this script will exit.
		ExitApp
		}
return
}

/**************************************************************************************************************
group: ITaskbarList
minimum required OS: Windows 2000 Professional, Windows XP, Windows 2000 Server

Function: ITaskbarList_AddTab()
adds an item to the taskbar.

params:
	handle hWin - the handle to the window to be added.
	
returns:
	HRESULT success - S_OK (0x000) on success, error code otherwise
***************************************************************************************************************	
*/
ITaskbarList_AddTab(hWin){
return DllCall(NumGet(NumGet(ITaskbarList(1)+0)+4 * (A_PtrSize ? A_PtrSize : 4)), A_PtrSize ? "Ptr" : "Uint", ITaskbarList(1), "UInt", hWin)
}

/**************************************************************************************************************
Function: ITaskbarList_DeleteTab()
deletes an item from the taskbar.

params:
	handle hWin - the handle to the window whose entry should be deleted.

returns:
	HRESULT success - S_OK (0x000) on success, error code otherwise
***************************************************************************************************************	
*/
ITaskbarList_DeleteTab(hWin){
return DllCall(NumGet(NumGet(ITaskbarList(1)+0)+5 * (A_PtrSize ? A_PtrSize : 4)), A_PtrSize ? "Ptr" : "Uint", ITaskbarList(1), "UInt", hWin)
}

/**************************************************************************************************************
Function: ITaskbarList_ActivateTab()
Activates an item on the taskbar.

params:
	handle hWin - the handle to the window whose item should be activated.
	
returns:
	HRESULT success - S_OK (0x000) on success, error code otherwise

Remarks:
	- The window is not actually activated; the window's item on the taskbar is merely displayed as active.
***************************************************************************************************************	
*/
ITaskbarList_ActivateTab(hWin){
return DllCall(NumGet(NumGet(ITaskbarList(1)+0)+6 * (A_PtrSize ? A_PtrSize : 4)), A_PtrSize ? "Ptr" : "Uint", ITaskbarList(1), "UInt", hWin)
}

/**************************************************************************************************************
Function: ITaskbarList_SetActiveAlt()
Marks a taskbar item as active but does not visually activate it.

params:
	handle hWin - the handle to the window that should be marked as active.

returns:
	HRESULT success - S_OK (0x000) on success, error code otherwise

Remarks:
	- _SetActiveAlt marks the item associated with hwnd as the currently active item for the window's process without changing the pressed state of any item. Any user action that would activate a different tab in that process will activate the tab associated with hwnd instead. The active state of the window's item is not guaranteed to be preserved when the process associated with hwnd is not active. To ensure that a given tab is always active, call SetActiveAlt whenever any of your windows are activated. Calling SetActiveAlt with a NULL hwnd clears this state._
***************************************************************************************************************	
*/
ITaskbarList_SetActiveAlt(hWin){
return DllCall(NumGet(NumGet(ITaskbarList(1)+0)+7 * (A_PtrSize ? A_PtrSize : 4)), A_PtrSize ? "Ptr" : "Uint", ITaskbarList(1), "UInt", hWin)
}

/**************************************************************************************************************
group: ITaskbarList2
minimum required OS: Windows XP, Windows Server 2003

Function: ITaskbarList_MarkFullscreen()
Marks a window as full-screen.

params:
	handle hGui - the window handle of your gui
	bool ApplyRemove - determines whether to apply or remove fullscreen property

returns:
	HRESULT success - S_OK (0x000) on success, error code otherwise
***************************************************************************************************************	
*/
ITaskbarList_MarkFullscreen(hGui, ApplyRemove) {
return DllCall(NumGet(NumGet(ITaskbarList(2)+0)+8 * (A_PtrSize ? A_PtrSize : 4)), A_PtrSize ? "Ptr" : "Uint", ITaskbarList(2), "Uint", hGui, "UInt", ApplyRemove)
}

/**************************************************************************************************************
group: ITaskBarList3
minimum required OS: Windows 7, Windows Server 2008 R2

Function: ITaskbarList_SetProgressValue()
set the current value of a taskbar progressbar

params:
	handle hGui - the window handle of your gui
	int value - the value to set, in percent

returns:
	HRESULT success - S_OK (0x000) on success, error code otherwise
***************************************************************************************************************	
*/
ITaskbarList_SetProgressValue(hGui, Value) { ; original function by Lexikos (see at the top of this lib)
return DllCall(NumGet(NumGet(ITaskbarList(3)+0)+9 * (A_PtrSize ? A_PtrSize : 4)), A_PtrSize ? "Ptr" : "Uint", ITaskbarList(3), "uint", hGui, "int64", Value, "int64", 100)
}

/**************************************************************************************************************
Function: ITaskbarList_SetProgressState()
sets the current state and thus the color of a taskbar progressbar

params:
	handle hGui - the window handle of your gui
	variant state - the state to set

possible states:
	0 or S - stop displaying progress
	1 or I - indeterminate (similar to progress style PBS_MARQUEE), green
	2 or N - normal, by default green
	4 or E - error, by default red
	8 or P - paused, by default yellow

returns:
	HRESULT success - S_OK (0x000) on success, error code otherwise

Remarks:
	- There's still a difference between setting progress to 0 or turning it off.
	- original function by Lexikos
***************************************************************************************************************	
*/
ITaskbarList_SetProgressState(hGui, State) { ; 
	if State is not integer
		{
		if State not in I,N,E,P,S
			return -1
		State :=  (State = "I" ? 1
				: (State = "N" ? 2
				: (State = "E" ? 4
				: (State = "P" ? 8 : 0))))
		}
return DllCall(NumGet(NumGet(ITaskbarList(3)+0)+10 * (A_PtrSize ? A_PtrSize : 4)), A_PtrSize ? "Ptr" : "Uint", ITaskbarList(3), "uint", hGui, "uint", State)
}

/**************************************************************************************************************
Function: ITaskbarList_RegisterTab()
Informs the taskbar that a new tab or document thumbnail has been provided for display in an application's taskbar group flyout.

params:
	handle hTab - the handle to the windo to be registered as a tab
	handle hWin - the handle to thew window to hold the tab.
	
returns:
	HRESULT success - S_OK (0x000) on success, error code otherwise
***************************************************************************************************************	
*/
ITaskbarList_RegisterTab(hTab, hWin){
return DllCall(NumGet(NumGet(ITaskbarList(3)+0)+11 * (A_PtrSize ? A_PtrSize : 4)), A_PtrSize ? "Ptr" : "Uint", ITaskbarList(3), "UInt", hTab, "UInt", hWin)
}

/**************************************************************************************************************
Function: ITaskbarList_UnRegisterTab()
Removes a thumbnail from an application's preview group when that tab or document is closed in the application.

params:
	handle hTab - the handle to the window whose thumbnail gonna be removed.
	
returns:
	HRESULT success - S_OK (0x000) on success, error code otherwise
***************************************************************************************************************	
*/
ITaskbarList_UnRegisterTab(hTab){
return DllCall(NumGet(NumGet(ITaskbarList(3)+0)+12 * (A_PtrSize ? A_PtrSize : 4)), A_PtrSize ? "Ptr" : "Uint", ITaskbarList(3), "UInt", hTab)
}

/**************************************************************************************************************
Function: ITaskbarList_SetTabOrder()
Inserts a new thumbnail into an application's group flyout or moves an existing thumbnail to a new position in the application's group.

params:
	handle hTab - the handle to the window to be inserted or moved.
	handle hBefore - the handle of the tab window whose thumbnail that hwndTab is inserted to the left of.
	
returns:
	HRESULT success - S_OK (0x000) on success, error code otherwise
***************************************************************************************************************	
*/
ITaskbarList_SetTabOrder(hTab, hBefore = 0){
return DllCall(NumGet(NumGet(ITaskbarList(3)+0)+13 * (A_PtrSize ? A_PtrSize : 4)), A_PtrSize ? "Ptr" : "Uint", ITaskbarList(3), "UInt", hTab, "UInt", hBefore)
}


/**************************************************************************************************************
Function: ITaskbarList_SetTabActive()
Informs the taskbar that a tab or document window has been made the active window.

params:
	handle hTab - the handle to the tab to become active.
	handle hWin - the handle to the window holding that tab.
	
returns:
	HRESULT success - S_OK (0x000) on success, error code otherwise
***************************************************************************************************************	
*/
ITaskbarList_SetTabActive(hTab, hWin){
return DllCall(NumGet(NumGet(ITaskbarList(3)+0)+14 * (A_PtrSize ? A_PtrSize : 4)), A_PtrSize ? "Ptr" : "Uint", ITaskbarList(3), "UInt", hTab, "UInt", hWin, "UInt", 0)
}

/**************************************************************************************************************
Function: ITaskbarList_ThumbBarAddButtons()
extensive support for all thumbbutton functions coming soon...
***************************************************************************************************************	
*/

/**************************************************************************************************************
Function: ITaskbarList_SetOverlayIcon()
set the overlay icon for a taskbar button

params:
	handle hGui - the window handle of your gui
	hIcon Icon - handle to an icon

returns:
	HRESULT success - S_OK (0x000) on success, error code otherwise
	
Remarks:
	- To get a hIcon, you might use LoadImage (<http://msdn.microsoft.com/de-de/library/ms648045>)
***************************************************************************************************************	
*/
ITaskbarList_SetOverlayIcon(hGui, Icon) {
return DllCall(NumGet(NumGet(ITaskbarList(3)+0)+18 * (A_PtrSize ? A_PtrSize : 4)), A_PtrSize ? "Ptr" : "Uint", ITaskbarList(3), "uint", hGui, "uint", Icon)
}

/**************************************************************************************************************
Function: ITaskbarList_SetThumbnailTooltip()
set a custom tooltip for your thumbnail

params:
	handle hGui - the window handle of your gui
	str Tooltip - the text to set as your tooltip
			
returns:
	HRESULT success - S_OK (0x000) on success, error code otherwise
***************************************************************************************************************	
*/
ITaskbarList_SetThumbnailTooltip(hGui, Tooltip){
if (!A_PtrSize) {
	nSize := DllCall("kernel32\MultiByteToWideChar", "Uint", 0, "Uint", 0, A_PtrSize ? "Ptr" : "Uint", &Tooltip, "int", -1, "Uint", 0, "int", 0)
	VarSetCapacity(wTooltip, nSize * 2 + 1)
	DllCall("kernel32\MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &Tooltip, "int", -1, "Uint", &wTooltip, "int", nSize + 1)
	Tooltip := &wTooltip
	}
return DllCall(NumGet(NumGet(ITaskbarList(3)+0)+19 * (A_PtrSize ? A_PtrSize : 4)),A_PtrSize ? "Ptr" : "Uint",ITaskbarList(3),"UInt",hGui,A_PtrSize ? "wstr" : "uint",Tooltip)
}


/**************************************************************************************************************
Function: ITaskbarList_SetThumbnailClip()
limit the taskbar thumbnail of a gui to a specified size instead of the whole window

params:
	handle hGui - the window handle of your gui
	int x - the x-coordinate of the area to show in the taskbar thumbnail
	int y - the y-coordinate of the area to show in the taskbar thumbnail
	int w - the width of the area to show in the taskbar thumbnail
	int h - the heigth of the area to show in the taskbar thumbnail
			
returns:
	HRESULT success - S_OK (0x000) on success, error code otherwise
***************************************************************************************************************	
*/
ITaskbarList_SetThumbnailClip(hGui, x, y, w, h) {
	
	VarSetCapacity(Rect, 16, 0)
	NumPut(x, Rect, 0)
	NumPut(y, Rect, 4)
	NumPut(w+x, Rect, 8)
	NumPut(h+y, Rect, 12)
return DllCall(NumGet(NumGet(ITaskbarList(3)+0)+20 * (A_PtrSize ? A_PtrSize : 4)), A_PtrSize ? "Ptr" : "Uint", ITaskbarList(3), "UInt", hGui, "UInt", &Rect)
}

/**************************************************************************************************************
group: ITaskbarList4
minimum required OS: Windows 7, Windows Server 2008 R2

Function: ITaskbarList_SetTabProperties()
Allows a tab to specify whether the main application frame window or the tab window should be used as a thumbnail or in the peek feature.

params:
	handle hTab - the handle of the tab to work on.
	int properties - the properties to set.
	
possible properties:
	0 - none
	1 - use the thumbnail provided by the main application frame window.
	2 - use the thumbnail of the tab except when it is active.
	3 - use the peek image provided by the main application frame window.
	4 - use the peek image of the tab except when it is active.
	
You may combine these values like this:
>	properties := 1|4
However, first lookup this page (<http://msdn.microsoft.com/de-de/library/dd562320.aspx>) to ensure this won't cause an error.

returns:
	HRESULT success - S_OK (0x000) on success, error code otherwise
***************************************************************************************************************	
*/
ITaskbarList_SetTabProperties(hTab, properties){
return DllCall(NumGet(NumGet(ITaskbarList(4)+0)+21 * (A_PtrSize ? A_PtrSize : 4)), A_PtrSize ? "Ptr" : "Uint", ITaskbarList(4), "UInt", hTab, "UInt", properties)
}

/**************************************************************************************************************
group: private functions

Function: ITaskbarList()
returns a ITaskbarList object and initializes it. *Only for private use by the library.*

params:
	int interface - the number of the interface to create.

returns:
	uint interfacepointer - a pointer used to invoke the object.
***************************************************************************************************************	
*/
ITaskbarList(Interface){
static ITaskBarList1 := false, ITaskBarList2 := false, ITaskBarList3 := false, ITaskBarList4 := false
, CLSID := "{56FDF344-FD6D-11d0-958A-006097C9A090}", IID1 := "{56FDF342-FD6D-11d0-958A-006097C9A090}", IID2 := "{602D4995-B13A-429b-A66E-1935E44F4317}"
, IID3 := "{ea1afb91-9e28-4b86-90e9-9e9f8a5eefaf}", IID4 := "{c43dc798-95d1-4bea-9030-bb99e2983a1a}", Func1 := "ComObjCreate", Func2 := "COM_CreateObject"

if (!ITaskBarList%Interface%){
	if IsFunc(Func1){
		ITaskBarList%Interface% := %Func1%(CLSID, IID%Interface%)
	} else if IsFunc(Func2) {
		ITaskBarList%Interface% := %Func2%(CLSID, IID%Interface%)
	} else {
		MsgBox 16, %A_ThisFunc%, This script is neither running AHK_L/2 nor is the COM library available.`nAs at least one of them is required, this script will exit.
		ExitApp
		}
	DllCall(NumGet(NumGet(ITaskBarList%Interface% + 0) + 3 * (A_PtrSize ? A_PtrSize : 4)), A_PtrSize ? "Ptr" : "Uint", ITaskBarList%Interface%)
	}
	
return ITaskBarList%Interface%
}
/**************************************************************************************************************
group: code

Note:
This section is only for those that don't understand at all what's going on in this code!

Explanation:
When reading the code you will find lines like this:
>	return DllCall(NumGet(NumGet(ITaskbarList(3)+0)+19 * (A_PtrSize ? A_PtrSize : 4)), "uint", ITaskbarList(3), "UInt", hGui, "str", Tooltip)
Not a long time ago, I wouldn't have understood this either. I'll try to explain it a bit, as far as I understand it myself.

Let's start from the inner braces:
>	NumGet(ITaskbarList(3)+0)
The function call to ITaskbarList() gives us a pointer to the ITaskbarList3 interface. By using NumGet(), we actually get the interface itself.

Then the next NumGet():
>	NumGet(NumGet(ITaskbarList(3)+0)+19 * (A_PtrSize ? A_PtrSize : 4))
This is quite strange. In fact, the "interface" we got from the inner braces is a location in memory.
It is the location of the objects "vtable" in memory. We now modify this location to get to a specific function in it.
- First: the 19 means it is the 19th function in this interface's vtable.
- A_PtrSize is because of a difference between 32bit and 64bit systems: I don't exactly what it is, but it works ;-)

The NumGet() gives us a pointer to the function itself.

Now the entire DllCall():
>	DllCall(NumGet(NumGet(ITaskbarList(3)+0)+19 * (A_PtrSize ? A_PtrSize : 4)), "uint", ITaskbarList(3), "UInt", hGui, "str", Tooltip)
As you might notice, we not actually call a dll here, but a function in the memory. That's what the help says about dllcall():
>	"In v1.0.46.08+, this parameter may also consist solely of an an integer, which is interpreted as the address of the function to call."

The parameters are just what the function needs:
	- hGui as handle to the window
	- Tooltip as tooltip to set.
	
But what about the first one?:
You might know AHK_L object syntax:
>	Object.Function() ; equivalent to:
>	Function(Object)
In our case, it's quite the same as the second one: We give the object itself as first parameter.

Got curious?:
- Don't ask me :P
- Read the topics linked in the top of this page
- READ THAT POST: <http://www.autohotkey.com/forum/topic16187.html>

Disclaimer:
I don't understand a lot of these things, too, so maybe there are several mistakes in that rubbish ;-)
Corrections are always welcome :D
