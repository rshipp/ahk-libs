#NoEnv
#KeyHistory 0
#SingleInstance force
ListLines Off
SetBatchLines -1

SplashTextOn, 400, 50, Type Library Viewer, Loading type libraries...
libs := {}
Loop, HKCR, TypeLib, 2
{
	Loop HKCR, TypeLib\%A_LoopRegName%, 2
	{
		version := A_LoopRegName
	}
	StringSplit version, version, .
	hr := GUID_FromString(A_LoopRegName, guid)
	if (FAILED(hr))
	{
		MsgBox % Ti_FormatError(hr)
		continue
	}
	hr := DllCall("OleAut32\LoadRegTypeLib", "Ptr", &guid, "UShort", version1, "UShort", version2, "UInt", 0, "Ptr*", lib)
	if (FAILED(hr))
	{
		;MsgBox % Ti_FormatError(hr)
		continue
	}
	hr := DllCall(NumGet(NumGet(lib+0), 09*A_PtrSize, "Ptr"), "Ptr", lib, "Int", -1, "Ptr*", pName, "Ptr*", pDoc, "UInt*", 0, "Ptr", 0, "Int")
	if (FAILED(hr))
	{
		MsgBox % Ti_FormatError(hr)
		continue
	}
	StringUpper, guid, A_LoopRegName
	libs.Insert({ "Name": StrGet(pName), "Doc" : StrGet(pDoc), "GUID" : guid, "Version" : version })
	ObjRelease(lib)
}

Gui view: +Resize
Gui view: Add, Listview, x5 y5 w1200 h800, Name|Description|Version|GUID
Gui view: Default
for each, lib in libs
	LV_Add("", lib.Name, lib.Doc, lib.Version, lib.GUID)
Gui view: Add, Button, x5 y810 w100 h50 gCopySelected, Copy selected row
LV_ModifyCol(1, "AutoHdr Sort")
LV_ModifyCol(2, "AutoHdr")

SplashTextOff
Gui Show, w1210 h870, Type Library Viewer
return

viewGuiClose:
ExitApp
return

CopySelected:
row := LV_GetNext(1, "F")
Loop % LV_GetCount("Col")
{
	LV_GetText(header, 0, A_Index)
	LV_GetText(field, row, A_Index)
	text .= header " = " field "|"
}
text := RTrim(text, "|")
Clipboard := text
return