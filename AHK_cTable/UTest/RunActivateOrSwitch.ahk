RunActivateOrSwitch(Target, WinTitle = "") 
{
   ; Get the filename without a path 
   SplitPath, Target, TargetNameOnly

   ; Process returns the PID of a matching process exists, or 0 otherwise
   Process, Exist, %TargetNameOnly%
   ; Get the PID and the class if the process is already running
   If ErrorLevel > 0
   {
      PID = %ErrorLevel%
      WinGetClass, ClassID, ahk_pid %PID%
   }
   ; Run the program if the process is not already running
   Else
      Run, %Target%, , , PID

   ; At least one app  wouldn't always become the active
   ; window after using Run, so we always force a window activate.
   ; Activate by title if given, otherwise use class ID. Activating by class ID
   ; appears more robust for switching than using PID.
   If WinTitle <>
   {
      SetTitleMatchMode, 2
      WinWait, %WinTitle%, , 3
      IfWinActive, %WinTitle%
   WinActivateBottom, %WinTitle%
      Else
   WinActivate, %WinTitle%
   }
   Else
   {
      WinWait, ahk_class %ClassID%, , 3
      IfWinActive, ahk_class %ClassID%
           WinActivateBottom, ahk_class %ClassID%
      Else
   WinActivate, ahk_class %ClassID%
   }
}
