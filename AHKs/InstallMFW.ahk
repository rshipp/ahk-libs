#include FcnLib.ahk

Run, C:\Windows\system32\cmd.exe
Sleep, 1500
Send, cpan-outdated | cpanm{ENTER}
Send, cpan .{ENTER}
Send,

;Then when the title changes back from cpan . we're good to go
;TODO perhaps we should hide the window, then exit the window when the taks is finished
