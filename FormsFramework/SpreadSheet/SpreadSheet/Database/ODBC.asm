;
; Macro for easier error messages, actually a CTEXT variation
Err MACRO y:VARARG
	LOCAL sym

CONST segment
	IFIDNI <y>,<>
		sym db 0
	ELSE
		sym db y,0
	ENDIF
CONST ends

	invoke MessageBox,hWnd,offset sym,offset szLibName,MB_OK
	mov 	eax,TRUE
endm

.data

szDatabase		db 'mydb.mdb',0

; Connect
szConnect		db 'DRIVER={Microsoft Access Driver (*.mdb)};DBQ=mydb.mdb;',0

; Create
szDriver		db 'Microsoft Access Driver (*.mdb)',0
szAttributes	db 'CREATE_DB=mydb.mdb General',0
szCreateTable	db 'CREATE TABLE Person (ID autoincrement,LastName varchar,FirstName varchar,Address varchar,Phone varchar)',0

; Select
szSelect		db 'SELECT * FROM Person ORDER BY LastName,FirstName,Address,Phone',0

; Update
szUpdate		db "UPDATE Person SET %s='%s' WHERE ID=%u",0
szLastName		db 'LastName',0
szFirstName		db 'FirstName',0
szAddress		db 'Address',0
szPhone			db 'Phone',0

; Add row
szInsert		db "INSERT INTO Person (LastName,FirstName,Address,Phone) VALUES('','','','')",0
szSelectTop		db 'SELECT TOP 1 ID FROM Person ORDER BY ID DESC',0
szEmpty			db 0

;Delete row
szDelete		db 'DELETE FROM Person WHERE ID=%u',0

.data?

; SQL handles
hEnv		dd ?
hConn		dd ?
; Columns in the table
nID			dd ?
LastName	db 256 dup(?)
FirstName	db 256 dup(?)
Address		db 256 dup(?)
Phone		db 256 dup(?)

nRows		dd ?

.code

;Connect to database
ODBCConnect proc uses esi edi
	LOCAL	lnCon:DWORD

	invoke SQLAllocHandle,SQL_HANDLE_ENV,SQL_NULL_HANDLE,offset hEnv
	.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
		invoke SQLSetEnvAttr,hEnv,SQL_ATTR_ODBC_VERSION,SQL_OV_ODBC3,0
		.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
			invoke SQLAllocHandle,SQL_HANDLE_DBC,hEnv,offset hConn
			.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
				invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024
				mov		esi,eax
				invoke lstrcpy,esi,offset szConnect
				invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024
				mov		edi,eax
				invoke lstrlen,esi
				mov		edx,eax
				invoke SQLDriverConnect,hConn,0,esi,edx,edi,1024,addr lnCon,SQL_DRIVER_COMPLETE
				.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
					xor		eax,eax
				.else
					invoke SQLFreeHandle,SQL_HANDLE_DBC,hConn
					invoke SQLFreeHandle,SQL_HANDLE_ENV,hEnv
					mov		hConn,0
					mov		hEnv,0
					Err 'Unable to connect to the database.'
				.endif
				push	eax
				invoke GlobalFree,esi
				invoke GlobalFree,edi
				pop		eax
			.else
				invoke SQLFreeHandle,SQL_HANDLE_ENV,hEnv
				mov		hEnv,0
				Err 'Unable to allocate ODBC connection handle.'
			.endif
		.else
			invoke SQLFreeHandle,SQL_HANDLE_ENV,hEnv
			mov		hEnv,0
			Err 'Unable to set ODBC environment attributes.'
		.endif
	.else
		Err 'Unable to allocate ODBC environment handle.'
	.endif
	ret

ODBCConnect endp

;Disconnect from database
ODBCDisconnect proc

	.if hConn
		invoke SQLDisconnect,hConn
		invoke SQLFreeHandle,SQL_HANDLE_DBC,hConn
		invoke SQLFreeHandle,SQL_HANDLE_ENV,hEnv
		mov		hConn,0
		mov		hEnv,0
	.endif
	ret

ODBCDisconnect endp

;Create table
ODBCCreateTable proc
	LOCAL	hStmt:DWORD

	invoke SQLAllocHandle,SQL_HANDLE_STMT,hConn,addr hStmt
	.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
		invoke lstrlen,addr szCreateTable
		invoke SQLExecDirect,hStmt,addr szCreateTable,eax
		.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
			xor eax,eax
		.else
			Err "Failed to execute query."
		.endif
		push	eax
		invoke SQLFreeHandle,SQL_HANDLE_STMT,hStmt
		pop		eax
	.else
		Err 'Unable to allocate statement handle.'
	.endif
	ret

ODBCCreateTable endp

;Create new database
ODBCCreateDatabase proc

	invoke SQLConfigDataSource,NULL,ODBC_ADD_DSN,addr szDriver,addr szAttributes
	.if eax
		invoke ODBCConnect
		.if !eax
			invoke ODBCCreateTable
			invoke ODBCDisconnect
		.endif
	.else
		Err 'Unable to create database.'
	.endif
	ret

ODBCCreateDatabase endp

;Get all rows in the table
ODBCGetData proc uses ebx esi edi
	LOCAL	hStmt:DWORD
	LOCAL	len:DWORD

	mov		nRows,0
	invoke SQLAllocHandle,SQL_HANDLE_STMT,hConn,addr hStmt
	.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
		invoke SQLSetStmtAttr,hStmt,SQL_ATTR_CONCURRENCY,SQL_CONCUR_ROWVER,0
		invoke SQLSetStmtAttr,hStmt,SQL_ATTR_CURSOR_TYPE,SQL_CURSOR_KEYSET_DRIVEN,0
		invoke lstrlen,addr szSelect
		invoke SQLExecDirect,hStmt,addr szSelect,eax
		.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
		  @@:
			; ID
			invoke SQLBindCol,hStmt,1,SQL_INTEGER,addr nID,4,addr len
			; Last name
			invoke SQLBindCol,hStmt,2,SQL_CHAR,addr LastName,256,addr len
			; First name
			invoke SQLBindCol,hStmt,3,SQL_CHAR,addr FirstName,256,addr len
			; Address
			invoke SQLBindCol,hStmt,4,SQL_CHAR,addr Address,256,addr len
			; First name
			invoke SQLBindCol,hStmt,5,SQL_CHAR,addr Phone,256,addr len
			; Get row
			invoke SQLFetch,hStmt
			.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
				inc		nRows
				invoke SendMessage,hSpr,SPRM_SETROWCOUNT,nRows,0
				mov		spri.flag,SPRIF_TYPE or SPRIF_DATA or SPRIF_TEXTALIGN
				mov		spri.col,1
				mov		eax,nRows
				mov		spri.row,eax
				mov		spri.fmt.tpe,TPE_INTEGER or TPE_FORCETYPE
				mov		spri.fmt.txtal,FMTA_RIGHT
				mov		spri.lpdta,offset nID
				invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
				mov		spri.flag,SPRIF_TYPE or SPRIF_DATA or SPRIF_TEXTALIGN
				mov		spri.col,2
				mov		eax,nRows
				mov		spri.row,eax
				mov		spri.fmt.tpe,TPE_TEXT or TPE_FORCETYPE
				mov		spri.fmt.txtal,FMTA_LEFT
				mov		spri.lpdta,offset LastName
				invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
				mov		spri.col,3
				mov		eax,nRows
				mov		spri.row,eax
				mov		spri.fmt.tpe,TPE_TEXT or TPE_FORCETYPE
				mov		spri.fmt.txtal,FMTA_LEFT
				mov		spri.lpdta,offset FirstName
				invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
				mov		spri.col,4
				mov		eax,nRows
				mov		spri.row,eax
				mov		spri.fmt.tpe,TPE_TEXT or TPE_FORCETYPE
				mov		spri.fmt.txtal,FMTA_LEFT
				mov		spri.lpdta,offset Address
				invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
				mov		spri.col,5
				mov		eax,nRows
				mov		spri.row,eax
				mov		spri.fmt.tpe,TPE_TEXT or TPE_FORCETYPE
				mov		spri.fmt.txtal,FMTA_LEFT
				mov		spri.lpdta,offset Phone
				invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
				cmp		nRows,32700
				jne		@b
			.endif
		.else
			Err "Failed to execute query."
		.endif
		invoke SQLFreeHandle,SQL_HANDLE_STMT,hStmt
	.else
		Err 'Unable to allocate statement handle.'
	.endif
	ret

ODBCGetData endp

ODBCAddRow proc
	LOCAL	hStmt:DWORD
	LOCAL	len:DWORD

	invoke SQLAllocHandle,SQL_HANDLE_STMT,hConn,addr hStmt
	.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
		invoke SQLSetStmtAttr,hStmt,SQL_ATTR_CONCURRENCY,SQL_CONCUR_ROWVER,0
		invoke SQLSetStmtAttr,hStmt,SQL_ATTR_CURSOR_TYPE,SQL_CURSOR_KEYSET_DRIVEN,0
		invoke lstrlen,addr szInsert
		invoke SQLExecDirect,hStmt,addr szInsert,eax
		.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
			invoke lstrlen,addr szSelectTop
			invoke SQLExecDirect,hStmt,addr szSelectTop,eax
			.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
				; ID
				invoke SQLBindCol,hStmt,1,SQL_INTEGER,addr nID,4,addr len
				invoke SQLFetch,hStmt
				.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
					inc		nRows
					invoke SendMessage,hSpr,SPRM_SETROWCOUNT,nRows,0
					mov		spri.flag,SPRIF_TYPE or SPRIF_DATA or SPRIF_TEXTALIGN
					mov		spri.col,1
					mov		eax,nRows
					mov		spri.row,eax
					mov		spri.fmt.tpe,TPE_INTEGER or TPE_FORCETYPE
					mov		spri.fmt.txtal,FMTA_RIGHT
					mov		spri.lpdta,offset nID
					invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
					mov		spri.flag,SPRIF_TYPE or SPRIF_DATA or SPRIF_TEXTALIGN
					mov		spri.col,2
					mov		eax,nRows
					mov		spri.row,eax
					mov		spri.fmt.tpe,TPE_TEXT or TPE_FORCETYPE
					mov		spri.fmt.txtal,FMTA_LEFT
					mov		spri.lpdta,offset szEmpty
					invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
					mov		spri.col,3
					mov		eax,nRows
					mov		spri.row,eax
					mov		spri.fmt.tpe,TPE_TEXT or TPE_FORCETYPE
					mov		spri.fmt.txtal,FMTA_LEFT
					mov		spri.lpdta,offset szEmpty
					invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
					mov		spri.col,4
					mov		eax,nRows
					mov		spri.row,eax
					mov		spri.fmt.tpe,TPE_TEXT or TPE_FORCETYPE
					mov		spri.fmt.txtal,FMTA_LEFT
					mov		spri.lpdta,offset szEmpty
					invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
					mov		spri.col,5
					mov		eax,nRows
					mov		spri.row,eax
					mov		spri.fmt.tpe,TPE_TEXT or TPE_FORCETYPE
					mov		spri.fmt.txtal,FMTA_LEFT
					mov		spri.lpdta,offset szEmpty
					invoke SendMessage,hSpr,SPRM_SETCELLDATA,0,addr spri
					xor		eax,eax
				.else
					Err "Failed to execute query."
				.endif
			.else
				Err "Failed to execute query."
			.endif
		.else
			Err "Failed to execute query."
		.endif
		invoke SQLFreeHandle,SQL_HANDLE_STMT,hStmt
	.else
		Err 'Unable to allocate statement handle.'
	.endif
	ret

ODBCAddRow endp

ODBCDeleteRow proc nRow:DWORD,lpRowID:DWORD
	LOCAL	hStmt:DWORD
	LOCAL	len:DWORD
	LOCAL	buffer[1024]:BYTE

	invoke SQLAllocHandle,SQL_HANDLE_STMT,hConn,addr hStmt
	.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
		invoke SQLSetStmtAttr,hStmt,SQL_ATTR_CONCURRENCY,SQL_CONCUR_ROWVER,0
		invoke SQLSetStmtAttr,hStmt,SQL_ATTR_CURSOR_TYPE,SQL_CURSOR_KEYSET_DRIVEN,0
		mov		eax,lpRowID
		mov		eax,[eax]
		invoke wsprintf,addr buffer,addr szDelete,eax
		invoke lstrlen,addr buffer
		invoke SQLExecDirect,hStmt,addr buffer,eax
		.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
			invoke SendMessage,hSpr,SPRM_DELETEROW,nRow,0
			dec		nRows
			invoke SendMessage,hSpr,SPRM_SETROWCOUNT,nRows,0
			mov		eax,nRows
			.if eax<nRow
				invoke SendMessage,hSpr,SPRM_SETCURRENTCELL,1,eax
			.endif
			xor		eax,eax
		.else
			Err "Failed to execute query."
		.endif
		invoke SQLFreeHandle,SQL_HANDLE_STMT,hStmt
	.else
		Err 'Unable to allocate statement handle.'
	.endif
	ret

ODBCDeleteRow endp

ODBCUpdate proc lpRowID:DWORD,lpCol:DWORD,lpData:DWORD
	LOCAL	hStmt:DWORD
	LOCAL	len:DWORD
	LOCAL	buffer[1024]:BYTE

	invoke SQLAllocHandle,SQL_HANDLE_STMT,hConn,addr hStmt
	.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
		invoke SQLSetStmtAttr,hStmt,SQL_ATTR_CONCURRENCY,SQL_CONCUR_ROWVER,0
		invoke SQLSetStmtAttr,hStmt,SQL_ATTR_CURSOR_TYPE,SQL_CURSOR_KEYSET_DRIVEN,0
		mov		eax,lpRowID
		mov		eax,[eax]
		invoke wsprintf,addr buffer,addr szUpdate,lpCol,lpData,eax
		invoke lstrlen,addr buffer
		invoke SQLExecDirect,hStmt,addr buffer,eax
		.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
			xor		eax,eax
		.else
			Err "Failed to execute query."
		.endif
		invoke SQLFreeHandle,SQL_HANDLE_STMT,hStmt
	.else
		Err 'Unable to allocate statement handle.'
	.endif
	ret

ODBCUpdate endp

