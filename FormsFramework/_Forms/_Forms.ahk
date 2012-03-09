/*
	Title:	_Forms
			*Forms framework.*

 Group: Overview
		Forms framework is a group of modules used together to create AHK graphical user interfaces. 
		It contains the list of optional module includes with each module designed to work with or without the framework in place.
		It includes number of custom controls, extensions and useful libraries. <Form> module is a backbone of the framework.		
		
 Group: Features
		All modules are developed so they fulfill specific goals :

		o Standalone. All modules are independent of each other. You can copy any module to your script and use it without other modules.
		  They generally don't depend on your script settings. 
		o Standardized. Generally, modules use the same or similar APIs whenever possible. Functions with big number of parameters use
		  named arguments to avoid long list of empty parameters. Functions doing similar things are declared the same and arguments
		  having similar purpose are named equaly cross-module.
		o Clean. They don't create any globals and try not to influence the hosting script in any way unless specified differently.
		o Documented. All scripts contain documentation in the source code. You can use mkdoc script to create HTML documentation out of it by simply
		  running it in the folder with scripts. You can use comment remover to reduce the size of the modules. You can also merge them into
		  single include using ScriptMerge, which gives you the option to keep the framework and its documentation in single file.
		o Free. All modules are open source and free.


 Group: Modules
 		o <_>			- Script initializer and set of helper functions.
		o <Form>		- Alternative way of creating AHK GUIs.
		o <Panel>		- Panel custom control, container for other controls.
		o <Toolbar>		- Toolbar custom control.
		o <Rebar>		- Rebar custom control.
		o <HLink>		- HyperLink custom control.
		o <Splitter>	- Splitter custom control.
		o <ScrollBar>	- Scrollbar custom control.
		o <Scroller>	- Makes windows scrollable.
		o <HiEdit>		- HiEdit custom control.
		o <QHTM>		- Qhtm custom control.
		o <SpreadSheet> - SpreadSheet custom control.
		o <Property>	- Property custom control.
		o <RaGrid>		- Ragrid custom control.]
		o <Win>			- Set of window functions.
		o <Dlg>			- Common dialogs.
		o <DockA>		- Docking system for AutoHotKey windows.
		o <ShowMenu>	- Show menu from the text.

 Group: Extensions
		o <Align>		- Aligns controls inside the parent.
		o <Attach>		- Determines how a control is resized with its parent.
		o <Cursor>		- Sets the cursor shape for a control or a window.
		o <Tooltip>		- Adds tooltips to GUI controls.
		o <CMenu>		- Sets a context menu for a control.
		o <CColor>		- Sets colors for the control.
		o <ILButton>	- Adds an image to a Button control.
		o <Font>		- Sets font for the control.

 Group: Known bugs/issues
		o Modules use decimal format of integer (default one). Module may not work if integer format is changed to Hex.
		  as it doesn't set and restore integer format for practical reasons (it would have to be repeated on far too many places).
		  If you use different integer format restore it back to decimal once you are finished.
 */
#include *i Form.ahk

;extensions
#include *i Align.ahk
#include *i Attach.ahk
#include *i Tooltip.ahk
#include *i Cursor.ahk
#include *i CMenu.ahk	
#include *i CColor.ahk
#include *i ILButton.ahk
#include *i Font.ahk

;controls
#include *i Panel.ahk
#include *i Toolbar.ahk
#include *i Rebar.ahk
#include *i RichEdit.ahk
#include *i HLink.ahk
#include *i Splitter.ahk
#include *i Scrollbar.ahk
#include *i Property.ahk

;dll controls
#include *i HiEdit.ahk
#include *i SpreadSheet.ahk
#include *i RaGrid.ahk
#include *i Qhtm.ahk


;utilities
#include *i _.ahk
#include *i DockA.ahk
#include *i Dlg.ahk
#include *i Scroller.ahk
#include *i ShowMenu.ahk
#include *i Win.ahk
#include *i COM.ahk
/* 
 Group: About
	o v0.45 by majkinetor.
	o Licenced under BSD <http://creativecommons.org/licenses/BSD/> .

	(see _Forms.png)
 */
