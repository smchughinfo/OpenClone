@echo off
echo Starting clipboard screenshot watcher in background...
start "Screenshot Watcher" powershell -ExecutionPolicy Bypass -File "%~dp0screenshot-watcher.ps1"
echo Screenshot watcher started! It will run in a separate window.
echo Use stop-screenshot-watcher.bat to stop it.
pause