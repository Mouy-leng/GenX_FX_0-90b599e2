@echo off
echo ========================================
echo   Workspace Maintenance
echo   Restore and Verify
echo ========================================
echo.

cd /d "%~dp0"
powershell.exe -ExecutionPolicy Bypass -File "workspace-maintenance.ps1"

pause






