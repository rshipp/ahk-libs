/* Title: ShowMenu
*/

/*
 Function:		ShowMenu
				Show menu from the text.
  
 Parameters: 
				MDef	- Textual menu definition.
				Mnu		- Menu to show. Label with the same name as menu will be launched on item selection.
						  "" means first menu will be shown (default)
				Sub		- Optional subroutine that will override default label (named by menu)
				Sep		- Optional separator char used for menu items in menu definition, by default new line
				
 Returns:      
				Message describing error if it occurred or new line separated list of created menus.
				If return value is blank, ShowMenu just displayed menu already created in one of previous calls.

	
 Remarks:
				You must have in the code label with the same name as that given to the menu, otherwise
				ShowMenu returns "No Label" error (unless you used "sub" parameter in which case the same 
				applies to that subroutine). There must be no white space between menu name and start of the line.
				Set each menu item on new line, use "-" to define separator.

 Metachars:
				To create *submenu*, use "item = [submenu]" notation where submenu must exist in the textual 
				menu definition. Referencing any particular menu as submenu multiple times will work 
				correctly, but circular references must be avoided.
				To make item *checked*, use "+" as first character of its name, to make it *disabled* use "*".
				To associated *user data* use "=data" after the item. If text after = doesn't contain valid
				submenu reference, it will be seen as user data. This also means that submenu items can contain data.
				To make menu definition more compact use something else then new line as item separator
				for instance "|" :
 >
 >					[Mnu1]
 >					item1|item2|item3|-|item4=[Mnu2]|item5
 >					[Mnu2]
 >					menu21 = menu21|menu22|menu23|menu24									  
 >				
				You can then use this command to show the menu
 >					ShowMenu(mDef, "", "", "|")				;use first menu found and | as item separator

 About:
				o v1.2 by majkinetor
				o Licensed under BSD <http://creativecommons.org/licenses/BSD/>.
 */
ShowMenu( mDef, mnu="", sub="", sep="`n", r=0 ) {
	static p, menus
	if (!r)  {
		if (mnu = "") and (SubStr(mDef, 1, 1) = "[")				;use first menu if mnu = ""
			mnu := SubStr(mDef, 2, InStr(mDef, "]")- 2)
		p := sub="" ? mnu : sub, menus:=""							;set on function call (not on recursion step)
	}

	Menu, %mnu%, UseErrorLevel, on
	Menu, %mnu%, Color,											    ;check if menu already exists
	if !ErrorLevel
		if !r {														;if this is first call, show the menu
			Menu, %mnu%, Show
			return 
		} else return												; otherwise this is recursion step so just return
	
	if !(r || IsLabel(p))
		return "No Label"

	if !(s := SubStr(mDef, 1, StrLen(mnu)+2) = "[" mnu "]" )		;start index
		s := InStr(mDef, "`n[" mnu "]")
	IfEqual, s, 0, Return "Menu not found"
	
	if !(e := InStr(mDef, "`n[",false, s+1))						;end index
		e := StrLen(mDef)		

 	if *(&mDef+s-1) = 10											;skip `n if on start
		s++
	s += Strlen(mnu)+3, this := SubStr(mDef, s, e-s+1)				;extract menu def

	menus .= mnu "`n"
	Loop, parse, this, %sep%, `n`r
	{
		s := A_LoopField
		IfEqual, s, ,continue
		IfEqual, s,-,SetEnv,s,										;separator
		if j := RegExMatch(s, "S)(?<=\[).+?(?=\])", out)			;check for submenu	
			 s := SubStr(s, 1, InStr(s,"=")-1),   ShowMenu( mDef, out, sub, sep, 1)
		else if k := InStr(s,"=")									;if it has = after it remove it
			s := SubStr(s, 1, k-1)

		if (c:=(*&s = 43)) or ((*&s=42) and c:=2)
			StringTrimLeft, s, s, 1
		Menu, %mnu%, Add, %s%, % j ? ":" out : p
		IfEqual, c, 1, Menu, %mnu%, Check, %s%
		IfEqual, c, 2, Menu, %mnu%, Disable, %s%

	}

	IfEqual, r, 0 , Menu, %mnu%, Show								;if not in recursion, show
	return menus
}
/*
 Function:		ShowMenu_Data
				Get data associated with menu item
  
 Parameters: 
				mDef	- Textual menu definition.
				item	- Menu item which associated data will be returned, if omited defaults to A_ThisMenuItem
				
 Returns:      
 				Associated data or empty string if no data is associated with item.
 */
ShowMenu_Data(mDef, item="") {
	if item=
		item := A_ThisMenuItem
	mDef .= "`n"
	j := InStr(mDef, item "=")
	IfEqual, j, 0, return 
	j += StrLen(item)+1
	return SubStr(mDef, j, InStr(mDef, "`n", false, j)-j)
}