@echo off
REM Master Windows Setup Script for GenZ Trading Platform
REM This script orchestrates the complete Windows setup process

echo.
echo ╔═══════════════════════════════════════════════════════╗
echo ║   GenZ Trading Platform - Windows Setup Master       ║
echo ║   Complete Environment Configuration                  ║
echo ╚═══════════════════════════════════════════════════════╝
echo.

REM Check for administrator rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ⚠️  ERROR: This script requires administrator privileges.
    echo    Please right-click and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo ✅ Running with administrator privileges
echo.

REM Menu
:menu
cls
echo.
echo ╔═══════════════════════════════════════════════════════╗
echo ║   GenZ Trading Platform - Windows Setup Master       ║
echo ╚═══════════════════════════════════════════════════════╝
echo.
echo Please select setup option:
echo.
echo [1] Complete Setup (Recommended)
echo     - Install all dependencies
echo     - Configure security
echo     - Set up development environment
echo     - Apply trading profile
echo.
echo [2] Quick Setup (Essential only)
echo     - Install core dependencies
echo     - Basic security configuration
echo.
echo [3] Developer Setup
echo     - Development tools only
echo     - Git, Node.js, Python, Docker
echo.
echo [4] Trader Setup
echo     - Trading platform configuration
echo     - MetaTrader setup
echo     - Security hardening
echo.
echo [5] Security Configuration Only
echo.
echo [6] Backup Current Settings
echo.
echo [7] Restore from Backup
echo.
echo [8] View Setup Status
echo.
echo [0] Exit
echo.
set /p choice="Enter your choice (0-8): "

if "%choice%"=="1" goto complete_setup
if "%choice%"=="2" goto quick_setup
if "%choice%"=="3" goto developer_setup
if "%choice%"=="4" goto trader_setup
if "%choice%"=="5" goto security_only
if "%choice%"=="6" goto backup_only
if "%choice%"=="7" goto restore_only
if "%choice%"=="8" goto view_status
if "%choice%"=="0" goto exit
goto menu

:complete_setup
echo.
echo 🚀 Starting Complete Setup...
echo ═════════════════════════════════════
echo.

echo [Step 1/6] Installing dependencies...
call "%~dp0install-dependencies.ps1"
if %errorLevel% neq 0 goto error

echo.
echo [Step 2/6] Setting up development environment...
call "%~dp0setup-dev-environment.bat"
if %errorLevel% neq 0 goto error

echo.
echo [Step 3/6] Configuring security...
call "%~dp0configure-security.bat"
if %errorLevel% neq 0 goto error

echo.
echo [Step 4/6] Applying trading profile...
powershell -ExecutionPolicy Bypass -File "%~dp0..\apply-profile.ps1" -ProfileName "trader"
if %errorLevel% neq 0 goto error

echo.
echo [Step 5/6] Creating initial backup...
powershell -ExecutionPolicy Bypass -File "%~dp0backup-settings.ps1"
if %errorLevel% neq 0 goto error

echo.
echo [Step 6/6] Verifying setup...
call :verify_setup

echo.
echo ✅ Complete setup finished successfully!
echo.
goto post_setup

:quick_setup
echo.
echo ⚡ Starting Quick Setup...
echo ═════════════════════════════════════
echo.

echo [Step 1/3] Installing essential tools...
powershell -Command "winget install Git.Git -e --silent --accept-source-agreements --accept-package-agreements"
powershell -Command "winget install OpenJS.NodeJS.LTS -e --silent --accept-source-agreements --accept-package-agreements"

echo.
echo [Step 2/3] Basic security configuration...
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $false"
powershell -Command "Set-MpPreference -MAPSReporting Advanced"

echo.
echo [Step 3/3] Verifying installation...
call :verify_setup

echo.
echo ✅ Quick setup finished!
echo.
goto post_setup

:developer_setup
echo.
echo 👨‍💻 Starting Developer Setup...
echo ═════════════════════════════════════
echo.

echo [Step 1/3] Installing development tools...
call "%~dp0install-dependencies.ps1"

echo.
echo [Step 2/3] Setting up development environment...
call "%~dp0setup-dev-environment.bat"

echo.
echo [Step 3/3] Applying developer profile...
powershell -ExecutionPolicy Bypass -File "%~dp0..\apply-profile.ps1" -ProfileName "developer"

echo.
echo ✅ Developer setup finished!
echo.
goto post_setup

:trader_setup
echo.
echo 📈 Starting Trader Setup...
echo ═════════════════════════════════════
echo.

echo [Step 1/3] Configuring security...
call "%~dp0configure-security.bat"

echo.
echo [Step 2/3] Setting up trading environment...
REM Create trading directories
mkdir "D:\Dropbox (Personal)\logs" 2>nul
mkdir "D:\Dropbox (Personal)\signal_output" 2>nul
mkdir "D:\Dropbox (Personal)\data" 2>nul
mkdir "D:\Backups\Trading" 2>nul

echo.
echo [Step 3/3] Applying trader profile...
powershell -ExecutionPolicy Bypass -File "%~dp0..\apply-profile.ps1" -ProfileName "trader"

echo.
echo ✅ Trader setup finished!
echo.
goto post_setup

:security_only
echo.
echo 🔒 Configuring Security...
echo ═════════════════════════════════════
echo.
call "%~dp0configure-security.bat"
echo.
echo ✅ Security configuration complete!
pause
goto menu

:backup_only
echo.
echo 💾 Backing up settings...
echo ═════════════════════════════════════
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0backup-settings.ps1"
echo.
echo ✅ Backup complete!
pause
goto menu

:restore_only
echo.
echo 📥 Restore from backup...
echo ═════════════════════════════════════
echo.
set /p backupPath="Enter backup directory path: "
if not exist "%backupPath%" (
    echo ❌ Backup directory not found!
    pause
    goto menu
)
powershell -ExecutionPolicy Bypass -File "%~dp0restore-settings.ps1" -BackupPath "%backupPath%"
echo.
echo ✅ Restore complete!
pause
goto menu

:view_status
cls
echo.
echo 📊 System Setup Status
echo ═════════════════════════════════════
echo.

REM Check installed tools
echo Checking installed tools...
echo.

git --version >nul 2>&1
if %errorLevel%==0 (
    echo ✅ Git installed
    git --version
) else (
    echo ❌ Git not found
)

node --version >nul 2>&1
if %errorLevel%==0 (
    echo ✅ Node.js installed
    node --version
) else (
    echo ❌ Node.js not found
)

python --version >nul 2>&1
if %errorLevel%==0 (
    echo ✅ Python installed
    python --version
) else (
    echo ❌ Python not found
)

docker --version >nul 2>&1
if %errorLevel%==0 (
    echo ✅ Docker installed
    docker --version
) else (
    echo ❌ Docker not found
)

code --version >nul 2>&1
if %errorLevel%==0 (
    echo ✅ VS Code installed
) else (
    echo ❌ VS Code not found
)

echo.
echo Checking directories...
echo.

if exist "D:\Dropbox (Personal)" (
    echo ✅ Project directory exists
) else (
    echo ❌ Project directory not found
)

if exist "D:\Backups" (
    echo ✅ Backup directory exists
) else (
    echo ❌ Backup directory not found
)

echo.
pause
goto menu

:verify_setup
echo Verifying setup...
git --version >nul 2>&1 && echo ✅ Git: OK || echo ❌ Git: Not found
node --version >nul 2>&1 && echo ✅ Node.js: OK || echo ❌ Node.js: Not found
python --version >nul 2>&1 && echo ✅ Python: OK || echo ❌ Python: Not found
exit /b 0

:post_setup
echo ═════════════════════════════════════
echo.
echo 📋 Next Steps:
echo.
echo 1. Restart your computer to apply all changes
echo 2. Configure Git credentials:
echo    git config --global user.name "Your Name"
echo    git config --global user.email "your.email@example.com"
echo.
echo 3. Review setup documentation:
echo    - windows-setup/README.md
echo    - windows-setup/docs/security-guide.md
echo    - windows-setup/docs/profile-setup.md
echo.
echo 4. Set up SSH keys for GitHub (if needed)
echo 5. Configure .env file for trading platform
echo.
echo 📚 Resources:
echo    - OneNote: https://onedrive.live.com/view.aspx?resid=C2A387A2E5F8E82F
echo    - NotebookLM: https://notebooklm.google.com/notebook/e8f4c29d-9aec-4d5f-8f51-2ca168687616
echo.
pause
goto menu

:error
echo.
echo ❌ An error occurred during setup!
echo    Check the error messages above for details.
echo.
pause
goto menu

:exit
echo.
echo Thank you for using GenZ Trading Platform Setup!
echo.
exit /b 0
