@echo off
REM Sync Local Files and Push to GitHub
cd /d "%~dp0"
powershell.exe -ExecutionPolicy Bypass -File "%~dp0sync-and-push-github.ps1"
pause

