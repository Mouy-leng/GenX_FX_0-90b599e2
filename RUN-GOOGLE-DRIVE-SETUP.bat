@echo off
echo ========================================
echo Google Drive Streaming Setup
echo ========================================
echo.
cd /d "%~dp0"
echo Running setup script...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0run-google-drive-setup-auto.ps1"
echo.
echo ========================================
echo Setup Complete
echo ========================================
echo.
echo Next: Open Google Drive settings and enable "Stream files" mode
echo.
pause

