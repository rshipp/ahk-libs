;?add 2010-09-06 MODIFIED for automation by Tuncay, all changes are marked with ;? comments.
;?add Text Compare v2 by jaco0646
;?add http://www.autohotkey.com/forum/viewtopic.php?t=13385
;?add Changes and modifications contain usage of commandline parameter, disabling gui and 
;?add outcommending some msgboxes. HTML output is forced. And small bug is eliminated too. :D

#SingleInstance force
#NoTrayIcon
#NoEnv
SetBatchLines, -1
Gui, +AlwaysOnTop +LastFound
;?add-begin
Path1=%1%
Path2=%2%
cmdline_outdir=%3%
NoWhite=0
Mismatch=0
HTML=1
;?add-end
;?mod-begin
;~ Gui, Add, Edit, w500 cGray vPath1, %cmdline_file1% ;?original Enter file path #1 here.
;~ Gui, Add, Edit, w500 cGray vPath2, %cmdline_file2% ;?original Enter file path #2 here.
;~ Gui, Add, Button, w50 gGuiSubmit, OK
;~ Gui, Add, Button, w50 gGuiClose x+10, Cancel
;~ Gui, Font, Bold
;~ Gui, Add, Button, gHelp x+10, ?
;~ Gui, Font, Norm
;~ Gui, Add, Checkbox, x+20 vNoWhite, Ignore white space
;~ Gui, Add, Checkbox, x+10 vMismatch, Report mismatches
;~ Gui, Add, Checkbox, x+10 vHTML, Output in HTML
;~ Gui, Show,,Text Compare
;~ GuiControl, Focus, HTML
;?mod-end
WinGet, WinID, ID
SetTimer, Edit
;?add-begin
GoSub, GuiSubmit
ExitApp
;?add-end
return
GuiClose:
ExitApp
Help:
Run,http://www.autohotkey.net/~jaco0646/Text Compare Help.html
return
GuiDropFiles:
If A_EventInfo > 2
{
 Gui, +OwnDialogs
 MsgBox,48,Text Compare, More than 2 items were dropped.
 return
}
If A_EventInfo = 2
 Loop,Parse,A_GuiEvent,`n,`r
 {
  GuiControl,Font,Path%A_Index%
  GuiControl,,Path%A_Index%,%A_LoopField%
 }
Else If (A_GuiControl="path1") OR (A_GuiControl="path2")
{
 GuiControl,Font,%A_GuiControl%
 GuiControl,,%A_GuiControl%,%A_GuiEvent%
}
return
GuiSubmit:
SetTimer, Edit, Off
Gui,Submit
Gui,Destroy
Loop,2
{
 IfNotExist,% path%A_Index%
 {
  MsgBox,16,Text Compare,% "The path does not exist:`n" path%A_Index%
  ExitApp
 }
 FileGetAttrib, attribs,% path%A_Index%
 IfInString, attribs, D
 {
  MsgBox,16,Text Compare,% "The path does not specify a file:`n" path%A_Index%
  ExitApp
 }
 StringRight,slash,Path%A_Index%,1
 If slash = \
  StringTrimRight,Path%A_Index%,Path%A_Index%,1
}
Loop
{
 match=0
 FileReadLine, line1, %Path1%, %A_Index%
 Error1 := ErrorLevel
 FileReadLine, line2, %Path2%, %A_Index%
 Error2 := ErrorLevel
 If (Error1) AND (Error2)
  break
 If NoWhite
 {
  NW1 := RegExReplace(line1,"[`t ]+")
  NW2 := RegExReplace(line2,"[`t ]+")
  If (NW1 = NW2)
   continue
  If NW1=
   Error1=1
  If NW2=
   Error2=1
 }
 Else If (line1 = line2)
  continue
 If Error1
  match+=2
 If Error2
  match++
 If file1=
 {
  FileRead, file1, %Path1%
  FileRead, file2, %Path2%
  If NoWhite
  {
   file1 := RegExReplace(file1,"[`t ]+")
   file2 := RegExReplace(file2,"[`t ]+")
  }
 }
 If Mismatch
 {
  num3=#
  num4=#
 }
 line1copy := NoWhite=1 ? NW1:line1
 line2copy := NoWhite=1 ? NW2:line2
 If Error2=0
  Loop, Parse, file1, `n,`r
   If (A_LoopField = line2copy)
   {
    match++
    num4 := A_Index
    break
   }
 If Error1=0
  Loop, Parse, file2, `n,`r
   If (A_LoopField = line1copy)
   {
    match+=2
    num3 := A_Index
    break
   }
 If (match = 3) AND !(Mismatch)
  continue
 If doc=
 {
  SplitPath,Path1,,,,NoExt1
  SplitPath,Path2,,,,NoExt2
  ext := HTML=1 ? ".html":".txt"
  ;?mod-begin
  doc := cmdline_outdir "\" NoExt1 "-vs-" NoExt2 ext ;?original A_ScriptDir
  ;?mod-end
  If HTML
  {
   IfNotExist,%doc%
    FileAppend,
    (LTrim
     <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
     <html>
     <head>
     <title>%NoExt1%-vs-%NoExt2%</title>
     </head>
     <body bgcolor="F5F5DC" text="000000">
     <font color="0000FF">
     File1 = %Path1%<BR>File2 = %Path2%
     </font>
     <font face="Lucida Console">
     <P><DL>
    )
    ,%doc%
  }
  Else FileAppend, File1 = %Path1%`r`nFile2 = %Path2%`r`n`r`n, %doc%
 }
 i++
 num := A_Index
 If (Mismatch=1) AND (match != 3)
 {
  num5 := "/" num ":" num3
  num6 := "/" num ":" num4
 }
 If HTML
 {
  Loop, 2
  {
   ;?edit-begin added semikolon to all
   StringReplace, line%A_Index%, line%A_Index%, &, &amp;, All
   StringReplace, line%A_Index%, line%A_Index%, <, &lt;, All
   StringReplace, line%A_Index%, line%A_Index%, >, &gt;, All
   StringReplace, line%A_Index%, line%A_Index%, %A_Space%, &nbsp;, All
   StringReplace, line%A_Index%, line%A_Index%, %A_Tab%, &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;, All
   ;?edit-end
  }
  If match = 0
   FileAppend,
   (LTrim
    <dt><font color="8B0000">Line %num%<BR></font>
    <dd><font color="008000">File1:</font> %line1%<BR>
        <font color="008000">File2:</font> %line2%<BR>
   )
   ,%doc%
  Else If match = 1
   FileAppend,
   (LTrim
    <dt><font color="8B0000">Line %num%%num6%<BR></font>
    <dd><font color="008000">Unique to File1:</font> %line1%<BR>
   )
   ,%doc%
  Else If match = 2
   FileAppend,
   (LTrim
    <dt><font color="8B0000">Line %num%%num5%<BR></font>
    <dd><font color="008000">Unique to File2:</font> %line2%<BR>
   )
   ,%doc%
  Else If match = 3
  {
   If (NoWhite) AND !(NW1)
    FileAppend,
   (LTrim
    <dt><font color="8B0000">Line %num%:%num3%/%num%:%num4%<BR></font>
    <dd><font color="008000">Mismatch:</font> %line2%<BR>
   )
   ,%doc%
   Else
    FileAppend,
   (LTrim
    <dt><font color="8B0000">Line %num%:%num3%/%num%:%num4%<BR></font>
    <dd><font color="008000">Mismatch:</font> %line1%<BR>
   )
   ,%doc%
  }
 }
 Else
 {
  If match = 0
   FileAppend, Line %num%`r`n%A_Tab%File1>> %line1%`r`n%A_Tab%File2>> %line2%`r`n, %doc%
  Else If match = 1
   FileAppend, Line %num%%num6%`r`n%A_Tab%Unique to File1>> %line1%`r`n, %doc%
  Else If match = 2
   FileAppend, Line %num%%num5%`r`n%A_Tab%Unique to File2>> %line2%`r`n, %doc%
  Else If match = 3
  {
   If Mismatch
   {
    If (NoWhite) AND !(NW1)
     FileAppend, Line %num%:%num3%/%num%:%num4%`r`n%A_Tab%Mismatch>> %line2%`r`n, %doc%
    Else
     FileAppend, Line %num%:%num3%/%num%:%num4%`r`n%A_Tab%Mismatch>> %line1%`r`n, %doc%
   }
   Else i--
  }
 }
}
If i
{
 If HTML
  FileAppend, </DL>%i% differences.<P><HR><DL>, %doc%
 Else FileAppend, `r`n%i% differences.`r`n`r`n, %doc%
 ;?out MsgBox,48,Text Compare
 ;?out ,%i% differences were written to the Final Report file:`n`n%NoExt1%`n-vs-`n%NoExt2%
}
;?out Else MsgBox,64,Text Compare, These files are identical:`n`n%Path1%`n%Path2%
ExitApp
Edit:
GuiControlGet,Focus,FocusV
Loop,2
{
 GuiControlGet,Contents,,Path%A_Index%
 If Focus = Path%A_Index%
 {
  If Contents = Enter file path #%A_Index% here.
  {
   GuiControl,,Path%A_Index%
   GuiControl,Font,Path%A_Index%
  }
 }
 Else If Contents=
 {
  Gui,Font,cGray
  GuiControl,Font,Path%A_Index%
  GuiControl,,Path%A_Index%,Enter file path #%A_Index% here.
  Gui,Font
 }
}
return