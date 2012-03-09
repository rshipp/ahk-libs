#NoEnv

GameWindow := new Raydium("Test Game")
GameWindow.Camera.FieldOfView := 60
;GameWindow.Camera.Type := "Orthographic"

GameWindow.Lights[1].State := 1
GameWindow.Lights[1].Position := [4.0,4.0,4.0]
GameWindow.Lights[1].Intensity := 1000000 ;wip: not working
GameWindow.Lights[1].Color := [0.0,1.0,0.0]

GameWindow.Environment.Background := [0.7,0.8,1.0]

GameWindow.Environment.Fog.State := 1
GameWindow.Environment.Fog.Type := "DoubleExponential"
GameWindow.Environment.Fog.Density := 0.1

;CameraX := 10, CameraY := 10, CameraZ := 20

/*
;wip: skybox not working
;DllCall("Raydium.dll\raydium_fog_disable","CDecl")
NumPut(1,DllCall("GetProcAddress","UPtr",GameWindow.hModule,"AStr","raydium_sky_force"),0,"Char")
DllCall("Raydium.dll\raydium_sky_enable","AStr","desert","CDecl")
DllCall("Raydium.dll\raydium_sky_box_name","AStr","desert","CDecl")
DllCall("Raydium.dll\raydium_sky_box_cache","CDecl")
*/

GameWindow.Entities.Ground := new Raydium.Entity("test.tri")
If (Ground = -1)
    ExitApp ;error loading file

pCallBack := RegisterCallback("Display","Fast")
DllCall("Raydium.dll\raydium_callback","UPtr",pCallBack,"CDecl")
Return

class Raydium
{
    __New(Title = "",Width = 800,Height = 600,WindowType = "Resizable")
    {
        this.hModule := DllCall("LoadLibrary","Str","Raydium.dll")
        DllCall("Raydium.dll\raydium_init_args_hack","Int",1,"Str","","CDecl")

        If (WindowType = "Resizable") ;resizable window
            RenderMode := 0 ;RAYDIUM_RENDERING_WINDOW
        Else If (WindowType = "FullScreen") ;fullscreen
            RenderMode := 1 ;RAYDIUM_RENDERING_FULLSCREEN
        Else If (WindowType = "Fixed") ;fixed size window
            RenderMode := 10 ;RAYDIUM_RENDERING_WINDOW_FIXED
        Else ;invalid window type
            throw Exception("Invalid window type: " . WindowType . ".",-1)

        DllCall("Raydium.dll\raydium_window_create","UInt",Width,"UInt",Height,"Char",RenderMode,"AStr",Title,"CDecl")

        DllCall("Raydium.dll\raydium_texture_filter_change","UInt",2,"CDecl") ;RAYDIUM_TEXTURE_FILTER_TRILINEAR: highest quality texture filter

        this.Camera := new Raydium.Camera(this.hModule)
        this.Lights := new Raydium.Lights(this.hModule)
        this.Environment := new Raydium.Environment
    }

    static Entities := Object()

    class Entity
    {
        static Counter := 0

        __New(Path,Translation,Rotation)
        {
            this.Path := Path
            this.MeshID := DllCall("Raydium.dll\raydium_object_load","AStr",Name,"CDecl")
            If this.MeshID = -1 ;error loading entity
                throw Exception("Could not load entity: " . Path . ".",-1)
            this.Name := "Entity" . Raydium.Entity.Counter
            Raydium.Entity.Counter ++
            this.ObjectID := DllCall("Raydium.dll\raydium_ode_object_create","AStr",this.Name,"CDecl")
            If this.ObjectID = -1 ;error loading entity
                throw Exception("Could not load entity: " . Path . ".",-1)
        }
    }

    #Include Modules\Camera.ahk
    #Include Modules\Lights.ahk
    #Include Modules\Environment.ahk

    __Delete()
    {
        DllCall("FreeLibrary","UPtr",this.hModule)
    }
}

Display()
{
    global Ground, UFO
    global GameWindow, CameraX, CameraY, CameraZ ;wip: temporary

    ;DllCall("Raydium.dll\raydium_joy_key_emul","CDecl")
    ;CameraX += NumGet(DllCall("GetProcAddress","UPtr",GameWindow.hModule,"AStr","raydium_joy_x"),0,"Float")
    ;CameraY += NumGet(DllCall("GetProcAddress","UPtr",GameWindow.hModule,"AStr","raydium_joy_y"),0,"Float")
    ;DllCall("Raydium.dll\raydium_camera_look_at","Float",CameraX,"Float",CameraY,"Float",CameraZ,"Float",0.0,"Float",0.0,"Float",0.0,"CDecl")

    DllCall("Raydium.dll\raydium_camera_freemove","UInt",1,"CDecl")
    DllCall("Raydium.dll\raydium_sky_box_render","Float",0.0,"Float",0.0,"Float",0.0,"CDecl")

    DllCall("Raydium.dll\raydium_clear_frame","CDecl")
    DllCall("Raydium.dll\raydium_object_draw","UInt",Ground,"CDecl")
    DllCall("Raydium.dll\raydium_rendering_finish","CDecl")
}