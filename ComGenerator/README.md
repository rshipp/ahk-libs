# ComGenerator
## History
Quite some time ago, I started [CCF](https://github.com/maul-esel/Com-Classes). It's a project to collect AHK classes that wrap COM (non-dispatch) interfaces in a standardized way. After some classes, it was obvious to me and others that the code was repeating over and over. So suggestions came up to write a script that automates this task. But as my RegEx skills are low and the interface declarations differ a lot. So it just remained an idea.

In the last weeks, I looked into some COM interfaces providing type information, namely **ITypeInfo**. I got the idea this could be used instead to enable automatic generation.

## Purpose
Well, this is the script mentioned above. It is written in AHK **(requires latest AHK_L)** and uses the CCF classes (brought in as submodule) and allows class creation via CMD and GUI. Or rather, it should. Right now, some basic functionalities are implemented, the main part is still missing.

## Requirements:
As mentioned before ComGenerator requires the latest AHK_L. To get it running, you should also fetch the submodule (the CCF): `git submodule update --init`.

## Contribute
Any AHK developers are **welcome to fork this and to contribute**. Of course, the same applies to CCF: ITypeInfo, ITypeInfo2, ITypeLib2 and other interfaces are missing or incomplete.

## Command line parameters:
If run from the command line, ComGenerator accepts (or *will accept*) the following parameters:

### Information
Parameter            | Description
---------------------|--------------------------
`--name [INTERFACE]` | defines the interface name to use. ComGenerator will search for this name in the registry. If it is not found, it will fail and exit
`--iid [IID]`        | defines the interface id to use. This argument overrides the name argument. One of those two must be specified.
`--clsid [CLSID]`    | defines the CLSID to use. If this is ommitted, ComGenerator assumes there's no system default implementation

### Versions
Parameter            | Description
---------------------|--------------------------
`--ahk_L`            | ensures AHK_L output is generated.
`--ahk2`             | ensures AHK v2 output is generated. Both arguments can be combined. If entirely ommitted, `--ahk2` is assumed.

### Saving
Parameter            | Description
---------------------|--------------------------
`--save [DIR]`       | saves all output in *DIR*. If this is ommitted, output is written to stdout.

The files are saved in the output directory under `[AHKVersion]\[NAME].ahk`, for example `AutoHotkey_L\TypeInfo.ahk`.