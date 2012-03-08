; ShellFileOperation by SKAN
; 2007, http://www.autohotkey.com/forum/viewtopic.php?p=133249#133249
ShellFileOperation( fileO=0x0, fSource="", fTarget="", flags=0x0, ghwnd=0x0 )     {

 If ( SubStr(fSource,0) != "|" )
      fSource := fSource . "|"

 If ( SubStr(fTarget,0) != "|" )
      fTarget := fTarget . "|"

 fsPtr := &fSource
 Loop, % StrLen(fSource)
  If ( *(fsPtr+(A_Index-1)) = 124 )
      DllCall( "RtlFillMemory", UInt, fsPtr+(A_Index-1), Int,1, UChar,0 )

 ftPtr := &fTarget
 Loop, % StrLen(fTarget)
  If ( *(ftPtr+(A_Index-1)) = 124 )
      DllCall( "RtlFillMemory", UInt, ftPtr+(A_Index-1), Int,1, UChar,0 )

 VarSetCapacity( SHFILEOPSTRUCT, 30, 0 )                 ; Encoding SHFILEOPSTRUCT
 NextOffset := NumPut( ghwnd, &SHFILEOPSTRUCT )          ; hWnd of calling GUI
 NextOffset := NumPut( fileO, NextOffset+0    )          ; File operation
 NextOffset := NumPut( fsPtr, NextOffset+0    )          ; Source file / pattern
 NextOffset := NumPut( ftPtr, NextOffset+0    )          ; Target file / folder
 NextOffset := NumPut( flags, NextOffset+0, 0, "Short" ) ; options

 DllCall( "Shell32\SHFileOperationA", UInt,&SHFILEOPSTRUCT )
 
Return NumGet( NextOffset+0 )
}