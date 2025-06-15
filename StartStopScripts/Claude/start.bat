@echo off
echo Starting Claude Code...
start "" wsl claude
timeout /t 2 /nobreak >nul

echo Starting screenshot watcher...
start "Screenshot Watcher" powershell -ExecutionPolicy Bypass -File "%~dp0screenshot-watcher.ps1"
timeout /t 1 /nobreak >nul
echo Screenshot watcher started in separate window

echo Creating shared tmux session...
wsl tmux new-session -d -s openclone 2>nul || echo Host session already exists
wsl tmux pipe-pane -t openclone -o 'cat >> /tmp/tmux-session.log' 2>nul || echo Host logging already enabled

echo Attaching to host shared terminal...
echo (Use VS Code button for CICD container terminal)
wsl tmux attach-session -t openclone