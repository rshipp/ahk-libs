; Sean: http://www.autohotkey.com/forum/viewtopic.php?p=156245#156245
; Thread: http://www.autohotkey.com/forum/viewtopic.php?t=78216
; MSDN: http://msdn.microsoft.com/en-us/library/windows/desktop/aa384106(v=vs.85).aspx

class WinHttpRequest {
    
    static _id := 1
    
    __new(callback = "`r", id = "") {
        ; msgbox % A_ThisFunc "`n" callback "`n" id
        ObjInsert(this, "", [])
        meta := this[""]
        meta.whr      := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        meta.pwhr     := ComObjUnwrap(meta.whr)
        meta.callback := callback != "`r" ? callback : ""
        meta.id       := IsObject(id) OR id ? id : WinHttpRequest._id++
        
        if IsObject(callback) OR IsFunc(callback)
            WinHttpRequest.Connect.(this)
    }
    
    __call( method, args* ) {
        ; msgbox % A_ThisFunc "`n" method "`n" LSON(args)
        return (this["","whr"])[method](args*)
    }
    
    __get( key ) {
        ; msgbox % A_ThisFunc "`n" key
        return this["","whr"][key]
    }
    
    __set( key, value ) {
        ; msgbox % A_ThisFunc "`n" key "`n" (IsObject(value) ? LSON(value) : value)
        return this["","whr"][key] := value
    }
    
    __delete() {
        meta := this[""]
        WinHttpRequest.Unadvise(meta.pconn, meta.cookie)
        WinHttpRequest.Release(meta.pconn)
        WinHttpRequest.CoTaskMemFree(meta.psink)
        for fn, addr in meta.rcb
            DllCall("GlobalFree", "UInt", addr)
        for i, addr in meta.objref
            ObjRelease(addr)
    }
    
    Connect() {
        static EventMethods := [{ name: "QueryInterface"         , params: 3 }
                               ,{ name: "AddRef"                 , params: 1 }
                               ,{ name: "Release"                , params: 1 }
                               ,{ name: "OnResponseStart"        , params: 3 }
                               ,{ name: "OnResponseDataAvailable", params: 2 }
                               ,{ name: "OnResponseFinished"     , params: 1 }
                               ,{ name: "OnError"                , params: 3 }]
        meta := this[""]
        if !meta.GetCapacity("IWinHttpRequestEvents")
        {
            ;save registercallback points and object references for releasing when `this` is deleted
            meta.rcb := [], meta.objref := []
            meta.SetCapacity("IWinHttpRequestEvents", 7*A_PtrSize)
            off := pwhre := meta.GetAddress("IWinHttpRequestEvents")
            for i, fn in EventMethods
            {
                meta.objref[A_Index] := Object({ meta: meta, name: fn.name })
                meta.rcb[A_Index]    := RegisterCallback("WinHttpRequest.EventHandler", "", fn.params, meta.objref[A_Index])
                off := NumPut(meta.rcb[A_Index], off+0)
            }
        }
        IID_IWinHttpRequestEvents := "{F97F4E15-B787-4212-80D1-D380CBBF982E}"
        meta.pconn := WinHttpRequest.FindConnectionPoint(meta.pwhr, IID_IWinHttpRequestEvents)
        meta.psink := WinHttpRequest.CoTaskMemAlloc(4*A_PtrSize)
        off := NumPut(pwhre     , meta.psink+0)
        off := NumPut(meta.pwhr , off+0)
        off := NumPut(meta.pconn, off+0)
        meta.cookie := WinHttpRequest.Advise(meta.pconn, meta.psink)
        off := NumPut(meta.cookie, off+0)
    }
    
    EventHandler(nStatus = "", pType = "") {
        Critical
        info := Object(A_EventInfo)
        func := info.name
        meta := info.meta
        
        if (func = "QueryInterface")
            NumPut(this, pType+0)
        else if (func = "AddRef") {
        }
        else if (func = "Release") {
        }
        else if IsFunc(meta.callback)
            meta.callback.(meta.id, nStatus, pType, func)
        else if IsFunc(meta.callback[func])
            meta.callback[func].(meta.id, nStatus, pType)
        return 0
    }
    
    ; COM_L functions by Sean :: http://www.autohotkey.com/forum/viewtopic.php?t=22923
    FindConnectionPoint(pdp, DIID) {
        DllCall(NumGet(NumGet(1*pdp)+ 0), "Uint", pdp, "Uint", WinHttpRequest.GUID4String(IID_IConnectionPointContainer, "{B196B284-BAB4-101A-B69C-00AA00341D07}"), "UintP", pcc)
        DllCall(NumGet(NumGet(1*pcc)+16), "Uint", pcc, "Uint", WinHttpRequest.GUID4String(DIID,DIID), "UintP", pcp)
        DllCall(NumGet(NumGet(1*pcc)+ 8), "Uint", pcc)
        Return	pcp
    }
    CoTaskMemAlloc(cb) {
        Return	DllCall("ole32\CoTaskMemAlloc", "Uint", cb)
    }
    CoTaskMemFree(pv) {
            DllCall("ole32\CoTaskMemFree", "Uint", pv)
    }
    GUID4String(ByRef CLSID, String) {
        VarSetCapacity(CLSID,16,0)
        DllCall("ole32\CLSIDFromString", "Uint", &String, "Uint", &CLSID)
        Return	&CLSID
    }
    Advise(pcp, psink) {
        DllCall(NumGet(NumGet(1*pcp)+20), "Uint", pcp, "Uint", psink, "UintP", nCookie)
        Return	nCookie
    }
    Unadvise(pcp, nCookie) {
        Return	DllCall(NumGet(NumGet(1*pcp)+24), "Uint", pcp, "Uint", nCookie)
    }

}
