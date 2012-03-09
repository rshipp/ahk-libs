/**************************************************************************************************************
class: ITaskbarList2
extends ITaskbarList

Requirements:
	- This requires AHK v2 alpha (may also work with v1.1)
	- It also requires Windows XP, Windows 2000 Server or higher
***************************************************************************************************************	
*/
class ITaskbarList2 extends ITaskbarList
	{
	/**************************************************************************************************************
	Variable: CLSID
	This is CLSID_TaskbarList. It is required to create the object.
	***************************************************************************************************************	
	*/
	var CLSID := "{56FDF344-FD6D-11d0-958A-006097C9A090}"
		
	/**************************************************************************************************************
	Variable: IID
	This is IID_ITaskbarList2. It is required to create the object.
	***************************************************************************************************************	
	*/
	var IID := "{602D4995-B13A-429b-A66E-1935E44F4317}"
	
	/**************************************************************************************************************
	Function: MarkFullScreen
	Marks a window as full-screen.

	Parameters:
		handle hGui - the window handle of your gui
		bool ApplyRemove - determines whether to apply or remove fullscreen property

	Returns:
		HRESULT success - S_OK (0x000) on success, error code otherwise.
		
	Example:
>	Gui 2: +LastFound
>	ITBL2.MarkFullScreen(WinExist())
	***************************************************************************************************************	
	*/
	MarkFullScreen(hWin){
		return DllCall(NumGet(this.vt+08*A_PtrSize), "Ptr", this.ptr, "Uint", hWin, "UInt", ApplyRemove)
		}
	}