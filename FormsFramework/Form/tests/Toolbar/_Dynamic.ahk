_("mo!")

    w := 600, h := 400
    hForm  := Form_New("Resize e3 w" w " h" h)

    hToolbar := Form_Add(hForm, "Toolbar", "", "gOnToolbar il=1L", "Align T, 35", "Attach w")
    hPanel   := Form_Add(hForm, "Panel", "", "", "Align F", "Attach w h")

    he := Form_Add(hPanel, "Edit", "Resize window so that toolbar doesn't fit", "r2", "Align T,100", "Attach p")
	hs := Form_Add(hPanel, "Splitter", "", "sunken", "Align T, 10", "Attach p")
    hm := Form_Add(hPanel, "MonthCal", "", "", "Align F", "Attach p")
    Toolbar_Insert(hToolbar, "cut`ncopy`npaste`nredo`nundo`ncopy`npaste`nredo`nundo`ncopy`npaste`nredo`nundo`nundo`nundo")
	Toolbar_SetMaxTextRows(hToolbar)
	Splitter_Set(hs, he " - " hm)

	Form_Show(hForm, "w500")
return 

Form1_Size:
	Toolbar_Size(hToolbar, hPanel)
return

Toolbar_Size(hToolbar, hPanel) {
	static last

	if last =
		return last := Win_GetRect(hToolbar, "h")

	th := Win_GetRect(hToolbar, "h")
	if (th != last)
	{
		Win_GetRect(hPanel, "*yh", py, ph)
		Win_Move(hPanel, "", last := th, "", ph-(th-py))
		Attach()	;reset Form1
	}
}

#include ..\..\inc
#include _Forms.ahk