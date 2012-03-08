; #Include FileGetVersionInfo.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

SetBatchLines -1
Loop, %A_WinDir%\System32\*.??l
  Files .= "|" A_LoopFileLongPath
Files := A_AhkPath . Files

Loop, Parse, Files, |
  MsgBox, 0, % (PeFile:=A_LoopField)
  , % "FileDescription      `t:`t" FileGetVersionInfo( PeFile, "FileDescription"  ) "`n"
    . "FileVersion          `t:`t" FileGetVersionInfo( PeFile, "FileVersion"      ) "`n"
    . "InternalName         `t:`t" FileGetVersionInfo( PeFile, "InternalName"     ) "`n"
    . "LegalCopyright       `t:`t" FileGetVersionInfo( PeFile, "LegalCopyright"   ) "`n"
    . "OriginalFilename     `t:`t" FileGetVersionInfo( PeFile, "OriginalFilename" ) "`n"
    . "ProductName          `t:`t" FileGetVersionInfo( PeFile, "ProductName"      ) "`n"
    . "ProductVersion       `t:`t" FileGetVersionInfo( PeFile, "ProductVersion"   ) "`n`n`n"
    . "CompanyName          `t:`t" FileGetVersionInfo( PeFile, "CompanyName"      ) "`n"
    . "PrivateBuild         `t:`t" FileGetVersionInfo( PeFile, "PrivateBuild"     ) "`n"
    . "SpecialBuild         `t:`t" FileGetVersionInfo( PeFile, "SpecialBuild"     ) "`n"
    . "LegalTrademarks      `t:`t" FileGetVersionInfo( PeFile, "LegalTrademarks"  ) "`n"