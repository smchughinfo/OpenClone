@echo off
cd /d "%~dp0\.."
call .venv\scripts\activate.bat
python Main.py backup
pause
