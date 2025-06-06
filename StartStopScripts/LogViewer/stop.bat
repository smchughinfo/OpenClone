@echo off
powershell.exe -Command "Get-Process | Where-Object { $_.MainModule.FileName -like '*python*' } | Where-Object { $_.Path -like '*logviewer*' } | Stop-Process -Force"

