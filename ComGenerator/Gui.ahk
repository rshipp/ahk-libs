/*
File: Gui.ahk
Script: ComGenerator

Purpose:
	Holds the UI-related code.

Authors:
	* maul.esel

Requirements:
	AutoHotkey - AutoHotkey_L v1.1+
	Libraries - CCF (https://github.com/maul-esel/COM-Classes)

License:
	http://unlicense.org
*/
/*
Label: BuildGui
builds the GUI
*/
BuildGui:
Gui main: New,, ComGenerator

Gui main: Add, Groupbox, x5 y0 w930 h45 cGray Section

Gui main: Add, Text, x10 ys+15 w300, AutoHotkey version:
Gui main: Add, Checkbox, vAHK_L x320 yp w300, AutoHotkey_L
Gui main: Add, Checkbox, vAHK2 x630 yp w300 Checked, AutoHotkey v2

Gui main: Add, Groupbox, x5 yp+25 w930 h100 cGray Section

Gui main: Add, Text, x10 ys+15 w300, Interface ID (IID):
Gui main: Add, Edit, vInterfaceID xp yp+25 w300
Gui main: Add, Button, xp yp+30 w300 vLoadInfoButton gGui_LoadLibraryInformation, Load

Gui main: Add, Text, x320 ys+15 w300, Interface name:
Gui main: Add, Edit, vInterfaceName xp yp+25 w300
Gui main: Add, Button, xp yp+30 w300 vSearchIIDButton gGui_SearchIID4Name, Search

Gui main: Add, Text, x630 ys+15 w300, Class ID:
Gui main: Add, Edit, vClassID xp yp+25 w300
Gui main: Add, Button, xp yp+30 w300 vSetClassButton gGui_SetCLSID, Set

Gui main: Add, Groupbox, x5 yp+25 w930 h75 cGray Section

Gui main: Add, Text, x10 ys+15, Type Library GUID:
Gui main: Add, Edit, vTypeLibGUID Readonly x150 yp w300

Gui main: Add, Text, x460 yp, Type Library Version:
Gui main: Add, Edit, vTypeLibMajorVer Readonly x630 yp w145
Gui main: Add, Edit, vTypeLibMinorVer Readonly x785 yp w145

Gui main: Add, Button, x10 yp+30 w920 disabled vLoadLibButton gGui_LoadTypeLibrary, Load library

Gui main: Add, Groupbox, x5 yp+25 w930 h45 cGray Section

Gui main: Add, Text, x10 ys+15, ITypeLib pointer:
Gui main: Add, Edit, vTypeLibPtr Readonly x150 yp w300
Gui main: Add, Button, x460 yp w470 disabled vLoadTypeButton gGui_LoadTypeInfo, Load type

Gui main: Add, Groupbox, x5 yp+25 w930 h45 cGray Section

Gui main: Add, Text, x10 ys+15, ITypeInfo pointer:
Gui main: Add, Edit, vTypeInfoPtr Readonly x150 yp w300
Gui main: Add, Button, x460 yp w470 disabled vGenerateButton gGui_GenerateClass, Generate class

Gui main: Add, Statusbar

Gui main: Default
SB_SetParts(310, 310)
Status(), Error()

Gui main: Show, w940
return

Gui_SetCLSID:
GuiControl main: +Readonly, ClassID
GuiControl main: Disable, SetClassButton
return

/*
Label: Gui_SearchIID4Name
searches the registry for an IID for a given interface name.
*/
Gui_SearchIID4Name:
Gui main: Submit, NoHide
if (!InterfaceName)
{
	Error(ERROR.NAME_MISSING, true), Status()
	return
}
iid := SearchIID4Name(InterfaceName)
GuiControl main:, InterfaceID, % iid ? iid : ""
return

/*
Label: Gui_LoadLibraryInformation
loads interface name, type library guid and type library version for an IID.
*/
Gui_LoadLibraryInformation:
Gui main: Submit, NoHide

GuiControl main:, InterfaceName, % name := GetName4IID(InterfaceID)
GuiControl main:, TypeLibGUID, % libid := GetTypeLibID4IID(InterfaceID)

version := GetTypeLibVersion4IID(InterfaceID)
StringSplit, version, version,.
GuiControl main:, TypeLibMajorVer, %version1%
GuiControl main:, TypeLibMinorVer, %version2%

if (name && libid && version)
{
	GuiControl main: +Readonly, InterfaceID
	GuiControl main: +Readonly, InterfaceName

	GuiControl main: Disable, LoadInfoButton
	GuiControl main: Disable, SearchIIDButton
	GuiControl main: Enable, LoadLibButton

	Error()
}
Status()
return

/*
Label: Gui_LoadTypeLibrary
loads the type library based on the information extracted in <Gui_LoadLibraryInformation>.
*/
Gui_LoadTypeLibrary:
Gui main: Submit, NoHide
lib := LoadTypeLibrary(TypeLibGUID, TypeLibMajorVer, TypeLibMinorVer)

GuiControl main:, TypeLibPtr, % lib.ptr
success := IsObject(lib)
GuiControl main: Enable%success%, LoadTypeButton
GuiControl main: Disable%success%, LoadLibButton
return

/*
Label: Gui_LoadTypeInfo
loads type information from the type library created in <Gui_LoadTypeLibrary> and based on the specified IID.
*/
Gui_LoadTypeInfo:
Gui main: Submit, NoHide
type := LoadTypeInfo(lib, InterfaceID)

GuiControl main:, TypeInfoPtr, % type.ptr
success := IsObject(type)
GuiControl main: Enable%success%, GenerateButton
GuiControl main: Disable%success%, LoadTypeButton
return

/*
Label: Gui_GenerateClass
generates a CCF class from the type information.
*/
Gui_GenerateClass:
Gui main: Submit, NoHide
version := AHKVersion.NONE

if (AHK_L)
	version |= AHKVersion.AHK_L
if (AHK2)
	version |= AHKVersion.AHK2

if (version == AHKVersion.NONE)
{
	version := AHKVersion.AHK2
	GuiControl main:, AHK2, 1
	GuiControl main: Disable, AHK2
}
generator := new CCFGenerator(type, version)
generator.Generate()
;throw Exception("Not implemented!", -1)
return

/*
Label: mainGuiClose
Invoked when the main window is closed. Closes the app.

Remarks:
	Any cleanup not directly connected to the UI should instead be placed in an OnExit label.
*/
mainGuiClose:
ExitApp
return

/*
Function: Gui_Status
If the app is in GUI mode, reports the current status to the user.

Parameters:
	STR text - the text to report
*/
Gui_Status(text = "Ready.")
{
	Gui main: Default
	SB_SetText(text, 1)
}

/*
Function: Gui_Error
If the app is in GUI mode, reports an error to the user

Parameters:
	STR text - the text to report
*/
Gui_Error(code, msg)
{
	Gui main: Default
	SB_SetText("`t`t" . ERROR.Messages[code], 3), SB_SetText("`t" . msg, 2)
}