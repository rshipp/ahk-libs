$(name, ver) {
	static e="App_Exit", i="App_Init", c="App_Show"
	global App_Name,App_Ver

	#SingleInstance, force
	#NoEnv
	SetBatchLines, -1
	OnExit, %A_ThisFunc%

	App_Name := name,  App_Ver  := ver
	IsFunc(i) ? %i%() : 
	IsFunc(c) ? %c%() : 
    return

 $:
	if IsFunc(e)
		 if %e%()
			ExitApp
	else ExitApp
 return
}

App_GetNextGui() {
	loop, 99 
	{
		Gui %A_Index%:+LastFoundExist
		IfWinNotExist
			return A_Index
	}
	return 0
}

#include *i modules.ahk
#include *i inc\modules.ahk