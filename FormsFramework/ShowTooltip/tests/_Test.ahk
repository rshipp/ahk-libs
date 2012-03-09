#Persistent 
#SingleInstance, force
CoordMode,ToolTip,Screen 

	Loop % (20){ 
	   Random, x,0,% A_ScreenWidth 
	   Random, y,0,% A_ScreenHeight 
	   Random, TimeIn,500,5000 
	   Random, TimeOut,2000,10000 
	   ShowToolTip("ToolTip " A_Index, x, y, TimeIn,TimeOut,"", A_Index) 
	} 
return

#include ..\ShowTooltip.ahk