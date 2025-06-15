@echo off

rem ####################################################################
rem ##### RUN EXISITING CONTAINER IF IT EXISTS #########################
rem ####################################################################

docker container inspect openclone-database >nul 2>&1
if %ERRORLEVEL% == 0 (
    wt --window 0 new-tab -p "OpenCloneDatabase" cmd /K "docker start -a openclone-database"
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

set cmd=%cmd% -p 5433:5432

rem ####################################################################
rem ###### SUPERUSER ###################################################
rem ####################################################################

set cmd=%cmd% -e POSTGRES_PASSWORD=%OpenClone_postgres_superuser_password%

rem ####################################################################
rem ###### OPEN CLONE DB ###############################################
rem ####################################################################

set cmd=%cmd% -e OpenClone_OpenCloneDB_User=%OpenClone_OpenCloneDB_User%
set cmd=%cmd% -e OpenClone_OpenCloneDB_Password=%OpenClone_OpenCloneDB_Password%
set cmd=%cmd% -e OpenClone_OpenCloneDB_Name=%OpenClone_OpenCloneDB_Name%

rem ####################################################################
rem ###### LOG DB ######################################################
rem ####################################################################

set cmd=%cmd% -e OpenClone_LogDB_User=%OpenClone_LogDB_User%
set cmd=%cmd% -e OpenClone_LogDB_Password=%OpenClone_LogDB_Password%
set cmd=%cmd% -e OpenClone_LogDB_Name=%OpenClone_LogDB_Name%

rem ####################################################################
rem ###### CONTAINER NAME ##############################################
rem ####################################################################

set cmd=%cmd% --name openclone-database openclone-database:1.0

rem Finally execute the command
wt --window 0 new-tab -p "OpenCloneDatabase" cmd /k "%cmd%"
