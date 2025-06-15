@echo off
echo Starting Claude Code...
wt --window 0 new-tab -p "OpenCloneClaudeCode" wsl claude
timeout /t 2 /nobreak >nul

echo Starting screenshot watcher...
wt --window 0 new-tab -p "Screenshot Copy" powershell -ExecutionPolicy Bypass -File "%~dp0screenshot-watcher.ps1"
timeout /t 1 /nobreak >nul
echo Screenshot watcher started in separate window

echo Creating shared tmux session...
wsl tmux new-session -d -s openclone 2>nul || echo Host session already exists
wsl tmux pipe-pane -t openclone -o 'cat >> /tmp/tmux-session.log' 2>nul || echo Host logging already enabled

echo Attaching to host shared terminal...
echo (Use VS Code button for CICD container terminal)
wt --window 0 new-tab -p "OpenCloneTMUX" wsl tmux attach-session -t openclone