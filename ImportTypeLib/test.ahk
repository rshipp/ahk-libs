#NoEnv
#SingleInstance off
#Warn
#KeyHistory 0
SetBatchLines -1
ListLines Off
#include ImportTypeLib.ahk

UIAutomation := ImportTypeLib(A_WinDir "\System32\UIAutomationCore.dll\1")

ptr := new UIAutomation.CUIAutomation()
MsgBox % "UIAutomation: " ptr
automation := new UIAutomation.IUIAutomation(ptr)

ptr := automation.GetRootElement()
MsgBox % "desktop: " ptr
desktop := new UIAutomation.IUIAutomationElement(ptr)

MsgBox % "Process: " desktop.CurrentProcessId
MsgBox % desktop.SetFocus()

ListVars
MsgBox