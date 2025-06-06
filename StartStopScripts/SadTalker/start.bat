@echo off

rem ####################################################################
rem ##### RUN EXISITING CONTAINER IF IT EXISTS #########################
rem ####################################################################

docker container inspect openclone-sadtalker >nul 2>&1
if %ERRORLEVEL% == 0 (
    start cmd -d /K "docker start -a openclone-sadtalker"
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

set cmd=%cmd% -p 5001:5001

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

set cmd=%cmd% -e OpenClone_CUDA_VISIBLE_DEVICES=%OpenClone_CUDA_VISIBLE_DEVICES%
set cmd=%cmd% --gpus all

rem ####################################################################
rem ###### CONTAINER NAME ##############################################
rem ####################################################################

set cmd=%cmd% --name openclone-sadtalker openclone-sadtalker:1.0

rem Finally execute the command
start cmd /k "%cmd%"

