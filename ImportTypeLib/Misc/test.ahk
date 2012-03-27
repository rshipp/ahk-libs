#NoEnv
#SingleInstance off
#Warn
#KeyHistory 0
SetBatchLines -1
ListLines Off

#include ..\
#include ImportTypeLib.ahk

UIAutomation := ImportTypeLib(A_WinDir "\System32\UIAutomationCore.dll")

struct := new UIAutomation.tagRECT()
struct.left := 16

rect := struct.Clone()
rect.bottom := 42
struct.top := 9

list := "TreeScope:`n"
for field, value in UIAutomation.TreeScope
	list .= "`tTreeScope." field " = " value "`n"
list .= "`nOrientationType:`n"
for field, value in UIAutomation.OrientationType
	list .= "`tOrientationType." field " = " value "`n"
list .= "`nstruct (tagRECT):`n"
for field, value in struct
	list .= "`tstruct." field " = " value "`n"
list .= "`nrect (tagRECT):`n"
for field, value in rect
	list .= "`trect." field " = " value "`n"
MsgBox % "Enumeration and structure fields:`n`n" list

automation := new UIAutomation.IUIAutomation(new UIAutomation.CUIAutomation())

desktop := new UIAutomation.IUIAutomationElement(automation.GetRootElement())
MsgBox % "The desktop:`n`n" GetElementInfo(desktop) "`n`nClick [OK] and wait 3 seconds."

sleep 3000

MouseGetPos,,,hwin

request := new UIAutomation.IUIAutomationCacheRequest(automation.CreateCacheRequest())
;MsgBox % "value: " request.TreeScope
request.TreeScope := UIAutomation.TreeScope.Children

elem := new UIAutomation.IUIAutomationElement(automation.ElementFromHandleBuildCache(ComObjParameter(0x4000, hwin), ComObjParameter(0xD, request["internal://type-instance"])))
MsgBox % "The active window:`n`n" GetElementInfo(elem)

GetElementInfo(elem)
{
	global UIAutomation
	return "Process ID:`t"  elem.CurrentProcessId "`nWindow name:`t" elem.CurrentName "`nControl Class:`t" elem.CurrentClassName "`nUI Framework:`t" elem.CurrentFrameworkId "`nOrientation:`t" (elem.CurrentOrientation == UIAutomation.OrientationType.Horizontal ? "horizontal" : (elem.CurrentOrientation == UIAutomation.OrientationType.Vertical ? "vertical" : "none"))
}