;-------------------------------------------------------------------------
; Function:	 Send
;			 Send the message to another process (receiver) using WM_COPYDATA.
;
; Parameters:
;			 hwnd - Handle of the receiver
;			 msg  - Optional message to be sent. Default is empty message.
;			 port - Optional port, by default 100
;
; Returns:	 
;			 FAIL on error, 0 on success
;
IPC_Send(hwnd, msg="", port=100) {
	static WM_COPYDATA = 74, id=951753	;id is for security reasons

	len := StrLen(msg)              
	VarSetCapacity(CopyDataStruct, 12, 0)
	NumPut(port,	CopyDataStruct, 0)
	NumPut(len + 1, CopyDataStruct, 4)             
	NumPut(&msg,	CopyDataStruct, 8)             
	
   	SendMessage, WM_COPYDATA, id, &CopyDataStruct,, ahk_id %hwnd%
	return ErrorLevel
}

;-------------------------------------------------------------------------
; Function:	 OnMessage
;			 Set the message handler
;
; Parameters:
;			 label - Subroutine that will be called when message is received.
;					 IPC_Message & IPC_Port global vars will contain message info.
;
; Returns:	 
;			 false invalid label, true on success
;
IPC_OnMessage( pLabel ){
	global
	static WM_COPYDATA = 74, id=951753	;id is for security reasons

	if !IsLabel(pLabel)
		return false
	
	IPC_OnMessage := pLabel
	OnMessage(WM_COPYDATA, "IPC_OnCopyData")
	return true
}

;private IPC function, wm_copydata monitor
IPC_OnCopyData(wparam, lparam) {
	local  pStr

	IPC_Port := NumGet(lparam+0), pStr	 := NumGet(lparam+8)
	IPC_Message := DllCall("MulDiv", "Int", pStr, "Int",1, "Int",1, "str") 

	gosub %IPC_OnMessage%
	return 1
}