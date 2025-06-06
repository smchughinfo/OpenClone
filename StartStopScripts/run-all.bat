rem START THE DOCKER ENGINE
call ..\BatchScripts\Docker\start.bat
rem call ..\BatchScripts\Docker\close-docker-desktop.bat

rem START DATABASE
call ..\BatchScripts\Database\stop.bat
call ..\BatchScripts\Database\start.bat

rem START LOGVIEWER
call ..\BatchScripts\LogViewer\stop.bat
call ..\BatchScripts\LogViewer\start.bat

rem START WEBPACK
call ..\BatchScripts\WebPack\stop.bat
call ..\BatchScripts\WebPack\start.bat

rem START SADTALKER
call ..\BatchScripts\SadTalker\stop.bat
call ..\BatchScripts\SadTalker\start.bat

rem START U-2-NET
call ..\BatchScripts\U-2-NET\stop.bat
call ..\BatchScripts\U-2-NET\start.bat

