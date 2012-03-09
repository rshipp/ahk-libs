class Environment
{
    __New()
    {
        ObjInsert(this,"",Object())
        this.Background := [1.0,1.0,1.0]
        this.Ambient := [0.5,0.5,0.5]
        this.Fog := new Raydium.Environment.Fog
    }

    __Get(Key)
    {
        If (Key != "")
            Return, this[""][Key]
    }

    __Set(Key,Value)
    {
        If (Key = "Background")
        {
            If !IsObject(Value)
                throw Exception("Invalid color: " . Position . ".",-1)
            DllCall("Raydium.dll\raydium_background_color_change","Float",Value[1],"Float",Value[2],"Float",Value[3],"Float",ObjHasKey(Value,4) ? Value[4] : 1.0,"CDecl")
        }
        Else If (Key = "Ambient")
        {
            If !IsObject(Value)
                throw Exception("Invalid color: " . Position . ".",-1)
            VarSetCapacity(GlobalAmbience,16)
            NumPut(Value[1],GlobalAmbience,0,"Float")
            NumPut(Value[2],GlobalAmbience,4,"Float")
            NumPut(Value[3],GlobalAmbience,8,"Float")
            NumPut(ObjHasKey(Value,4) ? Value[4] : 1.0,GlobalAmbience,12,"Float")
            DllCall("opengl32.dll\glLightModelfv","UInt",0xB53,"UPtr",&GlobalAmbience) ;GL_LIGHT_MODEL_AMBIENT
        }
        Else If (Key = "Gravity")
        {
            If !IsObject(Value)
                throw Exception("Invalid gravity: " . Position . ".",-1)
            DllCall("Raydium.dll\raydium_ode_gravity_3f","Float",Value[1],"Float",Value[2],"Float",Value[3],"CDecl")
        }
        ObjInsert(this[""],Key,Value)
        Return, this
    }

    class Fog
    {
        __New()
        {
            ObjInsert(this,"",Object())
            ;this.State := 0
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
                    DllCall("Raydium.dll\raydium_fog_enable","CDecl")
                Else
                    DllCall("Raydium.dll\raydium_fog_disable","CDecl")
                DllCall("Raydium.dll\raydium_fog_apply","CDecl")
            }
            Else If (Key = "Type")
            {
                If (Value = "Linear")
                    DllCall("Raydium.dll\raydium_fog_mode","UInt",0x2601,"CDecl") ;RAYDIUM_FOG_MODE_LINEAR
                Else If (Value = "Exponential")
                    DllCall("Raydium.dll\raydium_fog_mode","UInt",0x800,"CDecl") ;RAYDIUM_FOG_MODE_EXP
                Else If (Value = "DoubleExponential")
                    DllCall("Raydium.dll\raydium_fog_mode","UInt",0x801,"CDecl") ;RAYDIUM_FOG_MODE_EXP2
                Else
                    throw Exception("Invalid type: " . Value . ".",-1)
                DllCall("Raydium.dll\raydium_fog_apply","CDecl")
            }
            Else If (Key = "Density")
            {
                If Value Is Not Number
                    throw Exception("Invalid density: " . Value . ".",-1)
                DllCall("Raydium.dll\raydium_fog_density","Float",Value,"CDecl")
                DllCall("Raydium.dll\raydium_fog_apply","CDecl")
            }
            Else If (Key = "Near")
            {
                If Value Is Not Number
                    throw Exception("Invalid near limit: " . Value . ".",-1)
                DllCall("Raydium.dll\raydium_fog_near","Float",Value,"CDecl")
                DllCall("Raydium.dll\raydium_fog_apply","CDecl")
            }
            Else If (Key = "Far")
            {
                If Value Is Not Number
                    throw Exception("Invalid far limit: " . Value . ".",-1)
                DllCall("Raydium.dll\raydium_fog_far","Float",Value,"CDecl")
                DllCall("Raydium.dll\raydium_fog_apply","CDecl")
            }
            ObjInsert(this[""],Key,Value)
            Return, this
        }
    }
}