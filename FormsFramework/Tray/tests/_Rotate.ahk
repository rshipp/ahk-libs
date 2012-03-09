OnExit, OnExit

#SingleInstance, force
	Gui, +LastFound
	hGui := WinExist()
	Tray_Add(hGui, "OnIcon", "shell32.dll:22")

	i := 0
	SetTimer, Rotate, 200
return

OnIcon(){
}

ESC:: GoSub OnExit

Rotate:
	i++
	n := Tray_Count()
	Tray_Move(i,i=n ? 1 : i+1)
	if (i=n)
		i := 0
return

OnExit:
	Tray_Remove(hGui)
	ExitApp
return

#include ..\Tray.ahk