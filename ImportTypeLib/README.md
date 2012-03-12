## ImportTypeLib
This project will allow calling COM object methods by name even on non-dispatch methods by using type information interfaces

### Example
Sounds complicated? Here is how it will look:

```ahk
UIAutomation := ImportTypeLib(A_WinDir "\System32\UIAutomationCore.dll")
automation := new UIAutomation.CUIAutomation()

MsgBox % "Retrieved condition: " automation.ControlViewCondition
automation.RemoveAllEventHandlers()

desktop := new UIAutomation.IUIAutomationElement(automation.GetRootElement())
MsgBox % "Desktop process PID: " desktop.CurrentProcessId
desktop.SetFocus()

MsgBox % "The desktop has " . (desktop.CurrentOrientation == UIAutomation.OrientationType.Horizontal ? "horizontal" : "vertical") . " orientation."
```

This will work for all COM interfaces for which a "type library" is available (in the example above, it is in `%A_WinDir%\System32\UIAutomationCore.dll`).