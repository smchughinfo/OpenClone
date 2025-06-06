@echo off
rem START docker
"C:\Program Files\Docker\Docker\frontend\Docker Desktop.exe"

@echo off
:loop
docker ps > temp.txt
findstr "CONTAINER" temp.txt > nul
if %errorlevel%==1 (
    echo CONTAINER not found, retrying...
    timeout /t .5
    goto loop
) else (
    echo CONTAINER found.
)
del temp.txt

timeout /t 3
