/* 
 Function:  ShowTooltip 
            Show the tooltip and automatically dismiss it. 

 Parameters: 
            Text     - Text to show. If omitted or empty, any existing tooltip will be hidden. 
            X,Y      - Coordinates on which to show tooltip. Affected by CoordMode. Optional. 
            In, Out  - Time in milliseconds for tooltip to show and to disappear. 
                     - If TimeOut is 0, tooltip will never be dismissed. Optional. 
            bControl - Set to TRUE to associate the tooltip with control currently under the mouse. 
                     - That means that Tooltip will not be shown if control has changed. By default, false 
            Nr          - Tooltip number, by default 19. Multiple tooltips can exist with different settings. 

 About: 
            o v2.0 by HotKeyIt 
 */ 
ShowToolTip(Text="", X="",Y="", In=500, Out=1500, bControl=0, Nr=19){ 
   static 
   If (Text=""){ 
      MouseGetPos,,,_win,_ctrl 
      ControlGet,hCtrl,HWND,,%_ctrl%,ahk_id %_win% 
      If ((T_Text%Nr% && !T_%Nr% && T_In%Nr%<A_TickCount && (!T_Ctrl%Nr% or (T_Ctrl%Nr% && hCtrl=T_Ctrl%Nr%))) || (T_%Nr% && T_Out%Nr%<A_TickCount && !((T_Text%Nr%:="") . (T_X%Nr%:="") . (T_Y%Nr%:="") . (T_In%Nr%:="") . (T_Out%Nr%:="") . (T_%Nr%:="") . (T_Ctrl%Nr%:="")))) 
         ToolTip % T_Text%Nr%,% T_X%Nr%,% T_Y%Nr%,% Nr+(T_Text%Nr% ? ((T_%Nr%:=1)-1) : 0) 
      Return (!T_%Nr% ? T_In%Nr% : (T_Out%Nr%>A_TickCount ? T_Out%Nr% : "")) 
   } else if (bControl=1){ 
      MouseGetPos,,,_win,_ctrl 
      ControlGet,T_Ctrl%Nr%,HWND,,%_ctrl%,ahk_id %_win% 
   } else T_Ctrl%Nr%:=0 
   T_Text%Nr%:=text,T_X%Nr%:= X,T_Y%Nr%:= Y,T_In%Nr%:=Round(A_TickCount+In),T_Out%Nr%:=(Out ? Round(A_TickCount+In+Out) : 9223372036854775807) 
   ShowToolTip: 
      NextTimer= 
      Loop 20 
         If (ErrorLevel:=ShowToolTip("","","","","","",A_Index)) 
            If (!NextTimer || NextTimer+A_TickCount>ErrorLevel) 
               NextTimer:=(ErrorLevel-A_TickCount<0) ? "" : (ErrorLevel-A_TickCount+10) 
      SetTimer, ShowToolTip,% NextTimer ? (-1*(NextTimer+10)) : "Off" 
   Return 
}