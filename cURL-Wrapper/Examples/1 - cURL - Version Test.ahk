#include ../cURL.ahk

if res := curl_global_init(){
	msgbox % "Global initialization error: " res
	exitapp
}

msgbox % curl_version()
curl_global_cleanup()
    exitapp