@echo off
REM Development Environment Setup Script
REM Installs and configures development tools for GenZ Trading Platform

echo ========================================
echo Development Environment Setup
echo ========================================
echo.

echo [1/10] Checking winget availability...
winget --version >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: winget is not available. Please install App Installer from Microsoft Store.
    pause
    exit /b 1
)

echo [2/10] Installing Git...
winget install --id Git.Git -e --silent --accept-source-agreements --accept-package-agreements

echo [3/10] Installing Node.js LTS...
winget install --id OpenJS.NodeJS.LTS -e --silent --accept-source-agreements --accept-package-agreements

echo [4/10] Installing Python 3.11...
winget install --id Python.Python.3.11 -e --silent --accept-source-agreements --accept-package-agreements

echo [5/10] Installing Docker Desktop...
winget install --id Docker.DockerDesktop -e --silent --accept-source-agreements --accept-package-agreements

echo [6/10] Installing VS Code...
winget install --id Microsoft.VisualStudioCode -e --silent --accept-source-agreements --accept-package-agreements

echo [7/10] Installing Windows Terminal...
winget install --id Microsoft.WindowsTerminal -e --silent --accept-source-agreements --accept-package-agreements

echo [8/10] Installing PowerShell 7...
winget install --id Microsoft.PowerShell -e --silent --accept-source-agreements --accept-package-agreements

echo [9/10] Refreshing environment...
call RefreshEnv.cmd 2>nul

echo [10/10] Configuring Git...
timeout /t 3 /nobreak >nul
git config --global core.autocrlf true
git config --global init.defaultBranch main

echo.
echo ========================================
echo Development Environment Setup Complete!
echo ========================================
echo.
echo IMPORTANT: Please restart your terminal or computer for changes to take effect.
echo.
echo Next steps:
echo 1. Configure Git with your name and email:
echo    git config --global user.name "Your Name"
echo    git config --global user.email "your.email@example.com"
echo.
echo 2. Install Node.js packages:
echo    npm install -g yarn pnpm
echo.
echo 3. Install Python packages:
echo    pip install --upgrade pip
echo    pip install -r requirements.txt
echo.
echo 4. Configure SSH keys for GitHub
echo.
pause
