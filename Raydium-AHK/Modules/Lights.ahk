class Lights
{
    __New(hModule)
    {
        Raydium.Lights.pColors := DllCall("GetProcAddress","UPtr",hModule,"AStr","raydium_light_color")
        Raydium.Lights.pIntensities := DllCall("GetProcAddress","UPtr",hModule,"AStr","raydium_light_intensity")

        this[1] := new Raydium.Lights.Light(1)
        this[2] := new Raydium.Lights.Light(2)
        this[3] := new Raydium.Lights.Light(3)
        this[4] := new Raydium.Lights.Light(4)
        this[5] := new Raydium.Lights.Light(5)
        this[6] := new Raydium.Lights.Light(6)
        this[7] := new Raydium.Lights.Light(7)
        this[8] := new Raydium.Lights.Light(8)
    }

    class Light
    {
        __New(Index)
        {
            If Index Not Between 1 And 8
                throw Exception("Invalid light index: " . Index . ".",-1)
            ObjInsert(this,"",Object())
            this.Index := Index
            this.State := 0
            this.Position := [0.0,0.0,0.0]
            this.Intensity := 1000000
            this.Color := [1.0,1.0,1.0]
        }

        __Get(Key)
        {
            If (Key != "")
                Return, this[""][Key]
        }

        __Set(Key,Value)
        {
            If (Key = "State")
            {
                If Value
                    DllCall("Raydium.dll\raydium_light_on","UInt",this.Index - 1,"CDecl") ;turn on the light
                Else
                    DllCall("Raydium.dll\raydium_light_off","UInt",this.Index - 1,"CDecl") ;turn off the light
            }
            Else If (Key = "Position")
            {
                If !IsObject(Value)
                    throw Exception("Invalid position: " . Position . ".",-1)
                VarSetCapacity(LightPosition,16)
                NumPut(Value[1],LightPosition,0,"Float")
                NumPut(Value[2],LightPosition,4,"Float")
                NumPut(Value[3],LightPosition,8,"Float")
                NumPut(0,LightPosition,12,"Float")
                DllCall("Raydium.dll\raydium_light_move","UInt",this.Index - 1,"UPtr",&LightPosition,"CDecl") ;move the light
            }
            Else If (Key = "Intensity")
            {
                If Value Is Not Number
                    throw Exception("Invalid color: " . Position . ".",-1)
                Index := this.Index - 1
                NumPut(Value,Raydium.Lights.pIntensities,Index << 2,"Float")
                DllCall("Raydium.dll\raydium_light_update_intensity","UInt",Index,"CDecl")
            }
            Else If (Key = "Color")
            {
                If !IsObject(Value)
                    throw Exception("Invalid color: " . Position . ".",-1)
                Index := this.Index - 1, Offset := Index << 4
                NumPut(Value[1],Raydium.Lights.pColors + Offset,0,"Float")
                NumPut(Value[2],Raydium.Lights.pColors + Offset,4,"Float")
                NumPut(Value[3],Raydium.Lights.pColors + Offset,8,"Float")
                NumPut(ObjHasKey(Value,4) ? Value[4] : 1.0,Raydium.Lights.pColors + Offset,12,"Float")
                DllCall("Raydium.dll\raydium_light_update_all","UInt",Index,"CDecl")
            }
            ObjInsert(this[""],Key,Value)
            Return, this
        }
    }
}