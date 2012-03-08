/*
_______________________________________________________________________________
_______________________________________________________________________________

Title: AhkStdLibCollection Explorer
    Explorer and installer of the libraries from database.
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

About: Introduction
    There are some really useful libraries outside. I have tried to collect
    some of the best of them and want to redistribute the collection in a
    single downloadable file. This makes the install process easy. Also 
    every project does have a description and links to their home threads.
    
    The database is in a single ini file. It contains every descriptions and
    meta data. The files are in flat folder structures. Everything very
    simple. This script is just one possible way to use the collection.
    
    You can edit in the Gui the examples, without touching the original ones.
    The #include file will be added automatically and the execution is done 
    in the temp directory. The following code will be added to begin of script
    dynamically:
    
    > #Include %path_lib%
    > #Include %filename%
    >

    Where filename is the name of the library and pathlib the directory of 
    the library from this collection. Any change in the TAB control of that
    Example is temporary only.

Additional Helper Tools:
    Uses a modified version from DerRaphael`s script "Doc-O-Matic" to generate 
    an "on the fly"-documentation.
    
    Uses a modified version from jaco0646`s script "Text Compare v2" to show up
    the differences of installed library against the one from the collection.
    
    Besides these tools, this script uses some of the libraries from the collection.

Links:
    * Discussion: [http://www.autohotkey.com/forum/viewtopic.php?p=335088]
    * Discussion / German: [http://de.autohotkey.com/forum/viewtopic.php?t=6437]
    * License: [http://www.gnu.org/licenses/gpl-3.0.html]
    * Doc-O-Matic: [http://www.autohotkey.com/forum/viewtopic.php?t=54846]
    * Text Compare v2: [http://www.autohotkey.com/forum/viewtopic.php?t=13385]

Developers:
    * Tuncay (Author)

License:
    GNU General Public License 3.0 or higher [http://www.gnu.org/licenses/gpl-3.0.html]
    
Category:
    FileSystem

Type:
    Application

Tested AutoHotkey Version:
    1.0.48.05

Tested Platform:
    XP, Vista, 7

Standalone (such as no need for extern file or library):
    No

StdLibConform (such as use of prefix and no globals use):
    No

Related:
    *StdLib related topics*
    * stdLib: call for information by DerRaphael: [http://www.autohotkey.com/forum/viewtopic.php?t=54047]
*/

#Include %A_ScriptDir%\lib
#Include ini.ahk
#Include Anchor.ahk
#Include MD5.ahk
#Include ProcessInfo.ahk
#Include EmptyMem.ahk
#Include ConnectedToInternet.ahk
#Include InternetFileRead.ahk

;  ------------------------------------------
;                  init
;  ------------------------------------------

#NoEnv
#NoTrayIcon
#SingleInstance force
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1 ; At end of init set to 0.
Suspend, On

; Global variables
config := ""                ; Contains the initial settings of script in ini format.
database := ""              ; Content of the libdb ini file.
database_header := ""       ; Copy of header section from database.
database_fileNames := ""    ; A comma separated list of all filenames from database.
                            ;   First comma is needed later with last comma.
currentItem := 0            ; The currently selected item id from listview.
                            ;   This will be updated with every call of Lv_Database.
lastItem := 1               ; Only needed with Lv_Database. (privat usage)
lastTab := ""               ; Only needed with Lv_Database. (privat usage)
Lv_DatabaseCall := False    ; Must be set to True prior calling Lv_Database by hand.
InstOrDeinst := True        ; Indicates that something was installed or deinstalled.
                            ;   Will be set to false after check. true for first check.
runningPidList := ";"       ; This is a list of all running samples. (first ; is needed)

; These are lists for use with setGuiFont().
standardFonts := "Arial, Segoe UI, Trebuchet MS"        ; Normal gui.
sourceFonts := "Courier New, Lucida Console"            ; Code.

; Main
OnExit, Exit
config := getConfig()                                   ; Retrieve initial settings in ini format.
loadDatabase(database)                                  ; Load libdb file into variable and update 
                                                        ;   the File > libdb in config.
database_header := ini_getSection(database, "Header")   ; Copy header prior to deleting it.
removeUnNeededSections(database)                        ; Delete all non script entries.
ini_exportToGlobals(database, false, "libdb")           ; Populate all entries to global array.

; ---
; The following part was copied from AGU`s script.
; http://www.autohotkey.com/forum/viewtopic.php?p=37633#37633
; Begin
  ; Retrieve scripts PID
  Process, Exist
  pid_this := ErrorLevel
 
  ; Retrieve unique ID number (HWND/handle)
  WinGet, hw_gui, ID, ahk_class AutoHotkeyGUI ahk_pid %pid_this%
 
  ; Call "HandleMessage" when script receives WM_SETCURSOR message
  WM_SETCURSOR = 0x20
  OnMessage( WM_SETCURSOR, "HandleMessage" )
 
  ; Call "HandleMessage" when script receives WM_MOUSEMOVE message
  WM_MOUSEMOVE = 0x200
  OnMessage( WM_MOUSEMOVE, "HandleMessage" )
; End
; ---

; Show Gui and suspend off.
Title := buildMainGui()
checkForUpdate("VERSION.txt")
Menu, Tray, Icon
Suspend, Off
showGui(Title, 1) 
Sleep, 200
EmptyMem()
SetBatchLines, 0

RETURN ; End of AutoExecution.

;  ------------------------------------------
;           Gui related routines
;  ------------------------------------------

checkForUpdate(_file)
{
    Global config, database_header
    Update := False
    libdb := ini_getValue(config, "File", "libdb")
    checkForUpdate := ini_getValue(database_header, "HEADER", "checkForUpdate")
    If (checkForUpdate = "-1")
    {
        MsgBox, 3, Ahk Standard Library Collection - Version Check, The script can check at startup silently (and fast)`n for new available version of the collection.`n`nTo change this setting back`, set in libdb.ini the key:`n`n    CheckForUpdate `n`nto value: `n`n    0=no check  (No)`n    1=check  (Yes)`n    -1=ask this  (Cancel)`n`nShould it check for new version?
        IfMsgBox, Yes
        {
            checkForUpdate := 1
            ini_replaceValue(database_header, "HEADER", "checkForUpdate", "1")
            IniWrite, 1, %libdb%, HEADER, checkForUpdate
        }
        IfMsgBox, No
        {
            checkForUpdate := 0
            ini_replaceValue(database_header, "HEADER", "checkForUpdate", "0")
            IniWrite, 0, %libdb%, HEADER, checkForUpdate
        }
        IfMsgBox, Cancel
        {
            checkForUpdate := -1
            ini_replaceValue(database_header, "HEADER", "checkForUpdate", "-1")
            IniWrite, -1, %libdb%, HEADER, checkForUpdate
        }
    }
    If (checkForUpdate && ConnectedToInternet())
    {
        filePath := ini_getValue(database_header, "HEADER", "Location")
        SplitPath, filePath,, fileDir
        If (InternetFileRead(uploadedVersion, fileDir . "/" . _file))
        {
            FileRead, thisVersion, %A_ScriptDir%\%_file%
            If (uploadedVersion > thisVersion)
            {
                GuiControl, Show, Txt_openUpdate
                Update := True
            }
        }
    }
    return Update
}

showGui(_GuiTitle, _selectEntry = 1)
{
    Gui, Show, , %_GuiTitle%
    selectEntry(_selectEntry)
    GuiControl, Focus, Ed_Search
}

selectEntry(_selectEntry = 1)
{
    Global Lv_Database
    LV_Modify(_selectEntry, "+Focus +Select +Vis")
    GoSub, Lv_Database
    GuiControl, Focus, Lv_Database
}

; Creates the Main Gui from scratch.
buildMainGui()
{
    Global
    Local GuiTitle              ; Return value. The calculated title of Gui.
    
    ; Following variables are used to add controls.
    Local Lv_DatabaseRows := 12 ; Count of entries in the listview.
    Local mx := 8, mx2 := 16    ; Default margin x for controls.
    Local my := 8, my2 := 16    ; Default margin x for controls.
    Local x                     ; Dynamically expressed current x position for controls.
    Local w                     ; Dynamically expressed current width for controls.
    Local h                     ; Dynamically expressed current hight for controls.
    Local Base_w := 540         ; Width of widest control.
    Local Lv_w := 0             ; Dynamically expressed width of Lv control.
    Local SmallButton_w := 24   ; Width of small buttons.
    Local Button_w := 140       ; Width of all button controls
    Local Info_h := 200         ; Height of the Info Tab control
    
    ; Following variables are used for filling the ListView.
    Local database_entryList
    Local database_entryCount
    Local prefixOrFunction
    Local date
    Local license 
    
    Gui, 1:+Default
    Gui, +Resize +MinSize
    Gui, Margin, %mx%, %my%
    setGuiFont("default")
    setGuiFont(standardFonts, "norm")
    
    ; Add Gui Header
    Gui, Add, Text, vTxt_CurrentAhkVersion 0x80
        , % "Your AutoHotkey version is " . ini_getValue(config, "Version", "currentAhk") . " | Go to "
    setGuiFont("", "cblue underline")
    Gui, Add, Text, x+4 +0x400 0x80 gTxt_openHome vTxt_openHome, Home of this Collection
    setGuiFont("default", "norm")
    Gui, Add, Text, x+0, % " by " . ini_getValue(database_header, "HEADER", "Creator")
    setGuiFont("", "bold cRed")
    Gui, Add, Text, x+36 +0x400 0x80 +Hidden vTxt_openUpdate, * Update available *
    setGuiFont("", "bold s13 cNavy")
    w := Base_w
    Gui, Add, Text, w%w% x%mx% y+%my% vTxt_Title 0x80
    setGuiFont("default")
    setGuiFont("", "norm")
    
    w := 64
    Gui, Add, Text, w%w% x%mx%, Search:
    w := Base_w - w - (2 * SmallButton_w) - (3 * mx) + 3
    Gui, Add, Edit, w%w% x+%mx% gEd_Search vEd_Search
    Gui, Add, Button, w%SmallButton_w% x+%mx% gBtn_CleanSearch vBtn_CleanSearch, X
    Gui, Add, Button, w%SmallButton_w% x+%mx% gBtn_HelpSearch vBtn_HelpSearch, ?    
    Gui, Add, Checkbox, x%mx% y+%my% +Check3 +Checked-1 gChk_isStandalone vChk_isStandalone, Standalone 
    Gui, Add, Checkbox, x+%mx% +Check3 +Checked-1 gChk_isStdlibConform vChk_isStdlibConform, StdlibConform 
    
    ; Prepare Database List to add
    database_entryList := ini_getAllSectionNames(database, database_entryCount)
    ; Sort the list numerical and check for duplicates.
    Sort, database_entryList, D`, N U
    If (ErrorLevel > 0) ; Sort has detected duplicate.
    {
        MsgBox, 16, Fatal error: Database conflict
            , There is a conflict with the id of an entry.`n%ErrorLevel% duplicate ids!`n`nList: %database_entryList%
        ExitApp
    }
    
    ; Add Database List
    w := Base_w - Button_w - (mx / 2)
    Lv_w := w
    Gui, Add, ListView, w%w% x%mx% r%Lv_DatabaseRows% +Hidden +Section +AltSubmit -Multi Count%database_entryCount% gLv_Database2 vLv_Database2
        , Id|Prefix/Func|Name|Revision|Last Modified|Author|License|Category|is Standalone|is StdlibConform|Filename|MD5 (file hash)|GUID (project id)
    Gui, Add, ListView, xp yp w%w% r%Lv_DatabaseRows% +Section +AltSubmit -Multi Count%database_entryCount% gLv_Database vLv_Database
        , Id|Prefix/Func|Name|Revision|Last Modified|Author|License|Category|is Standalone|is StdlibConform|Filename|MD5 (file hash)|GUID (project id)
    GuiControl, -Redraw, Lv_Database
    ; Fill the listview with all entries from database.
    Loop, Parse, database_entryList, `,
    {
        ; Do not add entries without a GUID.
        If (libdb_%A_LoopField%_GUID = "") 
        {
            Continue
        }
        convertBracketsForAllFields(A_LoopField)
        If ((prefixOrFunction := libdb_%A_LoopField%_Prefix) = "")
        {
            prefixOrFunction := RegExReplace(libdb_%A_LoopField%_Source, "S)\..*?$") . "()"
        }
        Else
        {
            prefixOrFunction .= "_*"
            StringUpper, prefixOrFunction, prefixOrFunction
        }
        If ((date := libdb_%A_LoopField%_Date) != "")
        {
            FormatTime, date, %date%, yyyy-MM
        }
        If ((license := libdb_%A_LoopField%_License) = "")
        {
            license := "<Unknown>"
            libdb_%A_LoopField%_LicenseSource := ini_getValue(config, "File", "defaultLicense")
        }
        LV_Add(""
            , A_LoopField
            , prefixOrFunction
            , libdb_%A_LoopField%_Abstract
            , libdb_%A_LoopField%_Revision
            , date
            , libdb_%A_LoopField%_Author
            , license
            , libdb_%A_LoopField%_Category
            , libdb_%A_LoopField%_Standalone
            , libdb_%A_LoopField%_StdlibConform
            , libdb_%A_LoopField%_Source
            , MD5_File(ini_getValue(config, "Dir", "lib") . "\" . libdb_%A_LoopField%_Source)
            , libdb_%A_LoopField%_GUID)
        StringReplace, libdb_%A_LoopField%_Description, libdb_%A_LoopField%_Description, ``n, `n, All
        StringReplace, libdb_%A_LoopField%_Notes, libdb_%A_LoopField%_Notes, ``n, `n, All
        database_fileNames .= libdb_%A_LoopField%_Source . ","
    }
    StringTrimRight, database_fileNames, database_fileNames, 1 ; Delete last comma.
    ; Adjust list headers
    LV_ModifyCol("", "AutoHdr")
    Loop, 13
    {
        LV_ModifyCol(A_Index, "AutoHdr Logical")
    }
    LV_ModifyCol(1, "AutoHdr Integer")
    LV_ModifyCol(2, "Logical 100")
    LV_ModifyCol(6, "Logical 140")
    LV_ModifyCol(8, "Logical 140")
    LV_Modify(1, "+Focus +Select")
    GuiControl, +Redraw, Lv_Database
    
    ; Add Info Tabs
    w := Base_w + 4
    Gui, Add, Tab2, w%w% h%Info_h% gTab_Info vTab_Info, Description|Example|Source|Notes|Dependency|Installed Libs
    w := Base_w
    h := Info_h - 24
    Gui, Tab, Description
    Gui, Add, Edit, w%w% h%h% x+0 y+0 +ReadOnly vEd_InfoDescription
    setGuiFont(sourceFonts)
    Gui, Tab, Example
    Gui, Add, Edit, w%w% h%h% x+0 y+0 -Wrap +HScroll vEd_InfoExample gEd_InfoExample
    Gui, Tab, Source
    Gui, Add, Edit, w%w% h%h% x+0 y+0 +ReadOnly -Wrap +HScroll vEd_InfoSource
    setGuiFont(standardFonts)
    Gui, Tab, Notes
    Gui, Add, Edit, w%w% h%h% x+0 y+0 +ReadOnly vEd_InfoNotes
    Gui, Tab
    Gui, Tab, Dependency
    Gui, Add, Edit, w%w% h%h% x+0 y+0 +ReadOnly vEd_InfoDependency
    Gui, Tab
    Gui, Tab, Installed Libs
    Gui, Add, Edit, w%w% h%h% x+0 y+0 +ReadOnly vEd_InfoInstalledLibs, % getListOfInstalledLibs()
    Gui, Tab
    
    w := Button_w
    x := Lv_w + mx2
    
    ; Add Other Controls
    setGuiFont("", "bold cRed")
    Gui, Add, Text, w%w% x%x% yp-44 0x80 +Right +BackgroundTrans +Hidden vTxt_Warning
    setGuiFont("default")
    setGuiFont("", "norm")
    
    ; Add Action Buttons
    w := w/2 - mx/2
    Gui, Add, Button, w%w% x%x% ys0 Section gBtn_Install vBtn_Install, Install
    Gui, Add, Button, w%w% xp0 yp0 +Hidden gBtn_deinstall vBtn_deinstall, Deinstall
    Gui, Add, Button, w%w% x+%mx% gBtn_copyTo vBtn_copyTo, Copy To
    Gui, Add, Button, w%w% xs0 gBtn_openDocomatic vBtn_openDocomatic, Analyze
    Gui, Add, Button, w%w% x+%mx% +Disabled gBtn_openTextcompare vBtn_openTextcompare, Compare
    w := Button_w
    Gui, Add, Button, w%w% xs0 gBtn_openDoc vBtn_openDoc, Open Help
    Gui, Add, Button, w%w% gBtn_openTopic vBtn_openTopic, Open Discussion
    Gui, Add, Button, w%w% gBtn_openLicense vBtn_openLicense, Show License
    Gui, Add, Button, w%w% gBtn_runExample vBtn_runExample, Run Example
    
    Return getGuiTitle(database_entryCount)
}

updateGuiTitle:
SetBatchLines, -1
Gui, Show,, % getGuiTitle()
Return

getGuiTitle(_updateCount = "")
{
    Global database_header
    Static currentCount := 0
    If (_updateCount != "")
    {
        currentCount := _updateCount
    }
    date := ini_getValue(database_header, "HEADER", "Timestamp")
    FormatTime, date, %date%, yyyy MMM
    If (GuiTitle = "")
    {
        AhkTypeCompatible := ini_getValue(database_header, "HEADER", "AhkTypeCompatible")
        If (AhkTypeCompatible != "")
        {
            AhkTypeCompatible := " - " . AhkTypeCompatible
        }
        GuiTitle := ini_getValue(database_header, "HEADER", "Title")
            . AhkTypeCompatible . ", " . date
            . " ~ Libs: "
    }
    GuiTitle .= LV_GetCount() . " / " . currentCount
    Return GuiTitle
}

convertBracketsForAllFields(_source)
{
    Global
    StringReplace, libdb_%_source%_Author, libdb_%_source%_Author, ``{, [, All
    StringReplace, libdb_%_source%_Author, libdb_%_source%_Author, ``}, ], All
    
    StringReplace, libdb_%_source%_LicenseSource, libdb_%_source%_LicenseSource, ``{, [, All
    StringReplace, libdb_%_source%_LicenseSource, libdb_%_source%_LicenseSource, ``}, ], All
        
    StringReplace, libdb_%_source%_Description, libdb_%_source%_Description, ``{, [, All
    StringReplace, libdb_%_source%_Description, libdb_%_source%_Description, ``}, ], All
    
    StringReplace, libdb_%_source%_Notes, libdb_%_source%_Notes, ``{, [, All
    StringReplace, libdb_%_source%_Notes, libdb_%_source%_Notes, ``}, ], All
}

; Changes the font of the current or selected font for subsequent controls
; in a Gui. The default value changes back to original font of OS. An empty
; value uses last setted value (font or option). The "default" value does 
; not change the last used font.
; The fonts are comma separated list of font names.
; > setGuiFont("Lucida Console, Verdana")     ; Fonts to use.
; > setGuiFont("")                            ; Last used setted fonts.
; > setGuiFont("default")                     ; Restores system default.
setGuiFont(_fonts = "default", _options = "", _gui = "")
{
    Static lastFonts := ""
    Static lastOptions := ""
    If (_fonts = "")
    {
        _fonts := lastFonts
    }
    Else If (_fonts = "default")
    {
        _fonts := ""
    }
    Else
    {
        lastFonts := _fonts
    }
    If (_options = "")
    {
        _options := lastOptions
    }
    Else
    {
        lastOptions := _options
    }
    If (_gui)
    {
        If (_fonts = "")
        {
            Gui, %_gui%:Font
        }
        Else
        {
            Loop, Parse, _fonts, CSV, %A_Space%
            {
                Gui, %_gui%:Font, %_options%, %A_LoopField%
            }
        }
    }
    Else
    {
        If (_fonts = "")
        {
            Gui, Font
        }
        Else
        {
            Loop, Parse, _fonts, CSV, %A_Space%
            {
                Gui, Font, %_options%, %A_LoopField%
            }
        }
    }
}

;  ------------------------------------------
;                Gui events
;  ------------------------------------------

GuiSize:
SetBatchLines, -1
Gui, 1:+Default
Anchor("Txt_CurrentAhkVersion", "w")
Anchor("Txt_openUpdate", "x")
Anchor("Txt_Title", "w")
Anchor("Ed_Search", "w")
Anchor("Btn_CleanSearch", "x")
Anchor("Btn_HelpSearch", "x")
Anchor("Btn_Install", "x")
Anchor("Btn_deinstall", "x")
Anchor("Btn_copyTo", "x")
Anchor("Btn_openDoc", "x")
Anchor("Btn_openDocomatic", "x")
Anchor("Btn_openTextcompare", "x")
Anchor("Btn_openTopic", "x")
Anchor("Btn_openLicense", "x")
Anchor("Btn_runExample", "x")
Anchor("Txt_Warning", "x")
Anchor("Lv_Database", "w")
Anchor("Lv_Database2", "w")
Anchor("Tab_Info", "wh")
Anchor("Ed_InfoDescription", "wh")
Anchor("Ed_InfoExample", "wh")
Anchor("Ed_InfoSource", "wh")
Anchor("Ed_InfoNotes", "wh")
Anchor("Ed_InfoInstalledLibs", "wh")
Anchor("Ed_InfoDependency", "wh")
If (A_TickCount - GuiSize_LastTime > 100)
{
    updateTxtTitle()
    WinSet, Redraw
}
GuiSize_LastTime := A_TickCount
Return

GuiClose:
GoSub, Exit
Return

;  ------------------------------------------
;            Gui Control events
;  ------------------------------------------

Lv_Database:
Critical
Gui, Submit, NoHide
If (A_GuiEvent == "DoubleClick" || A_GuiEvent == "R")
{
    BackupClipboard := ClipboardAll
    MsgBox, 68, Copied to Clipboard, % "(Clipboard Updated):`n`n---`n`n" . getCurrentItemToClipboard(!(A_GuiEvent == "R")) . "`n`n---`n`n(Restore Clipboard?)" 
    IfMsgBox, Yes
    {
        Clipboard := BackupClipboard
    }
}
Else If (A_GuiEvent == "Normal" || A_GuiEvent == "A" || A_GuiEvent == "I" || A_GuiEvent == "F" || Lv_Database2CalledFrom = true)
{
    Lv_Database2CalledFrom := False
    If (Lv_DatabaseCall = true)
    {
        GuiControl, Hide, Txt_Warning
        Lv_DatabaseCall := False
    }
    Else
    {
        LV_GetText(currentItem, A_EventInfo > 0 ? A_EventInfo : lastItem, 1)
    }
    If ((currentItem > 0 && currentItem != lastItem) || Tab_Info != lastTab)
    {
        GuiControl, Hide, Txt_Warning
        updateTxtTitle()
        If (Tab_Info = "Description")
        {
            GuiControl,, Ed_InfoDescription, % libdb_%currentItem%_Description
        }
        Else If (Tab_Info = "Example")
        {
            FileRead, file, % ini_getValue(config, "Dir", "samp") . "\" . libdb_%currentItem%_Sample
            GuiControl,, Ed_InfoExample, %file%
        }
        Else If (Tab_Info = "Source")
        {
            FileRead, file, % ini_getValue(config, "Dir", "lib") . "\" . libdb_%currentItem%_Source
            GuiControl,, Ed_InfoSource, %file%
        }
        Else If (Tab_Info = "Notes")
        {
            If (libdb_%currentItem%_Notes!="")
            {
                GuiControl,, Ed_InfoNotes, % libdb_%currentItem%_Notes
            }
            else
            {
                GuiControl,, Ed_InfoNotes, <no additional notes>
            }
        }
        Else If (Tab_Info = "Dependency")
        {
            If (libdb_%currentItem%_Dependency!="")
            {
                GuiControl,, Ed_InfoDependency, % RegExReplace(libdb_%currentItem%_Dependency, "`a)\R", "`n")
            }
            else
            {
                GuiControl,, Ed_InfoDependency, <no dependency>
            }
        }
        Else If (Tab_Info = "Installed Libraries")
        {
            If (InstalledOrDeinstalled)
            {
                GuiControl,, Ed_InfoInstalledLibs, % getListOfInstalledLibs()
            }
        }
        IfExist, % ini_getValue(config, "Dir", "stdlib") . "\" . libdb_%currentItem%_Source
        {
            GuiControl, Hide, Btn_Install
            GuiControl, Show, Btn_DeInstall
            If (RegExMatch(Ed_InfoInstalledLibs, "Sm)\*\s+\Q" . libdb_%currentItem%_Source . "\E"))
            {
                GuiControl, Enable, Btn_openTextcompare
            }
            else
            {
                GuiControl, Disable, Btn_openTextcompare
            }
        }
        Else
        {
            GuiControl, Show, Btn_Install
            GuiControl, Hide, Btn_DeInstall
            GuiControl, Disable, Btn_openTextcompare
        }
        GuiControl, % (libdb_%currentItem%_Documentation = "" ? "Disable" : "Enable"), Btn_openDoc
        GuiControl, % (libdb_%currentItem%_Discussion = "" ? "Disable" : "Enable"), Btn_openTopic
        GuiControl, % (libdb_%currentItem%_LicenseSource = "" ? "Disable" : "Enable"), Btn_openLicense
        ;GuiControl, % (libdb_%currentItem%_Sample = "" ? "Disable" : "Enable"), Btn_runExample
    }
    lastItem := currentItem
    lastTab := Tab_Info
}
If (currentItem = 0)
{
    currentItem := 1
    lastItem := 1
}
Return

getCurrentItemToClipboard(_withKeyNames = true, _separator = "=", _newLine = "`r`n")
{
    global
    Local x
    Local c
    Clipboard := ""
    Loop, 13
    {
        If (_withKeyNames)
        {
            LV_GetText(c, 0, A_Index)
            x .= c . _separator
        }
        LV_GetText(c, currentItem, A_Index)
        x .= c . _newLine
    }
    StringTrimRight, x, x, % StrLen(_newLine)
    Clipboard := x
    Return x
}

updateTxtTitle()
{
    Global
    GuiControl,, Txt_Title, % libdb_%currentItem%_Abstract . " by " . RegExReplace(libdb_%currentItem%_Author, "S),.*")
}

Tab_Info:
Lv_DatabaseCall := True
GuiControl, Focus, Lv_Database
Return

Ed_Search:
Critical
Gui, Submit, NoHide
Ed_Search()
Return

getGlobal(_var)
{
    Global
    Return (%_var%)
}

; searchType:
;   0=normal
;   1=id
;   2=md5
;   3=guid
;   4=files
Ed_Search(_forceSearch = False)
{
    Global config
    Global Lv_Database
    Global Lv_Database2
    Global Ed_Search
    Global Chk_isStandalone
    Global Chk_isStdlibConform
    
    Gui_SearchIn := ini_getValue(config, "Gui", "SearchIn")
    Gui_SearchAddInfo := ini_getValue(config, "Gui", "SearchAddInfo")
    If (Ed_Search != "" || _forceSearch = True)
    {
        searchType := 0 ; normal
        Ed_Search = %Ed_Search%
        StringLen, SearchLen, Ed_Search
        If (SubStr(Ed_Search, 1, 1) = ">")
        {
            searchType := 4 ; source
            StringTrimLeft, Ed_Search, Ed_Search, 1
            Ed_Search = %Ed_Search%
            Ed_Search := RegExReplace(Ed_Search, "S)(\s)+", "$1")
        }
        Else If (SearchLen < 4 && RegExMatch(Ed_Search, "S)^\d+$"))
        {
            searchType := 1 ; id
            If (SearchLen = 1)
            {
                Ed_Search := "0" . Ed_Search
            }
        }
        Else If (SearchLen = 32 && RegExMatch(Ed_Search, "S)^\w+$"))
        {
            searchType := 2 ; md5
        }
        Else If (SearchLen = 36 && RegExMatch(Ed_Search, "S)^\w{8}-\w{4}-\w{4}-\w{4}-\w{12}$"))
        {
            searchType := 3 ; guid
        }
        GuiControl, -Redraw, Lv_Database2
        Gui, ListView, Lv_Database2
        LV_Delete()
        Gui, ListView, Lv_Database
        Loop, % LV_GetCount()
        {
            row := A_Index
            Gui, ListView, Lv_Database
            Loop, 13
            {
                LV_GetText(col%A_Index%, row, A_Index)
            }
            If ((Chk_isStandalone = 0 && col9 != "no")
                || (Chk_isStandalone = 1 && col9 != "yes")
                || (Chk_isStdlibConform = 0 && col10 != "no")
                || (Chk_isStdlibConform = 1 && col10 != "yes"))
            {
                Continue
            }
            Haystack := ""
            VarSetCapacity(Haystack, 512, "")
            If (searchType = 1) ; id
            {
                Haystack .= col1 . "`r`n"
            }
            Else If (searchType = 2) ; md5
            {
                Haystack .= col12 . "`r`n"
            }
            Else If (searchType = 3) ; guid
            {
                Haystack .= col13 . "`r`n"
            }
            Else If (searchType = 4) ; source
            {
                FileRead, Haystack, % ini_getValue(config, "Dir", "lib") . "\" . getGlobal("libdb_" . row . "_Source")
                Haystack .= "`r`n"
            }
            Else ; normal
            {
                If (Gui_SearchAddInfo = True)
                {
                    Haystack := getGlobal("libdb_" . row . "_Description") . "`r`n"
                              . getGlobal("libdb_" . row . "_Notes") . "`r`n"
                }
                Loop, 13
                {
                    If A_Index In %Gui_SearchIn% ; Search at these user defined columnes only.
                    {
                        Haystack .= col%A_Index% . "`r`n"
                    }
                }
            }
            StringTrimRight, Haystack, Haystack, 2 ; Trim last `r`n.
            Haystack = %Haystack%
            SearchMatch := 1
            If (searchType > 0 && searchType < 4) ; exact id etc...
            {
                Loop, Parse, Ed_Search, %A_Space%, %A_Space%
                {
                    SearchMatch--
                    If (Haystack = A_LoopField)
                    {
                        SearchMatch++
                        Break
                    }
                }
            }            
            Else ; normal or source
            {
                Loop, Parse, Ed_Search, %A_Space%, %A_Space%
                {
                    SearchMatch--
                    If (SubStr(A_LoopField, 1, 1) = "!")
                    {
                        StringTrimLeft, field, A_LoopField, 1
                        If Not (RegExMatch(Haystack, "Sim)" . field))
                        {
                            SearchMatch++
                            Continue
                        }
                    }
                    Else If (RegExMatch(Haystack, "Sim)" . A_LoopField))
                    {
                        SearchMatch++
                        Continue
                    }
                }
            }         
            If (SearchMatch > 0)
            {
                Gui, ListView, Lv_Database2   
                LV_Add("", col1, col2, col3, col4, col5, col6, col7, col8, col9, col10, col11, col12, col13)
            }
            else 
            {
                currentItem:=""
                Lv_Database2CalledFrom:=true
                GoSub, Lv_Database2
                Lv_Database2CalledFrom:=false
            }
        }
        Gui, ListView, Lv_Database2
        ; Adjust list headers
        
        LV_ModifyCol("", "AutoHdr")
        Loop, 13
        {
            LV_ModifyCol(A_Index, "AutoHdr Logical")
        }
        LV_ModifyCol(1, "AutoHdr Integer")
        LV_ModifyCol(2, "Logical 100")
        LV_ModifyCol(6, "Logical 140")
        LV_ModifyCol(8, "Logical 140")
        LV_Modify(1, "+Focus +Select")
        GuiControl, +Redraw, Lv_Database2
        
        Gui, ListView, Lv_Database2
        GuiControl, Hide, Lv_Database
        GuiControl, Show, Lv_Database2
    }
    Else
    {
        Gui, ListView, Lv_Database
        currentItem := 1
        lastItem := 1
        GuiControl, Hide, Lv_Database2
        GuiControl, Show, Lv_Database
        Lv_Database := True
        LV_GetText(1, 1)
        GoSub, Lv_Database
    }
    GoSub, updateGuiTitle
    Return
}

Btn_CleanSearch:
GuiControl, -Redraw, Lv_Database2
GuiControl,, Ed_Search
GuiControl,, Chk_isStandalone, -1
GuiControl,, Chk_isStdlibConform, -1
GuiControl, +Redraw, Lv_Database2
GoSub, Ed_Search
selectEntry(1)
Return

Btn_HelpSearch:
MsgBox, 32, Search Help for Library Explorer, 
(
Search is done via Regular Expression, the RegExMatch() function (options cannot be specified). 
It sees every word as an individual search term, separated by space. 
All of these terms must match to show the entry (or with prefixed "!" to NOT match).

At default, these relevant fields are searched:

    *   Description
    *   Notes
    *   Prefix/Func
    *   Name
    *   Revision
    *   Last Modified
    *   Author
    *   License
    *   Category

It does recognizes id search, md5 and guid and shows the exactly identified entry only without search.

A leading ">" character turns on the search at source files only and no other field.

Double click to a row copies the data to the clipboard; right double click copies that without the header.

Examples:

    *   "ini|xml": One regex, "ini" or "xml" must be found.       
    *   "ini !xml": Two regexes, ini must be found and no "xml".
    *   ">#include": Search in sources only for "#include".
)
Return

Chk_isStandalone:
SetBatchLines, -1
Gui, Submit, NoHide
Ed_Search(true)
Return

Chk_isStdlibConform:
SetBatchLines, -1
Gui, Submit, NoHide
Ed_Search(true)
Return

Lv_Database2:
SetBatchLines, -1
If (A_GuiEvent == "Normal" || A_GuiEvent == "A" || A_GuiEvent == "I" || A_GuiEvent == "F")
{
    Gui, ListView, Lv_Database2
    Lv_Database2CalledFrom := True
    LV_GetText(currentItem, A_EventInfo > 0 ? A_EventInfo : lastItem, 1)
    GoSub, Lv_Database
}
Return

Txt_openHome:
Run, % ini_getValue(database_header, "HEADER", "Home")
Return

Btn_openDoc:
Loop, Parse, libdb_%currentItem%_Documentation, CSV, %A_Space%
{
    IfInString, A_LoopField, http://
    {
        Run, %A_LoopField%
    }
    Else
    {
        Run, % ini_getValue(config, "Dir", "doc") . "\" . A_LoopField
    }
}
Return

Btn_openDocomatic:
Run % createDocomatic(libdb_%currentItem%_Source)
Return

; _FileName should be the name of file only, without full path.
; i.g. "name.ahk"
createDocomatic(_FileName)
{
    Global config
    Source := ini_getValue(config, "Dir", "lib") . "\" . _FileName
    Dest := ini_getValue(config, "Dir", "temp") . "\" . getDocomaticFileName(_FileName)
    Docomatic := ini_getValue(config, "Tools", "Docomatic")
    SplitPath, Docomatic, , , ext
    If (ext = "ahk")
    {
        RunWait, "%A_AhkPath%" "%Docomatic%" "%Source%" "%Dest%"
    }
    Else
    {
        RunWait, "%Docomatic%" "%Source%" "%Dest%"
    }
    Return Dest
}

getDocomaticFileName(_FileName)
{
    Return RegExReplace(_FileName, "S)\..*?$") . "_docomatic.html"
}

Btn_openTextcompare:
Run, % openTextcompare(libdb_%currentItem%_Source)
Return

openTextcompare(_FileName)
{
    Global config
    Source := ini_getValue(config, "Dir", "lib") . "\" . _FileName
    Installed := ini_getValue(config, "Dir", "stdlib") . "\" . _FileName
    DestDir := ini_getValue(config, "Dir", "temp")
    Textcompare := ini_getValue(config, "Tools", "Textcompare")
    file := DestDir . "\" . SubStr(_FileName, 1, -4) . "-vs-" . SubStr(_FileName, 1, -4) . ".html"
    FileDelete, %file%
    SplitPath, Textcompare, , , ext
    If (ext = "ahk")
    {
        RunWait, "%A_AhkPath%" "%Textcompare%" "%Source%" "%Installed%" "%DestDir%"
    }
    Else
    {
        RunWait, "%Textcompare%" "%Source%" "%Installed%" "%DestDir%"
    }
    Return file
}

Btn_openTopic:
Run, % libdb_%currentItem%_Discussion
Return

Btn_openLicense:
IfInString, libdb_%currentItem%_LicenseSource, http://
{
    Run, % libdb_%currentItem%_LicenseSource
}
Else
{
    Run, % ini_getValue(config, "Dir", "licenses") . "\" . libdb_%currentItem%_LicenseSource
}
Return

Btn_runExample:
Btn_runExample()
Return

Btn_runExample()
{
    Global
    Local source
    Local filename
    Local libpath
    Local pid
    Local files
    Local DependFiles
    Local IncludeSource
    If (Tab_Info!="Example")
    {
        GuiControl, Choose, Tab_Info, |2 ; Example 2=TAB
        Sleep, 100
        Lv_Database2CalledFrom := True
        GoSub, Lv_Database
        Lv_Database2CalledFrom := False
    }
    Gui, Submit, NoHide
    source := libdb_%currentItem%_Source
    sample := libdb_%currentItem%_Sample 
    If (sample = "")
    {
        If (source = "")
        {
            sample := "default_demo.ahk"
        }
        Else
        {
            SplitPath, sample, source
        }
    }
    
    libpath := ini_getValue(config, "Dir", "lib")
    sample := ini_getValue(config, "Dir", "temp") . "\" . sample
    IfInString, sample, .ahk
    {
        FileDelete, %sample%  
    }
    files := getDependFiles(libdb_%currentItem%_Dependency)
    Loop, Parse, files, `n
    {
        DependFiles := "`r`n#Include " . A_LoopField
    }
    IncludeSource:= Source != "" ? "`r`n#Include " . source : "" 
    FileAppend, 
    (LTrim
        %Ed_InfoExample%
        RETURN
        #Include %libpath%%DependFiles%%IncludeSource%
    ), %sample%
    Run, "%A_AhkPath%" "%sample%", % ini_getValue(config, "Dir", "temp"), UseErrorLevel, NewPID
    If (ErrorLevel = "ERROR")
    {
        MsgBox, 53, Example failed to start, The script could not run.`nFile:`n`n%sample%
    }
    Else
    {
        runningPidList .= NewPID . ";"
    }
    Return
}

Btn_copyTo:
Btn_copyTo(libdb_%currentItem%_Source)
Return

Btn_copyTo(_fileNameToCopy)
{
    Global config
    Global database
    Global currentItem
    static lastDir := ""
    If (lastDir = "")
    {
        lastDir := A_WorkingDir
    }
    FileSelectFile, selectedFilePath, S16, % lastDir . "\" . _fileNameToCopy, Where to copy the file?, AutoHotkey Scripts (*.ahk)
    If (ErrorLevel = 0)
    {
        SplitPath, selectedFilePath, , lastDir
        ; Source
        FileCopy, % ini_getValue(config, "Dir", "lib") . "\" . _fileNameToCopy, %selectedFilePath%, 1
        ; Manifest
        FileDelete, %selectedFilePath%.manifest
        LV_GetText(FileMD5, currentItem, 12)
        manifest =
        (LTrim
        [Manifest]
        Timestamp = %A_Now%
        FileMD5 = %FileMD5%
        )
        manifest .= "`n" . RegExReplace(ini_getSection(database, currentItem), "S`a)^\[\d+]\R")
        
        StringReplace, manifest, manifest, `r,, All
        StringReplace, manifest, manifest, `n, `r`n, All
        FileAppend, %manifest%, %selectedFilePath%.manifest
    }
}


Btn_Install:
installStdLib(libdb_%currentItem%_Source)
files := getDependFiles(libdb_%currentItem%_Dependency)
Loop, Parse, files, `n
{
    installStdLib(A_LoopField)
}
Lv_DatabaseCall := True
GuiControl, Focus, Lv_Database
InstOrDeinst := True
GuiControl,, Ed_InfoInstalledLibs, % getListOfInstalledLibs()
Return

installStdLib(_sourceFile)
{
    Global
    Local doit, filename, stdlib, temp
    doit := false
    stdlib := ini_getValue(config, "Dir", "stdlib")
    temp := ini_getValue(config, "Dir", "temp")
    _sourceFile := ini_getValue(config, "Dir", "lib") . "\" . _sourceFile
    SplitPath, _sourceFile, filename
    IfExist, %stdlib%\%filename%
    {
        MsgBox, 36, Install
            , % "The file " . filename . " does exist in the standard library."
                . "`nDo you want replace the existing file with this version?"
                . "`nBackup file is made and updated one time per week at max."
        IfMsgBox, Yes
        {
            doit := true
        }
    }
    Else
    {
        doit := true
    }
    If (doit)
    {
        GuiControl, Show, Btn_DeInstall
        GuiControl, Hide, Btn_Install
        FileCreateDir, %temp%\%A_YWeek%
        FileCreateDir, %stdlib%
        FileMove, %stdlib%\%filename%, %temp%\%A_YWeek%\%filename%, 0
        FileCopy, %_sourceFile%, %stdlib%, 1
        appendlog("installed " . stdlib . "\" . filename)
    }
}

Btn_DeInstall:
deinstallStdLib(libdb_%currentItem%_Source)
Lv_DatabaseCall := True
GuiControl, Focus, Lv_Database
InstOrDeinst := True
GuiControl,, Ed_InfoInstalledLibs, % getListOfInstalledLibs()
Return

deinstallStdLib(_sourceFile)
{
    Global
    Local doit, filename, stdlib, temp
    doit := false
    stdlib := ini_getValue(config, "Dir", "stdlib")
    temp := ini_getValue(config, "Dir", "temp")
    _sourceFile := ini_getValue(config, "Dir", "lib") . "\" . _sourceFile
    SplitPath, _sourceFile, filename
    IfExist, %stdlib%\%filename%
    {
        MsgBox, 36, Install
            , % "The file " . filename . " does exist in the standard library."
                . "`nDo you want delete the existing file"
                . "`nBackup file is made and updated one time per week at max."
        IfMsgBox, Yes
        {
            GuiControl, Show, Btn_Install
            GuiControl, Hide, Btn_DeInstall
            GuiControl, Disable, Btn_openTextcompare
            FileCreateDir, %temp%\%A_YWeek%
            FileCreateDir, %stdlib%
            FileMove, %stdlib%\%filename%, %temp%\%A_YWeek%\%filename%, 0
            FileDelete, %stdlib%\%filename%
            appendlog("removed " . stdlib . "\" . filename)
        }
    }
}

Ed_InfoExample:
GuiControl, Text, Txt_Warning, Example was edited!
GuiControl, Show, Txt_Warning
Return

;  ------------------------------------------
;           Settings and database
;  ------------------------------------------

; Create and get the initial configuration for the script.
; The ini format can be read and manipulated by the internal
; Basic Ini String Library.
getConfig()
{
    If (A_IsCompiled)
    {
        If (A_AhkPath)
        {
            FileGetVersion, Version_currentAhk, %A_AhkPath%
        }
        Else
        {
            Version_currentAhk := 0
        }
    }
    Else
    {
        Version_currentAhk := A_AhkVersion
    }
    
    Gui_searchIn=2,3,4,5,6,7,8,9,10,11
    Gui_searchAddInfo := True ; Searches in Description and Notes also.
    
    Dir_stdlib=%A_MyDocuments%\AutoHotkey\Lib
    Dir_lib=%A_ScriptDir%\lib
    Dir_doc=%A_ScriptDir%\doc
    Dir_samp=%A_ScriptDir%\samp
    Dir_licenses=%A_ScriptDir%\licenses
    Dir_temp=%A_ScriptDir%\temp
    Dir_tools=%A_ScriptDir%\tools
    
    File_libdb=
    File_log=%Dir_temp%\log.txt
    File_defaultLicense=default-license.txt
    
    Tools_docomatic=%Dir_tools%\doc-o-matic.ahk
    Tools_textcompare=%Dir_tools%\Text Compare.ahk
    
    config =
    (LTrim
        [Version]
            currentAhk=%Version_currentAhk%
        [Gui]
            searchIn=%Gui_searchIn%
            searchAddInfo=%Gui_searchAddInfo%
        [Dir]
            stdlib=%Dir_stdlib%
            lib=%Dir_lib%
            doc=%Dir_doc%
            samp=%Dir_samp%
            licenses=%Dir_licenses%
            temp=%Dir_temp%
            tools=%Dir_tools%
        [File]
            libdb=%File_libdb%
            log=%File_log%
            defaultLicense=%File_defaultLicense%
        [Tools]
            docomatic=%Tools_docomatic%
            textcompare=%Tools_textcompare%
            
    )
    Return config
}

; Load database file into memory and update path in config
; Updated entry in config is the libdb under File.
loadDatabase(ByRef _data)
{
    Global config
    _data := ""
    loaded := false
    Loop, 9
    {
        path := ini_load(_data, "libdb")
        If (ErrorLevel)
        {
            MsgBox, 21, File not found`,Try: %A_Index%
                      , Database file`n"%path%"`ndoes not exist.
            IfMsgBox, Retry
            {
                Continue
            }
            IfMsgBox, Cancel
            {
                Break
            }
        }
        Else
        {
            loaded := true
            Break ; Continue with normal script execution.
        }
    }
    ini_replaceValue(config, "File", "libdb", path)
    Return loaded
}

; Delete all sections in ini which are not digits, plus delete the 0 entry.
removeUnNeededSections(ByRef _data)
{
    replaced := 0
    list := ini_getAllSectionNames(_data)
    Loop, Parse, list, `,
    {
        If A_LoopField Is Not Digit
        {
            replaced += ini_replaceSection(_data, A_LoopField)
        }
    }
    replaced += ini_replaceSection(_data, "0")
    Return replaced
}

getDependFiles(_list, _get = "filename")
{
    Global
    Local guid
    Local db
    Local files
    Local entrycount
    entrycount := LV_GetCount()
    Loop, Parse, _list, CSV
    {
        guid := RegExReplace(A_LoopField, "S).*:\s")
        Loop, %entrycount%
        {
            LV_GetText(guidFromDb, A_Index, 13) ; Guid
            If (guid = guidFromDb)
            {
                LV_GetText(filenameFromDb, A_Index, 11) ; Filename
                If (_get = "filename")
                {
                    files .= filenameFromDb . "`n"
                }
                Else If (_get = "guid")
                {
                    files .= guidFromDb . "`n"
                }
                Break
            }
        }
    }
    StringTrimRight, files, files, 1 ; Trim last newline.
    Return files
}


;  ------------------------------------------
;               Other
;  ------------------------------------------

Exit:
Critical
Suspend, On
Gui, Cancel
ProcessClose(runningPidList, True, "AutoHotkey") ; Close all ahk process from this script.
ExitApp

; 2007, 2010 by Tuncay
; pPID is a semikolon separated list of process identifiers (PID).
ProcessClose(ByRef pPID, All = False, inPath = "")
{
    IfInString, pPID, `;
    {
        dhw_backup := A_DetectHiddenWindows 
        DetectHiddenWindows, On
        Loop, Parse, pPID, `;
        {
            StringReplace, pPID, pPID, `;%A_LoopField%`;, `;
            Process, Exist, %A_LoopField%
            If (ErrorLevel)
            {
                If (inPath != "" && InStr(ProcessInfo_GetModuleFileNameEx(A_LoopField), inPath))
                {
                    WinClose, ahk_pid %A_LoopField%,, 0 ; wait 500ms
                    Process, Exist, %A_LoopField%
                    If (ErrorLevel)
                    {
                        WinKill, ahk_pid %A_LoopField%,, 0 ; 500ms
                        Process, Exist, %A_LoopField%
                        If (ErrorLevel)
                        {
                            Process, Close, %A_LoopField%
                        }
                    }
                }
                If All
                    Continue
                Else
                {
                    Break
                }
            }
            If ErrorLevel = 0
                Break
            Else
                Continue
        }
        DetectHiddenWindows, %dhw_backup%
    }
    Return
}

appendlog(_text)
{
    Global config
    FileAppend, `r`n%A_Now%: %_text%, % ini_getValue(config, "File", "log")
}


; Checks which libraries are installed on the system currently. The list is new line
; separated. It contains two lists, one for the user lib and the other one for the
; std lib folder of AutoHotkeys install path.
; If the file does exist in the collection, then the MD5 hash will be calculated and
; compared to the one from the collection. If the MD5 differs, then a star at begin
; of filename marks that.
; Currently there is no standardized way to say which one is the newer one or if the
; library just uses the same filename, beeing a completly another solution.
getListOfInstalledLibs(_fileNamePattern = "*")
{
    Global
    Local InstalledLibs := ""
    Local id := 0
    Local dir := ""
    Local MD5 := ""
    Local MD5_src := ""
    Local found := false
    InstalledLibs =
    (LTrim Join%A_Space%
        If the file is found in the collection, then the id is shown and the MD5 hash 
        will be calculated. A star marks a different hash. There is no standardized 
        way to tell which file is newer, you have to check it manually.`n`n
    )
    ; Check files from User Lib folder.
    dir := ini_getValue(config, "Dir", "stdlib")
    InstalledLibs .= dir . ":`n"
    Loop, % dir . "\" . _fileNamePattern . ".ahk", 0, 0
    {
        id := 0
        Loop, Parse, database_fileNames, `,
        {
            If (A_LoopField = A_LoopFileName)
            {
                id := A_Index
                Break
            }
        }
        If (id > 1)
        {
            found := true
            LV_GetText(MD5_src, id, 12)
            MD5 := MD5_File(A_LoopFileFullPath)
            If (MD5 == MD5_src)
            {
                MD5 := "  =  " . MD5
                InstalledLibs .= "  "
            }
            Else
            {
                MD5 := "  !=  " . MD5
                InstalledLibs .= "  * "
            }
            InstalledLibs .= A_LoopFileName . "  ~  [ " . id . " ]  MD5" . MD5 . "`n"
        }
        Else
        {
            InstalledLibs .= "  " . A_LoopFileName . "  ?`n"
        }
    }
    If (Not found)
    {
        InstalledLibs .= "  ---`n`n"
    }
    Else
    {
        InstalledLibs .= "`n"
    }
    ; Check files from AutoHotkey Lib folder.
    found := false
    SplitPath, A_AhkPath, , dir
    InstalledLibs .= dir . "\Lib:`n"
    Loop, % AhkDir . "\Lib\" . _fileNamePattern . ".ahk", 0, 0
    {
        id := 0
        Loop, Parse, database_fileNames, `,
        {
            If (A_LoopField = A_LoopFileName)
            {
                id := A_Index
                Break
            }
        }
        If (id > 1)
        {
            found := true
            LV_GetText(MD5_src, id, 12)
            MD5 := MD5_File(A_LoopFileFullPath)
            If (MD5 == MD5_src)
            {
                MD5 := "  =  " . MD5
                InstalledLibs .= "  "
            }
            Else
            {
                MD5 := "  !=  " . MD5
                InstalledLibs .= "  * "
            }
            InstalledLibs .= A_LoopFileName . "  ~  [ " . id . " ]  MD5" . MD5 . "`n"
        }
        Else
        {
            InstalledLibs .= "  " . A_LoopFileName . "  ?`n"
        }
    }
    If (Not found)
    {
        InstalledLibs .= "  ---"
    }
    InstOrDeinst := False
    Return InstalledLibs
}

; 2005 by shimanov
; http://www.autohotkey.com/forum/viewtopic.php?p=37696#37696
HandleMessage( p_w, p_l, p_m, p_hw )
{
   Global WM_SETCURSOR, WM_MOUSEMOVE
   Global standardFonts, sourceFonts
   Static URL_hover, h_cursor_hand, h_old_cursor
   
   if ( p_m = WM_SETCURSOR )
   {
      if ( URL_hover)
         return, true
   }
   else if ( p_m = WM_MOUSEMOVE )
   {
      if ( A_GuiControl = "Txt_openHome" )
      {
         if URL_hover=
         {
            setGuiFont(standardFonts, "norm cFF7F00")
            GuiControl, Font, Txt_openHome
            setGuiFont("default", "norm")
            setGuiFont("")
            h_cursor_hand := DllCall( "LoadCursor", "uint", 0, "uint", 32649 )
            
            URL_hover := true
         }
         
         h_old_cursor := DllCall( "SetCursor", "uint", h_cursor_hand )
      }
      else
      {
         if ( URL_hover )
         {
            setGuiFont(standardFonts, "underline cBlue")
            GuiControl, Font, Txt_openHome
            setGuiFont("default", "norm")
            setGuiFont("")
            
            DllCall( "SetCursor", "uint", h_old_cursor )
            
            URL_hover=
         }
      }
   }
}