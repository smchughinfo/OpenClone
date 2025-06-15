@echo off
echo Stopping tmux sessions...
wsl tmux kill-session -t openclone
docker exec openclone-cicd bash -c "tmux kill-session -t cicd-shared 2>/dev/null || echo 'CICD session not running'"

echo Stopping screenshot watcher...
taskkill /F /FI "WINDOWTITLE eq Screenshot Watcher*" 2>nul
if %errorlevel%==0 (
    echo Screenshot watcher stopped.
) else (
    echo No screenshot watcher found running.
)

echo All services stopped.
rem don't kill claude though, could accidentally delete chat history you dont want to lose