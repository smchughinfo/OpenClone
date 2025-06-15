@echo off

rem ####################################################################
rem ##### RUN EXISITING CONTAINER IF IT EXISTS #########################
rem ####################################################################

docker container inspect openclone-website >nul 2>&1
if %ERRORLEVEL% == 0 (
    wt -p "OpenCloneWebsite" cmd /K "docker start -a openclone-website"
    goto :EOF
)

rem ####################################################################
rem ###### RUN CONTAINER FOR THE FIRST TIME ############################
rem ####################################################################

rem Initialize the command string
set cmd=docker run

rem Run container in detached mode (background); use this in production to free up the terminal. Omit for interactive mode or use `-it` for an interactive session.
rem set cmd=%cmd% -d

rem ####################################################################
rem ###### NETWORK #####################################################
rem ####################################################################

set cmd=%cmd% -p 8080:80

rem ####################################################################
rem ###### FILE SYSTEM #################################################
rem ####################################################################

set cmd=%cmd% -v "%OpenClone_OpenCloneFS%":/OpenCloneFS
set cmd=%cmd% -e OpenClone_OpenCloneFS=/OpenCloneFS

rem ####################################################################
rem ###### SIGNALR #####################################################
rem ####################################################################

set cmd=%cmd% -e OpenClone_JWT_Issuer=%OpenClone_JWT_Issuer%
set cmd=%cmd% -e OpenClone_JWT_Audience=%OpenClone_JWT_Audience%
set cmd=%cmd% -e OpenClone_JWT_SecretKey=%OpenClone_JWT_SecretKey%

rem ####################################################################
rem ###### SUPPORT APPS ################################################
rem ####################################################################

set cmd=%cmd% -e OpenClone_SadTalker_HostAddresss=%OpenClone_SadTalker_HostAddress%
set cmd=%cmd% -e OpenClone_U2Net_HostAddress=%OpenClone_U2Net_HostAddress%

rem ####################################################################
rem ###### LOG LEVELS ##################################################
rem ####################################################################

set cmd=%cmd% -e OpenClone_OpenCloneLogLevel=%OpenClone_OpenCloneLogLevel%
set cmd=%cmd% -e OpenClone_SystemLogLevel=%OpenClone_SystemLogLevel%

rem ####################################################################
rem ###### API KEYS ####################################################
rem ####################################################################

set cmd=%cmd% -e OpenClone_OPENAI_API_KEY=%OpenClone_OPENAI_API_KEY%
set cmd=%cmd% -e OpenClone_GoogleClientId=%OpenClone_GoogleClientId%
set cmd=%cmd% -e OpenClone_GoogleClientSecret=%OpenClone_GoogleClientSecret%
set cmd=%cmd% -e OpenClone_ElevenLabsAPIKey=%OpenClone_ElevenLabsAPIKey%

rem ####################################################################
rem ###### CONNECTION STRINGS ##########################################
rem ####################################################################

set cmd=%cmd% -e OpenClone_DefaultConnection="%OpenClone_DefaultConnection%"
set cmd=%cmd% -e OpenClone_LogDbConnection="%OpenClone_LogDbConnection%"

rem ####################################################################
rem ###### CONTAINER NAME ##############################################
rem ####################################################################

set cmd=%cmd% --name openclone-website openclone-website:1.0

rem Finally execute the command
wt -p "OpenCloneWebsite" cmd /k "%cmd%"
