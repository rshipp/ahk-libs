/**************************************************************************************************************
class: ITaskbarList3
extends ITaskbarList2

Requirements:
	- This requires AHK v2 alpha (may also work with v1.1)
	- It also requires Windows 7, Windows Server 2008 R2 or higher
***************************************************************************************************************	
*/

class ITaskbarList3 extends ITaskbarList2
	{
	/**************************************************************************************************************
	Variable: CLSID
	This is CLSID_TaskbarList. It is required to create the object.
	***************************************************************************************************************	
	*/
	var CLSID := "{56FDF344-FD6D-11d0-958A-006097C9A090}"
		
	/**************************************************************************************************************
	Variable: IID
	This is IID_ITaskbarList3. It is required to create the object.
	***************************************************************************************************************	
	*/
	var IID := "{ea1afb91-9e28-4b86-90e9-9e9f8a5eefaf}"
	
	/**************************************************************************************************************
	Function: SetProgressValue
	sets the current value of a taskbar progressbar

	Parameters:
		handle hGui - the window handle of your gui
		int value - the value to set, in percent

	Returns:
		HRESULT success - S_OK (0x000) on success, error code otherwise.
				
	Example:
>	Gui +LastFound
>	ITBL3.SetProgressValue(WinExist(), 50)
	***************************************************************************************************************	
	*/
	SetProgressValue(hWin, value){
		return DllCall(NumGet(this.vt+09*A_PtrSize), "Ptr", this.ptr, "uint", hWin, "int64", value, "int64", 100)
		}
	
	/**************************************************************************************************************
	Function: SetProgressState
	sets the current state and thus the color of a taskbar progressbar

	Parameters:
		handle hGui - the window handle of your gui
		variant state - the state to set

	Possible states:
		0 or S - stop displaying progress
		1 or I - indeterminate (similar to progress style PBS_MARQUEE), green
		2 or N - normal, by default green
		4 or E - error, by default red
		8 or P - paused, by default yellow

	Returns:
		HRESULT success - S_OK (0x000) on success, error code otherwise.

	Example:
>	ITBL3.SetProgressState(hGui, "P")

	Remarks:
		- There's still a difference between setting progress to 0 or turning it off.
		- original function by Lexikos
	***************************************************************************************************************	
	*/
	SetProgressState(hWin, state){
		if State is not integer
			{
			if state not in I,N,E,P,S
				return -1
			State :=  (State = "I" ? 1
					: (State = "N" ? 2
					: (State = "E" ? 4
					: (State = "P" ? 8 : 0))))
			}
		return DllCall(NumGet(this.vt+10*A_PtrSize), "Ptr", this.ptr, "uint", hWin, "uint", state)
		}
	/**************************************************************************************************************
	Function: RegisterTab
	Informs the taskbar that a new tab or document thumbnail has been provided for display in an application's taskbar group flyout.

	Parameters:
		handle hTab - the handle to the windo to be registered as a tab
		handle hWin - the handle to thew window to hold the tab.
	
	Returns:
		HRESULT success - S_OK (0x000) on success, error code otherwise.
		
	Example:
>	ITBL3.RegisterTab(WinExist(), hGui)
	***************************************************************************************************************	
	*/	
	RegisterTab(hTab, hWin){
		return DllCall(NumGet(this.vt+11*A_PtrSize), "Ptr", this.ptr, "UInt", hTab, "UInt", hWin)
		}
	
	/**************************************************************************************************************
	Function: UnRegisterTab
	Removes a thumbnail from an application's preview group when that tab or document is closed in the application.

	Parameters:
		handle hTab - the handle to the window whose thumbnail gonna be removed.
	
	Returns:
		HRESULT success - S_OK (0x000) on success, error code otherwise.
		
	Example:
>	ITBL3.UnRegisterTab(WinExist("ahk_class AutoHotkey"))
	***************************************************************************************************************	
	*/
	UnRegisterTab(hTab){
		return DllCall(NumGet(this.vt+12*A_PtrSize), "Ptr", this.ptr, "UInt", hTab)
		}
	
	/**************************************************************************************************************
	Function: SetTabOrder
	Inserts a new thumbnail into an application's group flyout or moves an existing thumbnail
	to a new position in the application's group.

	Parameters:
		handle hTab - the handle to the window to be inserted or moved.
		handle hBefore - the handle of the tab window whose thumbnail that hwndTab is inserted to the left of.
	
	Returns:
		HRESULT success - S_OK (0x000) on success, error code otherwise.
		
	Example:
>	ITBL3.SetTabOrder(hGui)
	***************************************************************************************************************	
	*/
	SetTabOrder(hTab, hBefore = 0){
		return DllCall(NumGet(this.vt+13*A_PtrSize), "Ptr", this.ptr, "UInt", hTab, "UInt", hBefore)
		}
	
	/**************************************************************************************************************
	Function: SetTabActive
	Informs the taskbar that a tab or document window has been made the active window.

	Parameters:
		handle hTab - the handle to the tab to become active.
		handle hWin - the handle to the window holding that tab.
	
	Returns:
		HRESULT success - S_OK (0x000) on success, error code otherwise.
		
	Example:
>	ITBL3.SetTabActive(hGui1, hGui2)
	***************************************************************************************************************	
	*/
	SetTabActive(hTab, hWin){
		return DllCall(NumGet(this.vt+14*A_PtrSize), "Ptr", this.ptr, "UInt", hTab, "UInt", hWin, "UInt", 0)
		}
	
	/**************************************************************************************************************
	Function: SetOverlayIcon
	set the overlay icon for a taskbar button

	params:
		handle hGui - the window handle of your gui
		hIcon Icon - handle to an icon

	Returns:
		HRESULT success - S_OK (0x000) on success, error code otherwise.
		
	Example:
>	ITBL3.SetOverlayIcon(WinExist(), DllCall("LoadIcon", "UInt", 0, "UInt", 32516))
	
	Remarks:
		- To get a hIcon, you might use LoadImage (<http://msdn.microsoft.com/de-de/library/ms648045>)
	***************************************************************************************************************	
	*/
	SetOverlayIcon(hWin, Icon) {
		return DllCall(NumGet(this.vt+18*A_PtrSize), "Ptr", this.ptr, "uint", hWin, "uint", Icon)
		}
	
	/**************************************************************************************************************
	Function: SetThumbnailTooltip
	set a custom tooltip for your thumbnail

	Parameters:
		handle hGui - the window handle of your gui
		str Tooltip - the text to set as your tooltip
			
	Returns:
		HRESULT success - S_OK (0x000) on success, error code otherwise.
		
	Example:
>	ITBL3.SetThumbnailTooltip(WinExist(), "my custom tooltip")
	***************************************************************************************************************	
	*/
	SetThumbnailTooltip(hWin, Tooltip){
		return DllCall(NumGet(this.vt+19*A_PtrSize), "Ptr", this.ptr, "UInt", hWin, "str", Tooltip)
		}
	
	/**************************************************************************************************************
	Function: SetThumbnailClip
	limit the taskbar thumbnail of a gui to a specified size instead of the whole window

	Parameters:
		handle hGui - the window handle of your gui
		int x - the x-coordinate of the area to show in the taskbar thumbnail
		int y - the y-coordinate of the area to show in the taskbar thumbnail
		int w - the width of the area to show in the taskbar thumbnail
		int h - the heigth of the area to show in the taskbar thumbnail

	Returns:
		HRESULT success - S_OK (0x000) on success, error code otherwise.
		
	Example:
>	ITBL3.SetThumbnailClip(hGui, 0, 0, 100, 100)
	***************************************************************************************************************	
	*/
	SetThumbnailClip(hWin, x, y, w, h) {
		VarSetCapacity(Rect, 16, 0)
		NumPut(x, Rect, 0)
		NumPut(y, Rect, 4)
		NumPut(w+x, Rect, 8)
		NumPut(h+y, Rect, 12)
		
		return DllCall(NumGet(this.vt+20*A_PtrSize), "Ptr", this.ptr, "UInt", hWin, "UInt", &Rect)
		}
	}