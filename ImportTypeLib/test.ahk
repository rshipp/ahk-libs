#NoEnv
#SingleInstance off
#Warn
#KeyHistory 0
SetBatchLines -1
ListLines Off
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

MsgBox % "Desktop process: " desktop.CurrentProcessId
MsgBox % "Desktop name: " desktop.CurrentName
MsgBox % "Desktop class: " desktop.CurrentClassName
MsgBox % "The desktop has " . (desktop.CurrentOrientation == UIAutomation.OrientationType.Horizontal ? "horizontal" : (desktop.CurrentOrientation == UIAutomation.OrientationType.Vertical ? "vertical" : "no")) . " orientation."