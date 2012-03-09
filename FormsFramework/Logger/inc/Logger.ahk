/*  
	Title:  Logger Control
			*Logging API*

	Logger is an AHK module implementing small HTML logging API. It allows you to use consistent logging between different projects.
	Logger can display 3 types of messages - info, warning and error. Each message can display icon, category, text and time in fully 
	customizable manner.

	In its current implementation Logger uses QHTM control and thus it depends on qhtm.ahk wrapper. 
	The module can be quickly changed to use other controls instead, for instance IE control. This can be done by reimplementing 3
	functions with _WebControl_ prefix.
 */

/*
	Function: Add
			  Add Logger control to the GUI.

	Parameters:
			  GUI		- Handle of the parent.
			  X-H		- Control coordinates.
			  Handler	- Notification function that fires when user clicks on the type icon (i.e. properties). Function accepts two parameters - Type and Id.
	
	Config:
			 To setup Logger edit *Logger_config* or call Logger_Store(var, value) for dynamic set-up (for some values). You can entirely delete Logger_config.ahk if you don't need it.

			 You can omit any parameter you don't use, in which case Logger will use default values.

				bg				- Global background, by default "white".
				fg				- Global foreground, by default "black".
				fsize			- Global font size, 1-7 for predefined sizes or number with 'pt' suffix (points).
				isize			- Global icon size, by default 16.
				separator		- HTML used to separate log entries, none by default. If starts with *, it will separate only on type change, that is , messages from the same module will not be separated.
				icongroup		- Icon suffix. Icons are normally grabbed from the icons folder in the script directory. Icons are named by type with eventual suffix. Suffix can be used to quickly change icon group.
				style			- Space separated list of styles for the control, can include 'border' and 'transparent'. None by default.

				catwidth		- Category width or if no category is used, separator between icons and text.
				catalign		- Category align, by default "left".
				tcategory		- If true, type will be set as category. By default false.

	   
				The following parameters can be set for each type of message. The possible message types are "info", "warning" and "error"
				If not set, parameter will be set to the global one.

				%type%_bg		- Type background. 
				%type%_fg		- Type foreground. 
				%type%_fsize    - Type font size. 
				%type%_isize    - Type icon size. 
				%type%_catfg	- Type category foreground color. 


				Behavioral options :
				
				saveHour		- N, hour at which to save the content of the Logger in an external file. 
								  If starts with "*" content will be saved every N hours instead at Nth hour of the day.
								  By default empty, means that this functionality will be disabled.
				logDir			- Directory in which to save log files. Has no meaning if saveHour is disabled.
				timeFormat		- Time format used for log file names. See FormatTime for details about the format. Has no meaning if saveHour is disabled.
				error_kw, warning_kw - Coma separated list of keywords for <Auto> function.

	Remarks:
				The Logger will try to include ahk files it needs (Logger_config.ahk, qhtm.ahk) from the root of the script and from the "inc" folder.
				This function makes one global, Log_hwnd, that keeps handle of the Logger.

 */
Log_Add(hGui, x, y, w, h, Handler=""){
	global Log_hwnd
	Logger("*", "bg style saveHour logDir", bg, style, saveHour, logDir)

	Logger("handler", Handler)
	Log_hwnd := WebControl_Add(hGui, "<html><body bgcolor='" bg "'>", x, y, w, h, style, "Log_Handler")

	if (saveHour != "")
	{	
		FileCreateDir, %logdir%
		Log_saveTimer(true)					;initialize save timer
		SetTimer, Log_saveTimer, 60000		;check every minute
	}
}

/*
	Function: Error
			  Add error message

	Parameters:
			  txt		- Text of the message. It can contain references to AHK variables.
			  category	- Optional category. 
			  link		- Optional link. Within application link handler can be set up to fire upon link clicks. 
						  To let the user open the link with default browser return 1 from the handler function.
						  The primary use of this parameter is, however, in offline mode, i.e. when user is viewing the log in the local browser.
						  By default, link is set to "javascript:void(0)".
	
	Returns:
			  Error number.
	
	Remarks:
			  Text can be any kind of HTML with usual meaning except for new line, tab and space characters. 
			  Those will be transformed to their usual meaning. Apart from mentioned, the text
			  is normal HTML which means that you may want to additionally stylish the message. 
			  In some occasions you may also want to replace special HTML chars - for instance '<' or '>' - with appropriate HTML entities.
			  	  
			  Category parameter is optional. Use it to the put the name of the module that posted a message.
			  If logger option _tcategory_ is enabled, type will be set as category. If you use this parameter make sure you set _catwidth_ 
			  to appropriate value.


 */
Log_Error(txt, category="", link="") {
	return Log_addHtml(txt, A_ThisFunc, category, link)
}	

/*
	Function: Warning
			  Add warning message.

	Remarks:
			 See <Error> function.
 */
Log_Warning(txt, category="", link="") {
	return Log_addHtml(txt, A_ThisFunc, category, link)
}

/*
	Function: Info
			  Add info message.

	Remarks:
			 See <Error> function.
 */
Log_Info(txt, category="", link="") {
	return Log_addHTML(txt, A_ThisFunc, category, link)
}

/*
	Function: Auto
			  Add error, warning or info message.

	Remarks:
			 By default, if it sees word "error" inside message it will call <Error> function (similarly for warnings).
			 You can add comma separated list of keywords in the config file. Put error keywords in "error_kw" variable and 
			 warning fields in "warning_kw". If keywords are not matched, message will be posted as <Info>.

			 See <Error> function for other remarks.

 */
Log_Auto(txt, category="", link="") {
	static error_kw, warning_kw

	if (error_kw = "")
		Logger("*", "error_kw warning_kw", error_kw, warning_kw)

	loop, parse, error_kw, %A_Space%
		if InStr(txt, A_LoopField)
			return Log_Error(txt, category, link)

	loop, parse, warning_kw, %A_Space%
		if InStr(txt, A_LoopField)
			return Log_Warning(txt, category, link)
	
	return Log_Info(txt, category, link)
}

/*
	Function: Clear
			  Clears the Logger control.
 */
Log_Clear(){
	global Log_hwnd
	ControlSetText, , , ahk_id %Log_hwnd%
	WebControl_AddHtml(Log_hwnd, "<html><body bgcolor='" Logger("bg") "'>")

}

/*
	Function: OpenInBrowser
			  Opens the content of the logger control in the default system browser.
 */
Log_OpenInBrowser() {
	fName = %A_Temp%\%A_ScriptName%_Logger.html
	Log_Save(fName)
	Run, %fName%
}

/*
	Function: Save
			  Saves the content of the logger control in the file.

	Parameters:
			  FileName	- File name to save content to.
			  bAppend	- Set to true to append content to the file, by default false.
 */
Log_Save(FileName, bAppend = false){
	global Log_hwnd
	txt := WebControl_GetHTML(Log_hwnd)

	if (!bAppend)
		FileDelete, %FileName%
	FileAppend %txt%</body></html>, %FileName%
}

/*
	Function: SetSaveFile
			  Set up the real time save file. 

	Parameters:
			  FileName - If non empty, this file will be used to write information as soon as it is added to the control.
						 To disable real time file saving, omit this parameter. Its disabled by default.
 */
Log_SetSaveFile(FileName="") {
	file := Logger("save")
	ifNotEqual, file, ,FileAppend, </body></html>, %file%
	Logger("save", FileName)
}

;===========================================================================================

Log_addHTML( txt, type, category="", link="") {
	 global Log_hwnd
	 static warning_no, info_no, error_no, init, last_category, bTypeSep
	 static separator, imaxsize, catwidth, tcategory, catalign, icongroup
	 static space=" &nbsp;"

	 StringReplace, type, type, Log_, 	
	 StringReplace, txt, txt, `n, <br>, A
	 StringReplace, txt, txt, %A_Space%%A_Space%,%space%, A
	 StringReplace, txt, txt, %A_Tab%,%space%%space%, A

	 if SubStr(category, 1, 1)="*" 
		 category := (j := InStr(category, "_")) = -1 ? SubStr(category, 2) : SubStr(category, 2, j-2)

	 if !init {
		 imaxsize	:= Logger("imaxsize")+5
		 catwidth	:= Logger("catwidth")
		 tcategory  := Logger("tcategory")
		 catalign	:= Logger("catalign")
		 icongroup	:= Logger("icongroup")
 		 separator	:= Logger("separator")

		 if bTypeSep := (SubStr(separator, 1, 1) = "*")
			separator := SubStr(separator, 2)
		 last_category := category

		 init := 1
	 }

	 Logger("*" type "_", "bg fg isize fsize catfg", bg,fg,isize,fsize,catfg)

	 %type%_no +=1
	 no := %type%_no
	 category .= (category = "") && tcategory ? type : ""
	 link  .= link != "" ? "" : "javascript:void(0)"
	 txt := Log_derefernce(txt)

	 if (separator != "")
		sep := bTypeSep && (category != last_category) ? separator : ""

	 html =	
	 (LTrim Join
 				%sep%
				<table  bgcolor='%bg%' width=100`%>
				  <tr>
					<td align=center width=%imaxsize%px >
						 <a id='%type%%no%' href="%link%" title='%type% %no%' ><img width=%isize% height=%isize% src='%A_ScriptDir%\icons\%type%%icongroup%.png'></a>
					</td>
					<td align=%catalign% width=%catwidth%px>
						<font size=%fsize% color='%fg%'>%category%</font>
					</td>
					<td width=70`%>
						<font size=%fsize% color='%fg%'>%txt%</font>
					</td>
					<td align='right'>
						<font size=1 color='%fg%'>%A_Hour%:%A_Min%:%A_Sec%</font>
					</td>
				  </tr>
				</table>
	 ) 
	
	WebControl_AddHtml(Log_hwnd, html)
	if save := Logger("save")	
		FileAppend, %html%, %save%

	last_category := category
	return %no%
}


/*
	Storage Function	

	Usage:
		store(x)	 - return value of x
		store(x, v)  - set value of x to v and return previous value
		store("*", "x y z", x, y, z)  - get values of x, y and z into x, y and z
		store("*preffix_", "x y z", x, y, z) - get values of preffix_x, preffix_y and preffix_z into x, y and z

 */
Logger(var, value="~`a", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="") { 
	static
	ifEqual, init, , gosub Logger

	c := SubStr(var,1,1)
	if (c = "*" ){
		c := SubStr(var, 2)
		loop, parse, value, %A_Space%
			_ := %c%%A_LoopField%,   o%A_Index% := _ != "" ? _ : %A_LoopField%
		return
	}

	if InStr(var, "isize") 
		%var% := value, imaxsize := (error_isize > imaxsize) ? error_isize : warning_isize > imaxsize ? warning_isize : (info_isize > imaxsize) ? info_isize : imaxsize

	return (value !="~`a") ? %var% := value : %var%

 Logger:
	#include *i Logger_Config.ahk
	#include *i inc\Logger_Config.ahk

   ;defaults
	catwidth .= (catwidth = 0) or (catwidth = "") ? 1 : ""

	fsize	 .= fsize	!= "" ? ""   	: 1
	bg		 .= bg		!= "" ? ""   	: "white"
	fg		 .= fg		!= "" ? ""   	: "black"
	isize	 .= isize	!= "" ? ""   	: 16
	fsize    .= fsize	!= "" ? ""   	: 1
	catfg	 .= catfg	!= "" ? ""   	: fg
	catfg	 .= catfg	!= "" ? ""   	: fg
	catalign .= catalign!= "" ? ""   	: "left"
	
	error_kw .= error_kw!= "" ? ""   	: "error"
	warning_kw.= warning_kw!= "" ? ""  	: "warning"
	
	imaxsize := isize 
	imaxsize := (error_isize > imaxsize) ? error_isize : warning_isize > imaxsize ? warning_isize : (info_isize > imaxsize) ? info_isize : imaxsize
	if tcategory && (catwidth=1)
		catwidth = 100
	init := 1
 return 
}

; Dereference variables in text
Log_derefernce(txt) {
	global
	local match, match1, val

	loop{
		if !(j := RegExMatch(txt, "i)%([^ \t%]+)%", match))
			break

		val := %match1%
		StringReplace, txt, txt, `%%match1%`%, %val%, A
	}
	return txt
}


; Function that runs every minut to handle saveHour
Log_saveTimer( init = false ) {
	static saveHour, lastSave, b, logdir, timeformat
	if (saveHour = "")
		Logger("*", "saveHour logdir timeFormat", saveHour, logdir, timeformat),  lastSave := A_Now,   b := SubStr(saveHour, 1, 1) = "*",   saveHour := b ? SubStr(saveHour,2) : saveHour
	
	if !init	
	{
		if b {
			t -= lastSave, hours
			ifLess, t, %saveHour%, return				
		} 
		else ifNotEqual, A_Hour, %saveHour%, return
	}

	FormatTime, time, , %timeFormat%
	fn :=  (logdir ? logdir "\" : "") time ".htm"
	Log_Clear(), Log_SetSaveFile( fn )
	lastSave := A_Now
}

Log_saveTimer:
	Log_saveTimer()
return


Log_handler(hLogger, Type, Id) {
	static handler=0
	
	if handler = 0
		handler := Logger("handler")
	
	RegExMatch(Id, "(.+?)([0-9]+)", out)

	return IsFunc(handler) ? %handler%(out1, out2) : 0
}

;================= WEB CONTROL INTERFACE =============================

WebControl_Add(hCtrl, Text, X, Y, W, H, Style="", Fun=""){
	return QHTM_Add(hCtrl, X, Y, W, H, Text, Style, Fun)
}

WebControl_AddHtml(hCtrl, HTML, bScroll=false){
	return QHTM_AddHtml( hCtrl, HTML, bScroll )
}

WebControl_GetHtml(hCtrl){
	return QHTM_GetHTML(hCtrl)
}

#include *i qhtm.ahk
#include *i inc\qhtm.ahk

;================ WEB CONTROL INTERFACE END ==========================

/* 
 Group: Example
(start code)
	#SingleInstance force
		Gui, +LastFound
		hGui := WinExist()
		Log_Add( hGui, 0, 0, 600, 500)
		Gui, show, w600 h500

		Log_Info("This is some info"), s()
		Log_Error("Error ocured`nThis is the description of the error"), s()
		Log_Warning("This is warning"), s()

		Log_Auto("This is some info"), s()
		Log_Auto("Error ocured`nThis is the description of the error"), s()
		Log_Auto("This is warning"), s()

	return

	s() {
		Random, x, 1, 3
		Sleep, % x*1000
	}

(end code)
 */


/* 
 Group: About 
 	o Logger ver 1.0 by majkinetor.
	o QHTM copyright © GipsySoft. See http://www.gipsysoft.com/qhtm/
	o Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/>
 */

#include qhtm.ahk