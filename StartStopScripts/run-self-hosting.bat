rem START THE DOCKER ENGINE
call Docker\start.bat

rem START DATABASE
call Database\stop.bat
call Database\start.bat

rem START LOGVIEWER
call LogViewer\stop.bat
call LogViewer\start-local.bat

rem START SADTALKER
call SadTalker\stop.bat
call SadTalker\start.bat

rem START WEBSITE
call Website\start.bat

rem START CLAUDE CODE INTEGRATION
call Claude\start.bat

