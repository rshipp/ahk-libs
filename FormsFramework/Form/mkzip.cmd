call mkdoc.bat
"c:\Program Files\7-Zip\7z.exe" a -r -xr0!images -x!_doc\_ndproj -x!*svn -x!*.cmd -x!*.7z Forms.7z
pause