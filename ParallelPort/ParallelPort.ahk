#NoEnv

InitParallelPort(ModuleHandle,0)

Temp1 = 00000000
InputBox, Temp1, Parallel Port, Please enter a string of binary:,, W, H, X, Y,,, %Temp1%

WriteParallelPort(Temp1)
Temp1 := ReadParallelPort()
DllCall("FreeLibrary","UInt",hModule)

ToolTip, % Temp1
Sleep, 1000
ExitApp

;Port address is usually 0x378, but sometimes 0x278

InitParallelPort(ByRef ModuleHandle,VerifyDll = 1)
{
 global Inp32Proc
 global Out32Proc
 DllPath = %A_ScriptDir%\inpout32.dll
 If VerifyDll
  VerifyDll(DllPath)
 ModuleHandle := DllCall("LoadLibrary","uint",&DllPath)
 Out32Proc := DllCall("GetProcAddress","uint",DllCall("GetModuleHandle","uint",&DllPath),"str","Out32")
 Inp32Proc := DllCall("GetProcAddress","uint",DllCall("GetModuleHandle","uint",&DllPath),"str","Inp32")
}

ReadParallelPort(Port = 0x378) ;Port address
{ ;Returns a string of binary representing the state of each pin, by position
 global Inp32Proc
 Data := DllCall(Inp32Proc,"UInt",Port)
 While, Data <> 0
  Data1 := (Data & 1) . Data1, Data //= 2
 Return, SubStr("00000000" . Data1,-7)
}

WriteParallelPort(Data = "",Port = 0x378) ;Data to write, Port address
{
 global Out32Proc
 Data := SubStr("00000000" . Data,-7), Temp1 := StrLen(Data) + 1, Data1 := 0
 Loop, Parse, Data
  SubStr(Data,Temp1 - A_Index,1) ? (Data1 += 1 << (A_Index - 1))
 Return, DllCall(Out32Proc,"Int",Port,"Int",Data1)
}

ReadParallelPort1(Port = 0x378)
{
 global Inp32Proc
 Return, DllCall(Inp32Proc,"UInt",Port)
}

WriteParallelPort1(Data = "",Port = 0x378)
{
 global Out32Proc
 Return, DllCall(Out32Proc,"Int",Port,"Int",Data)
}

Esc::ExitApp
