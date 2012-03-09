#f::MsgBox, % ShellFolder() 
#m::ShellNavigate(A_MyDocuments, True) 
#p::ShellNavigate(A_ProgramFiles) 
#s::ShellNavigate(A_ScriptDir) 
#w::ShellNavigate(A_WinDir) 


ShellNavigate(sPath, bExplore=False, hWnd=0) 
{ 
   COM_Init() 
   psh  :=   COM_CreateObject("Shell.Application") 
   If   hWnd||(hWnd:=WinExist("ahk_class CabinetWClass"))||(hWnd:=WinExist("ahk_class ExploreWClass")) 
   { 
      psw  :=   COM_Invoke(psh, "Windows") 
      Loop, %   COM_Invoke(psw, "Count") 
         If   COM_Invoke(pwb:=COM_Invoke(psw, "Item", A_Index-1), "hWnd") <> hWnd 
            COM_Release(pwb) 
         Else   Break 
      COM_Invoke(pwb, "Navigate2", sPath) 
      COM_Release(pwb) 
      COM_Release(psw) 
   } 
   Else   COM_Invoke(psh, bExplore ? "Explore" : "Open", sPath) 
   COM_Release(psh) 
   COM_Term() 
} 

ShellFolder(hWnd=0) 
{ 
   If   hWnd||(hWnd:=WinExist("ahk_class CabinetWClass"))||(hWnd:=WinExist("ahk_class ExploreWClass")) 
   { 
      COM_Init() 
      psh  :=   COM_CreateObject("Shell.Application") 
      psw  :=   COM_Invoke(psh, "Windows") 
      Loop, %   COM_Invoke(psw, "Count") 
         If   COM_Invoke(pwb:=COM_Invoke(psw, "Item", A_Index-1), "hWnd") <> hWnd 
            COM_Release(pwb) 
         Else   Break 
      pfv  :=   COM_Invoke(pwb, "Document") 
      sFolder   := COM_Invoke(pfi:=COM_Invoke(psf:=COM_Invoke(pfv, "Folder"), "Self"), "Path"), COM_Release(psf), COM_Release(pfi), pfi:=0 
      sFocus   := COM_Invoke(pfi:=COM_Invoke(pfv, "FocusedItem"), "Name"), COM_Release(pfi), pfi:=0 
      Loop, %   COM_Invoke(psi:=COM_Invoke(pfv, "SelectedItems"), "Count") 
         sSelect   .= COM_Invoke(pfi:=COM_Invoke(psi, "Item", A_Index-1), "Name") . "`n", COM_Release(pfi), pfi:=0 
      COM_Release(psi) 
      COM_Release(pfv) 
      COM_Release(pwb) 
      COM_Release(psw) 
      COM_Release(psh) 
      COM_Term() 
      Return   "Folder:`t" . sFolder . "`nFocus:`t" . sFocus . "`n<Selected Items>`n" . sSelect 
   } 
}