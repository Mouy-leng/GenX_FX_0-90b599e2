@echo off
REM Windows Security Configuration Script
REM Configures Windows security settings for GenZ Trading Platform

echo ========================================
echo Windows Security Configuration
echo ========================================
echo.

REM Check for administrator rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script requires administrator privileges.
    echo Please right-click and select "Run as administrator"
    pause
    exit /b 1
)

echo [1/7] Configuring Windows Defender...
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $false"
powershell -Command "Set-MpPreference -MAPSReporting Advanced"
powershell -Command "Set-MpPreference -SubmitSamplesConsent SendAllSamples"

echo [2/7] Adding MetaTrader exclusions...
powershell -Command "Add-MpPreference -ExclusionPath 'C:\Program Files\MetaTrader 4' -ErrorAction SilentlyContinue"
powershell -Command "Add-MpPreference -ExclusionPath 'C:\Program Files\MetaTrader 5' -ErrorAction SilentlyContinue"
powershell -Command "Add-MpPreference -ExclusionPath 'C:\Users\%USERNAME%\AppData\Roaming\MetaQuotes' -ErrorAction SilentlyContinue"
powershell -Command "Add-MpPreference -ExclusionPath 'D:\Dropbox (Personal)' -ErrorAction SilentlyContinue"

echo [3/7] Configuring firewall rules...
powershell -Command "New-NetFirewallRule -DisplayName 'MetaTrader 4' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 443 -ErrorAction SilentlyContinue"
powershell -Command "New-NetFirewallRule -DisplayName 'MetaTrader 5' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 443,8080 -ErrorAction SilentlyContinue"
powershell -Command "New-NetFirewallRule -DisplayName 'Trading Bridge API' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8000 -ErrorAction SilentlyContinue"
powershell -Command "New-NetFirewallRule -DisplayName 'Trading Bridge Port' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 5555 -ErrorAction SilentlyContinue"

echo [4/7] Configuring User Account Control...
powershell -Command "Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'ConsentPromptBehaviorAdmin' -Value 2 -ErrorAction SilentlyContinue"

echo [5/7] Disabling unnecessary services...
powershell -Command "Set-Service -Name 'RemoteRegistry' -StartupType Disabled -ErrorAction SilentlyContinue"
powershell -Command "Set-Service -Name 'WerSvc' -StartupType Disabled -ErrorAction SilentlyContinue"

echo [6/7] Configuring Controlled Folder Access...
powershell -Command "Set-MpPreference -EnableControlledFolderAccess Enabled -ErrorAction SilentlyContinue"
powershell -Command "Add-MpPreference -ControlledFolderAccessProtectedFolders 'D:\Dropbox (Personal)' -ErrorAction SilentlyContinue"

echo [7/7] Running security scan...
powershell -Command "Start-MpScan -ScanType QuickScan"

echo.
echo ========================================
echo Security Configuration Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Review Windows Security settings
echo 2. Configure backup schedule
echo 3. Test trading applications
echo.
pause
