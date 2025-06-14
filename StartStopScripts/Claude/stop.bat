@echo off
wsl tmux kill-session -t openclone
rem don't kill claude though, could accidentally delete chat history you dont want to lose