# ahk-libs
All the (redistributable) AHK libs I can find...

Licenses are scattered around in there somewhere.

At the moment, this repo contains well over 200 libraries, classes, and
wrappers for AHK basic (vanilla), AHK\_L, and AHK v2, implemented in over
2900 ahk scripts.

## README!
Please note that, because this repo makes heavy use of git 'submodules',
downloading a zip or tarball is not useful. Instead, if you wish to have
access to all the libs included in this repo, please run:

    git clone git://github.com/george2/ahk-libs.git
    git submodule update --init --recursive
    git submodule update --remote --merge



## Included
So far, the included libs are (in no particular order):

* The 'ahkstdlib' collection, in its entirety (see
  http://www.autohotkey.com/forum/viewtopic.php?t=54996)
* Several of @Uberi's libs, including: 
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
* Rseding91's "Fast ini library", basic and advanced versions
* Several of @infogulch's libs, including:
  WinHttpRequest, 
  Map, 
  AsyncHttp, 
  Zip, 
  LSON, 
  ahk2-bigint, 
  CaseSensitiveObject, 
  ahk-OpenGL
* @nimdahk's AHKLink lib (https://github.com/nimdahk/AHKLink)
* @ChrisS85's CGUI and WorkerThread libs (https://github.com/ChrisS85)
* @camerb's AHK libs (https://github.com/camerb/AHKs)
* @polyethene's AutoHotkey-Scripts (https://github.com/polyethene/AutoHotkey-Scripts)
* Several of @maul-esel's libs (https://github.com/maul-esel/), including:
  COM-Classes, 
  FormsFramework, 
  ITaskbarList, 
  AeroThumbnail, 
  ImportTypeLib, 
  AHK-Util-Funcs (GUID, Mem, Obj, etc),
  ALD.ahk
* @hoppfrosch's cTable and cGist classes
* @HotKeyIt's _Struct libs for AHK v2 and _H
* @RaptorX's scintilla-wrapper and cURL-Wrapper libs
* @IsNull's ahkDBA
* @avi-aryan's "Avis-Autohotkey-Repo", which includes several AHK libraries.
* @lordkrandel's ahk_library
* @TLMcode's FF_COM
* @MasterFocus's "AutoHotkey" repo, which includes several AHK libraries and functions.
* @tinku99's ahkzmq wrapper and stdlib.
* @joedf's LibCon.ahk

The "Sources" file contains a list of the git repos from which
submodules were created, and are included here. 

## Note to developers of these libs
If your code is in this repo, and you do not want it to be, I apologize. 
Please just let me know, and I will remove it.
