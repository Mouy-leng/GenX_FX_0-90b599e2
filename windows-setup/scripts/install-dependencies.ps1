# PowerShell Script to Install Dependencies for GenZ Trading Platform
# Run with: powershell -ExecutionPolicy Bypass -File install-dependencies.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installing Dependencies" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script requires administrator privileges." -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    pause
    exit 1
}

# Function to check if command exists
function Test-CommandExists {
    param($command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'stop'
    try { if (Get-Command $command) { return $true } }
    catch { return $false }
    finally { $ErrorActionPreference = $oldPreference }
}

# Install Chocolatey if not present
Write-Host "[1/8] Checking Chocolatey..." -ForegroundColor Yellow
if (-not (Test-CommandExists choco)) {
    Write-Host "Installing Chocolatey..." -ForegroundColor Cyan
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    refreshenv
} else {
    Write-Host "Chocolatey already installed." -ForegroundColor Green
}

# Install Git
Write-Host "`n[2/8] Installing Git..." -ForegroundColor Yellow
if (-not (Test-CommandExists git)) {
    choco install git -y
} else {
    Write-Host "Git already installed." -ForegroundColor Green
}

# Install Node.js
Write-Host "`n[3/8] Installing Node.js..." -ForegroundColor Yellow
if (-not (Test-CommandExists node)) {
    choco install nodejs-lts -y
} else {
    Write-Host "Node.js already installed." -ForegroundColor Green
}

# Install Python
Write-Host "`n[4/8] Installing Python..." -ForegroundColor Yellow
if (-not (Test-CommandExists python)) {
    choco install python311 -y
} else {
    Write-Host "Python already installed." -ForegroundColor Green
}

# Install Docker Desktop
Write-Host "`n[5/8] Installing Docker Desktop..." -ForegroundColor Yellow
if (-not (Test-Path "C:\Program Files\Docker\Docker\Docker Desktop.exe")) {
    choco install docker-desktop -y
} else {
    Write-Host "Docker Desktop already installed." -ForegroundColor Green
}

# Install VS Code
Write-Host "`n[6/8] Installing Visual Studio Code..." -ForegroundColor Yellow
if (-not (Test-CommandExists code)) {
    choco install vscode -y
} else {
    Write-Host "VS Code already installed." -ForegroundColor Green
}

# Install Windows Terminal
Write-Host "`n[7/8] Installing Windows Terminal..." -ForegroundColor Yellow
if (-not (Test-Path "$env:LOCALAPPDATA\Microsoft\WindowsApps\wt.exe")) {
    choco install microsoft-windows-terminal -y
} else {
    Write-Host "Windows Terminal already installed." -ForegroundColor Green
}

# Install PowerShell 7
Write-Host "`n[8/8] Installing PowerShell 7..." -ForegroundColor Yellow
if (-not (Test-Path "C:\Program Files\PowerShell\7")) {
    choco install powershell-core -y
} else {
    Write-Host "PowerShell 7 already installed." -ForegroundColor Green
}

# Install Python packages
Write-Host "`n[Extra] Installing Python packages..." -ForegroundColor Yellow
if (Test-CommandExists python) {
    python -m pip install --upgrade pip
    if (Test-Path "requirements.txt") {
        pip install -r requirements.txt
    }
}

# Install Node.js global packages
Write-Host "`n[Extra] Installing Node.js global packages..." -ForegroundColor Yellow
if (Test-CommandExists npm) {
    npm install -g yarn pnpm pm2
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT: Please restart your computer for all changes to take effect." -ForegroundColor Yellow
Write-Host ""
Write-Host "Installed tools:" -ForegroundColor Cyan
Write-Host "  - Git" -ForegroundColor White
Write-Host "  - Node.js & npm" -ForegroundColor White
Write-Host "  - Python 3.11" -ForegroundColor White
Write-Host "  - Docker Desktop" -ForegroundColor White
Write-Host "  - Visual Studio Code" -ForegroundColor White
Write-Host "  - Windows Terminal" -ForegroundColor White
Write-Host "  - PowerShell 7" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Restart your computer" -ForegroundColor White
Write-Host "  2. Configure Git credentials" -ForegroundColor White
Write-Host "  3. Set up Docker Desktop" -ForegroundColor White
Write-Host "  4. Run setup-dev-environment.bat" -ForegroundColor White
Write-Host ""

pause
