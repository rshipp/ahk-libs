/*
_______________________________________________________________________________
_______________________________________________________________________________

Title: AhkStdLibCollection Add entry
    This adds an entry to the database.
_______________________________________________________________________________
_______________________________________________________________________________

License:

(C) Copyright 2010 Tuncay
    
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

See the file COPYING.txt for license and copying conditions.
*/

#Include %A_ScriptDir%\..\lib
#Include ini.ahk
#Include uuid.ahk

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

FileSelectFile, db_file, , %A_ScriptDir%\..\libdb.ini
GoSub, init
Return

init:
Gui, Destroy
FileRead, db_content, %db_file%
db_format := ini_getSection(db_content, "0")
db_format_keys := ini_getAllKeyNames(db_format)

; Prepare Database List to add
database_entryList := ini_getAllSectionNames(db_content)
; Sort the list numerical and check for duplicates.
; Count only entries
database_entryCount := 0
idlist := ""
Loop, Parse, database_entryList, `,
{
    If A_LoopField Is Digit ; It counts the 0 entry also!!!
    {
        database_entryCount++
        idlist .= A_LoopField . "|"
    }
}
StringTrimRight, idlist, idlist, 1

y := 0
Loop, Parse, db_format_keys, `,
{
    If (A_Index = 10)
    {
        Gui, Add, Text, w100 x+8 y8, %A_LoopField%
    }
    Else
    {
        Gui, Add, Text, w100 y+8, %A_LoopField%
    }
    Gui, Add, Edit, w300 vKey_%A_LoopField%
}
GuiControl,, Key_GUID, % uuid()
Gui, Add, ComboBox, x8 vcurrentId gIdChoose, %idlist%
Gui, Add, Button, gNew x8, New
Gui, Add, Button, gAdd x+8, Add
Gui, Add, Button, gOpenFile x+32, Open File
Gui, Add, Button, gGuiClose x+8, Exit
currentId := database_entryCount
GoSub, GuiShow
Return

GuiShow:
Gui, Show, , % "id: " . currentId . " / " . database_entryCount - 1
Return

GuiClose:
ExitApp
Return

New:
db_newSection := ""
Loop, Parse, db_format_keys, `,
{
    GuiControl,, Key_%A_LoopField%
}
GuiControl,, Key_GUID, % uuid()
GuiControl, Text, currentId
currentId := database_entryCount
GoSub, GuiShow
Return

Add:
Gui, Submit, NoHide
Loop, Parse, database_entryList, `,
{
    If (ini_getValue(db_content, A_LoopField, "GUID") = Key_GUID)
    {
        MsgBox Entry with same GUID does already exist
        Return
    }
    Else If (ini_getValue(db_content, A_LoopField, "Source") = Key_Source)
    {
        MsgBox Entry with same FileName does already exist
        Return
    }
}
db_newSection := "[" . database_entryCount . "]`n"
Loop, Parse, db_format_keys, `,
{
    If Key_%A_LoopField% is Not Space
    {
        db_newSection .= A_LoopField . " = " . Key_%A_LoopField% . "`n"
    }
}
FileAppend, `n%db_newSection%, %db_file%
database_entryCount++
GoSub, New
Run, ..\LibraryExplorer.ahk
WinWaitActive, AutoHotkey Standard Library Collection,, 2
If (ErrorLevel = 0)
{
    SendInput, {End}
}
Return

OpenFile:
Run, %db_file%
Return

IdChoose:
Critical
Gui, Submit, NoHide
If (currentId = "")
{
    currentId := database_entryCount
}
db_newSection := ""
currentSection := ini_getSection(db_content, currentId)
Loop, Parse, db_format_keys, `,
{
    GuiControl,, Key_%A_LoopField%, % ini_getValue(currentSection, currentId, A_LoopField)
}
GoSub, GuiShow
Return