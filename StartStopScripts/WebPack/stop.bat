rem this will actually kill all node processes, which might be a problem. but i can't find anything to distinguish webpack specifically
@echo off
powershell.exe -Command "Get-Process | Where-Object { $_.MainModule.FileName -like '*node*' } | Stop-Process -Force"
