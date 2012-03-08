/*
_______________________________________________________________________________
_______________________________________________________________________________

Title: AhkStdLibCollection get list
    This gets a list of all names of every entry in database.
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

db_file := A_ScriptDir . "\..\libdb.ini"
FileRead, db_content, %db_file%

ini_replaceSection(db_content, "0")
database_entryList := ini_getAllSectionNames(db_content)
database_entryCount := 0
idlist := ""
Loop, Parse, database_entryList, `,
{
    If A_LoopField Is Digit ; It counts the 0 entry also!!!
    {
        database_entryCount++
        idlist .= "[*]" . RegExReplace(ini_getValue(db_content, A_LoopField, "Source"), "S)\..*?$") . "`n"
    }
}
Sort, idlist, P4
StringTrimRight, idlist, idlist, 1
idlist := "[i]Count: " . database_entryCount . "[/i][list]" . idlist . "[/list]"
Clipboard := idlist
MsgBox Clipbaord updated:`n`n%idlist%
