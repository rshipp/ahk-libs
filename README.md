# ahk-libs
All the (redistributable) AHK libs I can find...

Licenses are scattered around in there somewhere.

At the moment, this repo contains well over 200 libraries, classes, and
wrappers for AHK basic (vanilla), AHK\_L, and AHK v2, implemented in over
2900 ahk scripts.

## AutoHotkey Library distribution
Want more libs? Several projects have similar goals to this one:

* [pAHKlite](https://github.com/hi5/pAHKlight)
* [package/stdlib distribution and management](https://trello.com/b/XVP4M76d/package-stdlib-distribution-and-management)
  from the [ahkscript](https://github.com/ahkscript) folks
* tuncay's original [ahkstdlib](http://www.autohotkey.com/forum/viewtopic.php?t=54996)

## README!
Please note that, because this repo makes heavy use of git 'submodules',
downloading a zip or tarball is not useful. Instead, if you wish to have
access to all the libs included in this repo, please run:

    git clone --recursive git://github.com/george2/ahk-libs.git


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
* [avi-aryan](https://github.com/avi-aryan)'s "Avis-Autohotkey-Repo", which includes several AHK libraries.
* [lordkrandel](https://github.com/lordkrandel)'s ahk_library
* [TLMcode](https://github.com/TLMcode)'s FF_COM
* [MasterFocus](https://github.com/MasterFocus)'s "AutoHotkey" repo, which includes several AHK libraries and functions.
* [tinku99](https://github.com/tinku99)'s ahkzmq wrapper and stdlib.
* [joedf](https://github.com/joedf)'s LibCon.ahk
* [avi-aryan](https://github.com/avi-aryan)'s autohotkey-scripts repo, including Avi's Math-Functions library.
* [Jim-VxE](https://github.com/Jim-VxE)'s JSON_ToObj, ADOSQL, and Table libraries.
* [JnLlnd](https://github.com/JnLlnd)'s ObjCSV library
* [fincs](https://github.com/fincs)' AutoHotkey Foundation Classes
  (AFC), and ahk-eval library
* [Lexikos](https://github.com/Lexikos)' DBGp library
* [AHK-just-me](https://github.com/AHK-just-me)'s HD_EX, TC_EX, IL_EX,
  LV_EX, Class_LV_Colors, Class_LV_InCellEdit, Class_SQLiteDB,
  Class_ImageButton, and Class_RichEdit.

## Note to developers of these libs
If your code is in this repo, and you do not want it to be, I apologize. 
Please just let me know, and I will remove it.
