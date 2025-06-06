@echo off
cd /d "%~dp0\.."
call .venv\scripts\activate.bat

REM Check for arguments
IF "%1"=="" (
    python Main.py restore ^
        --openclone_db_super_connection_string "%OpenClone_DefaultConnection_Super%" ^
        --log_db_super_connection_string "%OpenClone_LogDbConnection_Super%" ^
        --openclone_db_user_name "%OpenClone_OpenCloneDB_User%" ^
        --openclone_db_user_password "%OpenClone_OpenCloneDB_Password%" ^
        --log_db_user_name "%OpenClone_LogDB_User%" ^
        --log_db_user_password "%OpenClone_LogDB_Password%"
) ELSE (
    REM Use %* to get all command-line arguments
    echo "using args ---> %*"
    python Main.py restore %*
)
