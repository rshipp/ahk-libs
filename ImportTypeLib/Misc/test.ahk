#NoEnv
#SingleInstance off
#Warn
#KeyHistory 0
SetBatchLines -1
ListLines Off

#include ..\
#include ImportTypeLib.ahk

UIAutomation := ImportTypeLib(A_WinDir "\System32\UIAutomationCore.dll")

list := ""
for field, value in UIAutomation.TreeScope
	list .= "TreeScope." field " = " value "`n"
list .= "`n"
for field, value in UIAutomation.OrientationType
	list .= "OrientationType." field " = " value "`n"
MsgBox % list

automation := new UIAutomation.IUIAutomation(new UIAutomation.CUIAutomation())

desktop := new UIAutomation.IUIAutomationElement(automation.GetRootElement())
MsgBox % GetElementInfo(desktop)

sleep 3000

MouseGetPos,,,hwin
elem := new UIAutomation.IUIAutomationElement(automation.ElementFromHandle(ComObjParameter(0x4000, hwin)))
MsgBox % GetElementInfo(elem)

GetElementInfo(elem)
{
	global UIAutomation
	return "Process ID:`t"  elem.CurrentProcessId "`nWindow name:`t" elem.CurrentName "`nControl Class:`t" elem.CurrentClassName "`nUI Framework:`t" elem.CurrentFrameworkId "`nOrientation:`t" (elem.CurrentOrientation == UIAutomation.OrientationType.Horizontal ? "horizontal" : (elem.CurrentOrientation == UIAutomation.OrientationType.Vertical ? "vertical" : "none"))
}