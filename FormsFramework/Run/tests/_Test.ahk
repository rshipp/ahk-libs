	cmd := "schtasks /query"
	s := Run(cmd, "", .2)
	msgbox % s
return

#include ..\Run.ahk
