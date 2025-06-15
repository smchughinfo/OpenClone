@echo off

rem ####################################################################
rem ##### RUN EXISITING CONTAINER IF IT EXISTS #########################
rem ####################################################################

docker container inspect openclone-u-2-net >nul 2>&1
if %ERRORLEVEL% == 0 (
    wt -p "OpenCloneU2Net" cmd /K "docker start -a openclone-u-2-net"
    goto :EOF
)

rem ####################################################################
rem ###### RUN CONTAINER FOR THE FIRST TIME ############################
rem ####################################################################

rem Initialize the command string
set cmd=docker run

rem ####################################################################
rem ###### NETWORK #####################################################
rem ####################################################################

set cmd=%cmd% -p 5002:5002

rem ####################################################################
rem ###### FILE SYSTEM #################################################
rem ####################################################################

set cmd=%cmd% -v "%OpenClone_OpenCloneFS%":/OpenCloneFS
set cmd=%cmd% -e OpenClone_OpenCloneFS=/OpenCloneFS

rem ####################################################################
rem ###### LOG DATABASE ################################################
rem ####################################################################

set cmd=%cmd% -e OpenClone_DB_Host=%OpenClone_DB_Host%
set cmd=%cmd% -e OpenClone_DB_Port=%OpenClone_DB_Port%
set cmd=%cmd% -e OpenClone_LogDB_Name=%OpenClone_LogDB_Name%
set cmd=%cmd% -e OpenClone_LogDB_User=%OpenClone_LogDB_User%
set cmd=%cmd% -e OpenClone_LogDB_Password=%OpenClone_LogDB_Password%

rem ####################################################################
rem ###### GPU SETTINGS ################################################
rem ####################################################################

set cmd=%cmd% --gpus all

rem ####################################################################
rem ###### CONTAINER NAME ##############################################
rem ####################################################################

set cmd=%cmd% --name openclone-u-2-net openclone-u-2-net:1.0

rem Finally execute the command
wt -p "OpenCloneU2Net" cmd /k "%cmd%"
