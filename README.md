# ahk-libs
All the (redistributable) [AutoHotkey](http://ahkscript.org/) libraries I can find...

Licenses are scattered around in there somewhere.

At the moment, this repo contains well over 200 libraries, classes, and
wrappers for [AHK 1.1](https://github.com/Lexikos/AutoHotkey_L) (previously AHK\_L),
AHK 1.0 (previously basic/vanilla), and [AHK v2](https://github.com/Lexikos/AutoHotkey_L/tree/alpha),
implemented in over 3000 scripts.

## AutoHotkey Library Distribution
Want more libs? Several projects have similar goals to this one:

* [pAHKlight](https://github.com/hi5/pAHKlight)
* [ASPDM](https://github.com/ahkscript/ASPDM), for
  [package/stdlib distribution and management](https://trello.com/b/XVP4M76d/package-stdlib-distribution-and-management)
  from the [ahkscript](https://github.com/ahkscript) folks
* [ALD](http://libba.net/) (discontinued)
* tuncay's original [ahkstdlib](http://www.autohotkey.com/forum/viewtopic.php?t=54996) (discontinued)
* [Salt](https://code.google.com/p/salt/) (discontinued)

## README!
Please note that, because this repo makes heavy use of git 'submodules',
downloading a zip or tarball is not useful. Instead, if you wish to have
access to all the libs included in this repo, please run:

    git clone --recursive git://github.com/rshipp/ahk-libs.git


## Included
So far, the included libs are (in no particular order):

* The 'ahkstdlib' collection, in its entirety (see
  http://www.autohotkey.com/forum/viewtopic.php?t=54996)
* Several of [Uberi](https://github.com/Uberi)'s libs, including:
  AHK-DB (sqlite3 database functions),
  AssociativeArrays,
  AveragingFunctions,
  BarGrapher,
  DeltaCompression,
  ExprEval(),
  Geolocation,
  ListCompare,
  ParallelPort,
  QuotedStringReplace,
  RangeOverlap,
  Raydium-AHK (game engine wrapper),
  SingleCharArray,
  Speech (tts lib),
  TriangleCollisionDetection,
  Parallelist,
  Canvas-AHK,
  Fraction.ahk
* [Rseding91](https://github.com/Rseding91)'s "Fast ini library", basic and advanced versions
* Several of [infogulch](https://github.com/infogulch)'s libs, including:
  WinHttpRequest,
  Map,
  AsyncHttp,
  Zip,
  LSON,
  ahk2-bigint,
  CaseSensitiveObject,
  ahk-OpenGL
* [nimdahk](https://github.com/nimdahk)'s AHKLink lib
* [ChrisS85](https://github.com/ChrisS85)'s CGUI and WorkerThread libs
* [camerb](https://github.com/camerb)'s AHK libs
* [polyethene](https://github.com/polyethene)'s AutoHotkey-Scripts
* Several of [maul-esel](https://github.com/maul-esel)'s libs, including:
  COM-Classes,
  FormsFramework,
  ITaskbarList,
  AeroThumbnail,
  ImportTypeLib,
  AHK-Util-Funcs (GUID, Mem, Obj, etc),
  ALD.ahk
* [hoppfrosch](https://github.com/hoppfrosch)'s cTable and cGist classes
* [HotKeyIt](https://github.com/HotKeyIt)'s _Struct libs for AHK v2 and _H
* [RaptorX](https://github.com/RaptorX)'s scintilla-wrapper and cURL-Wrapper libs
* [IsNull](https://github.com/IsNull)'s ahkDBA
* [aviaryan](https://github.com/aviaryan)'s "autohotkey-scripts", which includes several AHK libraries and scripts.
* [lordkrandel](https://github.com/lordkrandel)'s ahk_library
* [TLMcode](https://github.com/TLMcode)'s FF_COM
* [MasterFocus](https://github.com/MasterFocus)'s "AutoHotkey" repo, which includes several AHK libraries and functions.
* [tinku99](https://github.com/tinku99)'s ahkzmq wrapper and stdlib.
* [joedf](https://github.com/joedf)'s LibCon.ahk
* [Jim-VxE](https://github.com/Jim-VxE)'s JSON_ToObj, ADOSQL, and Table libraries.
* [JnLlnd](https://github.com/JnLlnd)'s ObjCSV library
* [fincs](https://github.com/fincs)' AutoHotkey Foundation Classes
  (AFC), and ahk-eval library
* [Lexikos](https://github.com/Lexikos)' DBGp library
* [AHK-just-me](https://github.com/AHK-just-me)'s HD_EX, TC_EX, IL_EX,
  LV_EX, Class_LV_Colors, Class_LV_InCellEdit, Class_SQLiteDB,
  Class_ImageButton, and Class_RichEdit.
* [cocobelgica](https://github.com/cocobelgica)'s
  AutoHotkey-ElementTree, AutoHotkey-PS-Control, AutoHotkey-Menu,
  AutoHotkey-IPC, AutoHotkey-XConfig, AutoHotkey-JSON, AutoHotkey-XML,
  and AutoHotkey-Expose.
* [AfterLemon](https://github.com/AfterLemon) and
  [tidbit](https://github.com/acorns)'s Class_Console.
* [jNizM](https://github.com/jNizM)'s AHK_DllCall_WinAPI and
  AutoHotkey_Scripts (jNizM_AutoHotkey_Scripts).
* [Shambles-Dev](https://github.com/Shambles-Dev)’s HashTable and Facade.

## Removed

* [Shambles-Dev](https://github.com/Shambles-Dev)’s Plaster introspection
  and Composer functional programming libraries. ([Issue #4](https://github.com/rshipp/ahk-libs/issues/4))

## Note to developers of these libs
If your code is in this repo, and you do not want it to be, I apologize.
Please just let me know, and I will remove it.
