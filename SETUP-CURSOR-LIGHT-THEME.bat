@echo off
echo ========================================
echo   Cursor Light Theme Setup
echo   Professional Light Configuration
echo ========================================
echo.

cd /d "%~dp0"
powershell.exe -ExecutionPolicy Bypass -File "setup-cursor-light-theme.ps1"

echo.
echo ========================================
echo   Setup Complete!
echo   Please restart Cursor IDE to apply theme
echo ========================================
echo.
pause






