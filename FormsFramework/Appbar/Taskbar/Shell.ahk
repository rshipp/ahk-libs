/* Title:	Shell
			*Shell automation module.*
 */

/*
	Function: Restart
			  Restarts shell.

	Remarks:
			  The effect is the same as killing the explorer.exe using task manager and starting it again.
			  Function will try to prevent execution of start-up group when explorer is started again.

	Returns:
			  Pid of the new shell instance.			
 */
Shell_Restart() {
	static WM_QUIT=0x12
	oldDetect := A_DetectHiddenWIndows
	DetectHiddenWIndows, on	

	PostMessage, WM_QUIT,,,, ahk_class Progman 
	loop {
		Process, Exist, explorer.exe
		pid := ErrorLevel
		if !pid || (A_Index > 20)
			break
		while (WinExist("ahk_pid " pid) != 0) {
			WinKill, ahk_pid %pid%
			Sleep 200
			if (bBreak := A_Index > 20)
				break
		}
		ifNotEqual, bBreak, 0, 	break
	}
	DetectHiddenWIndows, %oldDetect%

	Run, explorer.exe, , , pid
	WinWait, ahk_class Shell_TrayWnd

	;Disable start up group by holding shift. Sleep value may need to be adjusted I guess for slow computers...
	Send, {SHIFT down}
	Sleep 100
	Send, {SHIFT up}

}

/*
	Function: SMShow
			  Show start menu on particular location.

	Parameters:
			 X, Y	 - Coordinate on which to show Start Menu. Omit both parameters to show the Start Menu on its original location.

			 Transparency - Window transparency, by default 255.
			 bHideShadow - Hide Start Menu Shadow. On some systems showing the menu on non-default position will bug up shadow.
						   Enabled by default.

	Remarks:
			ESC key will not close the window if you used X and Y parameters. To close the window you can use the following code:
 >			ESC:: WinHide, ahk_class DV2ControlHost
 */
Shell_SMShow(X="", Y="", Transparency="", bHideShadow=1) {
	
	if X=mouse
		VarSetCapacity(POINT, 8), DllCall("GetCursorPos", "uint", &POINT), X := NumGet(POINT), Y := NumGet(POINT, 4)

	oldDetect := A_DetectHiddenWIndows
	DetectHiddenWIndows, on	

	if (X Y = "")
		PostMessage, 0x111, 305,, ahk_class Shell_TrayWnd
	else {		
		hSM := WinExist("ahk_class DV2ControlHost")
		WinSet, Transparent, % Transparency != "" ? Transparency : 255
		WinMove, X, Y
		DllCall("ShowWindow", "uint", hSM, "uint", 5)				;use dllcall so setwindelay doesn't delay.		    
		ifEqual, bHideShadow, 1, WinHide, ahk_class SysShadow		;makes problems when user clicks the start menu button regular way, stays up
	}
	WinActivate,  ahk_id %hSM%
	ControlFocus, Edit1, ahk_id %hSM%								;focus search field on Vista.
	DetectHiddenWIndows, %oldDetect%
}

/*
	Function: SMAdd
			  Add shortcuts to start menu programs group.

	Parameters:
			 Parent	   - Name of the parent folder, relative to the Programs folder. Specify "!" to add file to the StartUp group.
			 FileName  - Name of the file. If omited, only Parent will be created. If starts with the "!", file will be added to the Start Menu for all users.
						 FileName doesn't have to exist.
			 o1..o7	   - Named parameters: Name, WDir, Args, Desc, Icon, Shortcut, IconNumber, RunState. Those parameters will be passed 
						 to FileCrateShortuct. If Name is not present function will use name of the input file.
 */
Shell_SMAdd( Parent, FileName="", o1="", o2="", o3="", o4="", o5="", o6="", o7="") {
	if SubStr(FileName, 1, 1) = "!"
		FileName := SubStr(FileName, 2), bAllUsers := true
	
	ifEqual, Parent, !, SetEnv, Parent, % Shell_GetCommonPath(bAllUsers ? "COMMON_STARTUP" : "STARTUP")
	else Parent := Shell_GetCommonPath( bAllUsers ? "COMMON_PROGRAMS" : "PROGRAMS") "\" Parent 

	loop, 7	{
		v := o%A_Index%
		ifEqual, v, ,break
		j := InStr(v, "="), n := SubStr(v, 1, j-1), %n% := SubStr(v, j+1)
	}
	IfEqual, Name,, SplitPath, FileName,,,,Name


	if !FileExist(Parent) {
		FileCreateDir, %Parent%
		ifEqual, ErrorLevel,1, return 0
	}

	FileCreateShortcut, %FileName%, %Parent%\%Name%.lnk, %WDir%, %Args%, %Desc%, %Icon%, %Shortcut%, %IconNumber%, %RunState%
}

/*
  Function:		GetCommonPath
 				Return location of standard system folders.
 
  Parameters:	
				Name	- Name of the sysetem folder.

  Folders:
				Bellow is the list of available folders and their typical locations :

				APPDATA                -  C:\Documents and Settings\username\Application Data.
				COOKIES				   -  C:\Documents and Settings\username\Cookies.
                COMMON_APPDATA         -  C:\Documents and Settings\All Users\Application Data. 
                COMMON_DOCUMENTS       -  C:\Documents and Settings\All Users\Documents.
				COMMON_PROGRAMS		   -  C:\Documents and Settings\All Users\Start Menu\Programs.
				COMMON_STARTMENU	   -  C:\Documents and Settings\All Users\Start Menu.
				COMMON_STARTUP		   -  C:\Documents and Settings\All Users\Start Menu\Programs\Startup.
                DESKTOP                -  C:\Documents and Settings\username\Desktop. 
                FONTS                  -  C:\Windows\Fonts. 
				FAVORITES			   -  C:\Documents and Settings\username\Favorites.
                LOCAL_APPDATA          -  C:\Documents and Settings\username\Local Settings\Application Data.
                MYMUSIC                -  C:\Documents and Settings\User\My Documents\My Music.
                MYPICTURES             -  C:\Documents and Settings\username\My Documents\My Pictures.
				MYVIDEO				   -  C:\Documents and Settings\username\My Documents\My Videos.
                PERSONAL               -  C:\Documents and Settings\username\My Documents.
                PROGRAM_FILES_COMMON   -  C:\Program Files\Common. 
                PROGRAM_FILES          -  C:\Program Files. 
                PROGRAMS               -  C:\Documents and Settings\username\Start Menu\Programs. 
				PROFILE				   -  C:\Documents and Settings\username.
				PROFILES			   -  C:\Documents and Settings.
                RESOURCES              -  C:\WINDOWS\Resources\ (For theme and other windows resources). 
				SENDTO				   -  C:\Documents and Settings\username\SendTo.
                STARTMENU              -  C:\Documents and Settings\username\Start Menu. 
                STARTUP                -  C:\Documents and Settings\username\Start Menu\Programs\Startup. 
                SYSTEM                 -  C:\Windows\System32.
                WINDOWS                -  C:\Windows.


  Returns:		
				Full path

  Reference:
			   <http://msdn.microsoft.com/en-us/library/bb762494(VS.85).aspx>
 				
 */
Shell_GetCommonPath( Name ) { 
		static  APPDATA=0x1A, COOKIES=0x21, COMMON_APPDATA=0x23, COMMON_DOCUMENTS=0x2e, COMMON_PROGRAMS=0x17, COMMON_STARTMENU=0x16
				,COMMON_STARTUP=0x18,DESKTOP=0x10, FONTS=0x14, FAVORITES=0x6, LOCAL_APPDATA=0x1C, MYMUSIC=0xd, MYVIDEO=0xe
				,MYPICTURES=0x27, PERSONAL=0x5,PROGRAM_FILES_COMMON=0x2b, PROGRAM_FILES=0x26, PROGRAMS=0x02, PROFILE=0x28, PROFILES=0x3e
				,RESOURCES=0x38, STARTMENU=0xb,STARTUP=0x7, SYSTEM=0x25, SENDTO=0x9, WINDOWS=0x24             
    VarSetCapacity(fpath, 512), DllCall( "shell32\SHGetFolderPathA", "uint", 0, "int", %Name%, "uint", 0, "int", 0, "str", fpath), VarSetCapacity(fpath, -1)
    return fpath
}

/*
  Function:		GetQuickLaunch
 				Returns files from the quick launch location.
 */
Shell_GetQuickLaunch(){
	path := Shell_GetCommonPath("APPDATA") "\Microsoft\Internet Explorer\Quick Launch"
	loop, %path%\*.*
		if !InStr(A_LoopFileAttrib, "H")
			s .= A_LoopFileFullPath "`n"
	return SubStr(s, 1, -1)
}

/*
	Function:	SetHook

	Parameter:
				Handler	- Name of the function to call on shell events. Omit to disable the active hook.			

	Handler:
		Event		- Event for which handler is called. 
		Param		- Parameter of the handler. Parameters are given bellow for each reason.

 >	OnShell(Reason, Param) {	
 >		static WINDOWCREATED=1, WINDOWDESTROYED=2, WINDOWACTIVATED=4, GETMINRECT=5, REDRAW=6, TASKMAN=7, APPCOMMAND=12
 >	} 
		
	Param:		
		WINDOWACTIVATED	-	The HWND handle of the activated window.
		WINDOWREPLACING	-	The HWND handle of the window replacing the top-level window.
		WINDOWCREATED	-	The HWND handle of the window being created.
		WINDOWDESTROYED	-	The HWND handle of the top-level window being destroyed.		
		GETMINRECT		-	A pointer to a RECT structure.
		TASKMAN			-	Can be ignored.
		REDRAW			-	The HWND handle of the window that needs to be redrawn.

	Remarks:
		Requires explorer to be set as a shell in order to work.

	Returns:
		0 on failure, name of the previous hook procedure on success.

	Reference:
		<http://msdn.microsoft.com/en-us/library/ms644989(VS.85).aspx>
 */
Shell_SetHook(Handler="") {
	oldDetect := A_DetectHiddenWindows
	DetectHiddenWindows, on
	Process, Exist
	h := WinExist("ahk_pid " ErrorLevel)
	DetectHiddenWindows, %oldDetect%

	if (Handler = "")
		return DllCall( "DeregisterShellHookWindow", "Uint", h)

	if !DllCall("RegisterShellHookWindow", "UInt", h) 
		return 0
	return OnMessage(DllCall( "RegisterWindowMessage", "str", "SHELLHOOK") , Handler)
}

/*
  Function:		EGetCount
 				Get the number of items in the view.
 
  Parameters:	
 				pHwnd	- Handle to windows explorer instance.
 				flag	- set "sel" to get number of selected items.
 
  Returns:		
 				Number of items, or -1 on failure.
 				
 */
Shell_EGetCount( pHwnd, flag="") {

	ieObj := Shell_EGetIEObject( pHwnd ) 
	fvObj := Shell_GetFolderView( ieObj )
	if !fvObj
		return -1

	if (flag="all") or flag = ""
		param := 0x00000002 ;SVGIO_ALLVIEW 
	else if (flag="sel")
		param := 0x00000001

	return IFolderView_ItemCount(fvobj, param)
}

/*
  Function: EGetIEObject
 			Get IWebBrowser2 interface pointer from open explorer windows.
 
  Parameters: 
             hwndFind - Return interface pointer for instance with given hwnd.
 
  Returns:
 			IWebBrowser2 interface pointer.
 */
Shell_EGetIEObject( hwndFind="" ) {
	static 	IID_IWebBrowser2  := "{D30C1661-CDAF-11D0-8A3E-00C04FC9E26E}"

	sw := ShellWindows_Create()
	loop, % ShellWindows_Count(sw)
	{
		COM_Release(dispObj)

		dispObj := ShellWindows_Item( sw, A_Index-1 )					;get Dispatcher interface
		if !(ieObj := COM_QueryInterface(dispObj, IID_IWebBrowser2))	;get IWebBrowser2 interface
			continue
		
		if WebBrowser2_HWND(ieObj) = hwndFind
			break

		COM_Release(ieObj), ieObj := 0
	}

	return ieObj
}

/*
 Function:		GetPath
				Returns the currently open file system path in the given explorer window.

 Parameters:	
				pHwnd	- Handle to windows explorer instance.

 Returns:
				Path of currently open folder.
 */
Shell_EGetPath( pHwnd ) {
	static IID_IPersistFolder2	:= "{1AC3D9F0-175C-11d1-95BE-00609797EA4F}"

	ieObj := Shell_EGetIEObject( pHwnd ) 

	;get folder view automatition object
	fvObj := Shell_GetFolderView(ieObj)

	pf2Obj := IFolderView_GetFolder(fvObj, IID_IPersistFolder2)
	pidl := IPersistFolder2_GetCurFolder(pf2Obj)

	COM_Release(pfd2Obj), COM_Release(fvObj), COM_Release(ieObj)

	if API_SHGetPathFromIDList(pidl, fpath)
		return fpath
}

/*
  Function:		GetSelection
 				Get selected item(s)
 
  Parameters:
 				hwnd	- Handle of Explorer window.
  
  Returns:
 				Path of each selected item.
 */
Shell_EGetSelection( pHwnd ) {
	ieObj := Shell_EGetIEObject( pHwnd )
	fvObj := Shell_GetFolderView( ieObj )

	elObj := IFolderView_Items(fvObj)
	loop
	{
		pidl := IEnumIdList_Next(elObj)
		ifEqual, pidl, 0, break
		API_SHGetPathFromIDList(pidl, fpath)
		res .= fpath "`n"
	}
	COM_Release(fvObj),	 COM_Release(ieObj)
	return res
}

/*
  Function:		GetView
 				Gets the current view of desired Explorer window.
 
  Parameters:	
 				pHwnd	- Handle to windows explorer instance.
 
  Returns:		View mode type, see <SetView>
 */
Shell_EGetView( pHwnd) {

	ieObj := Shell_EGetIEObject( pHwnd ) 
	fvObj := Shell_GetFolderView( ieObj )

	r := IFolderView_GetCurrentViewMode( fvObj )
	COM_Release(fvObj), COM_Release(ieObj)

	return r
}

/*
  Function:		ESelectItem
 				Select item by index.
  
  Parameters:
 				hwnd	- Handle of Explorer window.
 				idx1	- 0 based index of item to select.
 				idx2	- All items up to the idx2 will be selected. Keep in mind that this method selects items 1 by 1 thus selecting large amount 
 						  of items isn't efficient.
 */
Shell_ESelectItem(hwnd, idx1, idx2="") {
	ieObj := Shell_EGetIEObject( Hwnd )
	fvObj := Shell_GetFolderView( ieObj )

	if idx2 is not Integer
		return IFolderView_SelectItem(fvObj, idx1)
	
	loop,  % idx2 - idx1 + 1
		 IFolderView_SelectItem(fvObj, idx1+A_Index)	
}

/*
  Function:		SetPath
				Open the folder in given explorer window

 Parameters:	
				pHwnd	- Handle to windows explorer instance
				pPath	- path to be set or one of the tree symbols: > (go forward), < (go back), | (go up)
 Returns:
				True on success
 */
Shell_ESetPath( pHwnd, pPath ) {
	static IID_IShellBrowser	:= "{000214E2-0000-0000-C000-000000000046}"
	static SID_STopLevelBrowser := "{4C96BE40-915C-11CF-99D3-00AA004AE837}"
	static SBSP_PARENT := 0x2000, SBSP_NAVIGATEBACK := 0x4000, SBSP_NAVIGATEFORWARD := 0x8000

	ieObj := Shell_EGetIEObject( pHwnd ) 
	sbObj := COM_QueryService(ieObj, SID_STopLevelBrowser, IID_IShellBrowser)

	COM_Ansi2Unicode(pPath, wPath)

	pidl := 0
	if (pPath = "|") 
		flag := SBSP_PARENT
	else if (pPath ="<")
			flag :=	SBSP_NAVIGATEBACK	
		else if (pPath =">")
				flag :=	SBSP_NAVIGATEFORWARD	
			 else pidl := API_SHParseDisplayName( wPath ) 

	ShellBrowser_BrowseObject( sbObj, pidl, flag ) 
}

/*
  Function:		SetView
 				Sets the view in desired Explorer window
 
  Parameters:	
 				pHwnd	- Handle to windows explorer instance.
 				pView	- Number, view mode type. ICON (1), SMALLICON (2), LIST (3), DETAILS (4), THUMBNAIL (5), TILE (6), THUMBSTRIP (7)
 
 */
Shell_ESetView( pHwnd, pView ) {
	ieObj := Shell_EGetIEObject( pHwnd ) 
	fvObj := Shell_GetFolderView( ieObj )

	r := IFolderView_SetCurrentViewMode( fvObj, pView )
	COM_Release(fvObj), COM_Release(ieObj)

	return r
}

;============================================== PRIVATE ===================================



Shell_getFolderView( ieObj ) {
	static IID_IShellBrowser	:= "{000214E2-0000-0000-C000-000000000046}"
		,  IID_IFolderView		:= "{CDE725B0-CCC9-4519-917E-325D72FAB4CE}"
		,  SID_STopLevelBrowser := "{4C96BE40-915C-11CF-99D3-00AA004AE837}"
	
	sbObj := COM_QueryService(ieObj, SID_STopLevelBrowser, IID_IShellBrowser)
	svObj := ShellBrowser_QueryActiveShellView( sbObj )
	fvObj := COM_QueryInterface(svObj, IID_IFolderView)

	COM_Release(sbObj), COM_Release(svObj)
	return fvObj
}

ShellWindows_Create(){
	static CLSID_ShellWindows := "{9BA05972-F6A8-11CF-A442-00A0C90A8F39}"
		,  IID_ShellWindows	 := "{85CB6900-4D95-11CF-960C-0080C7F4EE85}"
	

	return COM_CreateObject(CLSID_ShellWindows, IID_ShellWindows) 
}

ShellWindows_Count(obj){
	DllCall( COM_VTable(obj, 7), "Uint", obj, "intP", cnt ) 
	return cnt
}

ShellWindows_Item( obj, index=0 ) {
	DllCall( COM_VTable(obj, 8), "Uint", obj, "int64", 3, "int64", index, "UintP", ieObj)
	return ieObj
}

WebBrowser2_HWND( obj ) {
	DllCall( COM_VTable(obj, 37), "Uint", obj, "UintP", hwnd)
	return hwnd
}

ShellBrowser_BrowseObject( obj, pidl, wFlags ) {
  	DllCall( COM_VTable(obj, 11), "Uint", obj, "uint", pidl, "uint", wFlags)
}

ShellBrowser_QueryActiveShellView(obj) {
 	DllCall( COM_VTable(obj, 15), "Uint", obj, "UintP", ppshv)
	return ppshv
}

IFolderView_GetFolder(obj, riid) {
	If StrLen(riid) = 38
	   COM_GUID4String(riid, riid)

 	DllCall( COM_VTable(obj, 5), "Uint", obj, "str", riid, "UintP", ppv)
	return ppv
}

IFolderView_SetCurrentViewMode( obj, viewMode ) {
	return DllCall( COM_VTable(obj, 4), "Uint", obj, "Uint", viewMode)
}

IFolderView_SelectItem( obj, idx, flag=1) {
	return DllCall( COM_VTable(obj, 15), "Uint", obj, "Uint", idx, "Uint", flag)
}

IFolderView_Item(obj, idx) {
	DllCall( COM_VTable(obj, 6), "Uint", obj, "Uint", idx, "UintP", pidl)
	return pidl
}

IFolderView_GetCurrentViewMode( obj ) {

	r := DllCall( COM_VTable(obj, 3), "Uint", obj, "UintP", viewMode)
	if (r>0) or (viewMode > 10)
		return 0

	return viewMode
}

IFolderView_GetFocusedItem(obj) {
	r := DllCall( COM_VTable(obj, 10), "Uint", obj,  "UintP", piItem)
	if r > 0 
		return 0

	return piItem
}

IFolderView_ItemCount(obj, pFlag) {
 	r := DllCall( COM_VTable(obj, 7), "Uint", obj, "uint", pFlag, "UintP", pcItems)
	if r > 0 
		return -1

	return pcItems
}

IFolderView_Items(obj, pFlag=0x80000001) {
	guid := COM_GUID4String(IID_IEnumIDList,"{000214F2-0000-0000-C000-000000000046}")
	DllCall(COM_VTable(obj, 8), "Uint", obj, "Uint", pFlag, "Uint" ,guid, "UintP", p)
	return p
}  

IEnumIdList_Next(obj) {
     DllCall(COM_VTable(obj, 3), "Uint", obj, "Uint", 1, "UintP", pidl, "UintP", 0)
	 return pidl
}

IPersistFolder2_GetCurFolder(obj){
 	DllCall( COM_VTable(obj, 5), "Uint", obj, "UintP", ppidl)
	return ppidl
}

ShellFolder_GetDisplayNameOf(obj, pidl, uFlags) {
 	DllCall( COM_VTable(obj, 11), "Uint", obj, "UintP", ppidl, "uint", uFlags, "str", 0) ;???
	return name
}

API_SHGetPathFromIDList(pidl, ByRef pszPath ) {
	VarSetCapacity( pszPath, 255, 0 )
	return DllCall("shell32.dll\SHGetPathFromIDList", "uint", pidl, "str", pszPath)
}

API_SHParseDisplayName( ByRef path ) {
	r := DllCall( "shell32.dll\SHParseDisplayName", "uint", &path, "uint", 0, "uintP", pidl ,"uint",0, "uint", 0 )
	if r > 0 
		return 0

	return pidl
}

/* Group: Examples
 Display info about active Explorer window
 (start code)
  	    h := WinExist("ahk_class ExploreWClass")
 
 	    p := "Path: " Shell_GetPath( h )
 	    s := "Sel:`n" Shell_GetSelection( hwnd)          
 
 	    msgbox %p%`n%s%
 (end code)
 */

/*
  Group: About 
       o Ver 2.0 by majkinetor. See http://www.autohotkey.com/forum/topic19400.html
       o Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/>
 */