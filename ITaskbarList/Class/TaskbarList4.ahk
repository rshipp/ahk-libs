/**************************************************************************************************************
class: ITaskbarList4
extends ITaskbarList3

Requirements:
	- This requires AHK v2 alpha (may also work with v1.1)
	- It also requires Windows 7, Windows Server 2008 R2 or higher
***************************************************************************************************************	
*/

class ITaskbarList4 extends ITaskbarList3
	{
	/**************************************************************************************************************
	Variable: CLSID
	This is CLSID_TaskbarList. It is required to create the object.
	***************************************************************************************************************	
	*/
	var CLSID := "{56FDF344-FD6D-11d0-958A-006097C9A090}"
		
	/**************************************************************************************************************
	Variable: IID
	This is IID_ITaskbarList4. It is required to create the object.
	***************************************************************************************************************	
	*/
	var IID := "{c43dc798-95d1-4bea-9030-bb99e2983a1a}"
		
	/**************************************************************************************************************
	Function: SetTabProperties
	Allows a tab to specify whether the main application frame window or the tab window
	should be used as a thumbnail or in the peek feature.

	Parameters:
		handle hTab - the handle of the tab to work on.
		int properties - the properties to set.
	
	Possible properties:
		0 - none
		1 - use the thumbnail provided by the main application frame window.
		2 - use the thumbnail of the tab except when it is active.
		3 - use the peek image provided by the main application frame window.
		4 - use the peek image of the tab except when it is active.
	
	You may combine these values like this:
>		properties := 1|4
	However, first lookup this page (<http://msdn.microsoft.com/de-de/library/dd562320.aspx>) to ensure this won't cause an error.

	Returns:
		HRESULT success - S_OK (0x000) on success, error code otherwise.
		
	Example:
>		ITBL4.SetTabProperties(WinExist(), 1|4)
***************************************************************************************************************	
*/
	SetTabProperties(hTab, properties){
		return DllCall(NumGet(this.vt+21*A_PtrSize), "Ptr", this.ptr, "UInt", hTab, "UInt", properties)
		}
	}