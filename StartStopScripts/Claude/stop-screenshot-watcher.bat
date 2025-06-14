@echo off
echo Stopping screenshot watcher...
taskkill /F /FI "WINDOWTITLE eq Screenshot Watcher*" 2>nul
if %errorlevel%==0 (
    echo Screenshot watcher stopped.
) else (
    echo No screenshot watcher found running.
)
pause