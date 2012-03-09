/**************************************************************************************************************
class: ITaskbarList
extends IUnknown

Requirements:
	- This requires AHK v2 alpha (may also work with v1.1)
	- It also requires Windows 2000 Professional, Windows XP, Windows 2000 Server or higher
***************************************************************************************************************	
*/
class ITaskbarList extends IUnknown
	{
	/**************************************************************************************************************
	Variable: CLSID
	This is CLSID_TaskbarList. It is required to create the object.
	***************************************************************************************************************	
	*/
	var CLSID := "{56FDF344-FD6D-11d0-958A-006097C9A090}"
	
	/**************************************************************************************************************
	Variable: IID
	This is IID_ITaskbarList1. It is required to create the object.
	***************************************************************************************************************	
	*/
	var IID := "{56FDF342-FD6D-11d0-958A-006097C9A090}"
	
	/**************************************************************************************************************
	Function: HrInit
	initializes the interface.

	Returns:
		HRESULT success - S_OK (0x000) on success, error code otherwise.
		
	Example:
>		ITBL.HrInit()
		
	Remarks:
		- This is required to work with ITaskbarList(1-4).
	***************************************************************************************************************	
	*/
	HrInit(){
		return DllCall(NumGet(this.vt+03*A_PtrSize), "ptr", this.ptr)
		}
	
	/**************************************************************************************************************
	Function: AddTab
	adds a new item to the taskbar
	
	Parameters:
		handle hWin - the handle to the window to add.
		
	Returns:
		HRESULT success - S_OK (0x000) on success, error code otherwise.
		
	Example:
>	Gui +LastFound
>	ITBL.AddTab(WinExist())
	***************************************************************************************************************	
	*/
	AddTab(hWin){
		return DllCall(NumGet(this.vt+04*A_PtrSize), "Ptr", this.ptr, "UInt", hWin)
		}
	
	/**************************************************************************************************************
	Function: DeleteTab
	deletes an item from the taskbar
	
	Parameters:
		handle hWin - the handle to the window to remove.
		
	Returns:
		HRESULT success - S_OK (0x000) on success, error code otherwise.
		
	Example:
>	ITBL.DeleteTab(WinExist("Notepad"))
	***************************************************************************************************************	
	*/
	DeleteTab(hWin){
		return DllCall(NumGet(this.vt+05*A_PtrSize), "Ptr", this.ptr, "UInt", hWin)
		}
	
	/**************************************************************************************************************	
	Function: ActivateTab
	Activates an item on the taskbar.
	
	Parameters:
		handle hWin - the handle to the window whose item should be activated.
	
	Returns:
		HRESULT success - S_OK (0x000) on success, error code otherwise.
		
	Example:
>	ITBL.ActivateTab(WinExist("Mozilla Firefox"))

	Remarks:
		- The window is not actually activated; the window's item on the taskbar is merely displayed as active.
	***************************************************************************************************************	
	*/
	ActivateTab(hWin){
		return DllCall(NumGet(this.vt+06*A_PtrSize), "Ptr", this.ptr, "UInt", hWin)
		}
	
	/**************************************************************************************************************	
	Function: SetActiveAlt
	Marks a taskbar item as active but does not visually activate it.

	Parameters:
		handle hWin - the handle to the window that should be marked as active.

	Returns:
		HRESULT success - S_OK (0x000) on success, error code otherwise.

	Example:
>	ITBL.SetActiveAlt(WinExist())

	Remarks:
		- SetActiveAlt marks the item associated with hwnd as the currently active item for the window's process without changing the pressed state of any item. Any user action that would activate a different tab in that process will activate the tab associated with hwnd instead. The active state of the window's item is not guaranteed to be preserved when the process associated with hwnd is not active. To ensure that a given tab is always active, call SetActiveAlt whenever any of your windows are activated. Calling SetActiveAlt with a NULL hwnd clears this state.
	***************************************************************************************************************	
	*/
	SetActiveAlt(hWin){
		return DllCall(NumGet(this.vt+07*A_PtrSize), "Ptr", this.ptr, "UInt", hWin)
		}
	}