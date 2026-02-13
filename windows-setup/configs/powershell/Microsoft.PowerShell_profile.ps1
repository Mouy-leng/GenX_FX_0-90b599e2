# PowerShell Profile for GenZ Trading Platform
# Place this file in: ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

# Set execution policy for current user (if not already set)
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Import useful modules
Import-Module posh-git -ErrorAction SilentlyContinue

# Set console encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Aliases
Set-Alias -Name g -Value git
Set-Alias -Name d -Value docker
Set-Alias -Name k -Value kubectl -ErrorAction SilentlyContinue
Set-Alias -Name py -Value python -ErrorAction SilentlyContinue
Set-Alias -Name ll -Value Get-ChildItem

# Custom functions
function Get-GitStatus { 
    git status 
}
Set-Alias -Name gs -Value Get-GitStatus

function Set-LocationProject { 
    Set-Location "D:\Dropbox (Personal)" 
}
Set-Alias -Name proj -Value Set-LocationProject

function Get-PublicIP {
    (Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content
}

function Test-Port {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ComputerName,
        [Parameter(Mandatory=$true)]
        [int]$Port
    )
    Test-NetConnection -ComputerName $ComputerName -Port $Port
}

function Get-ProcessByPort {
    param(
        [Parameter(Mandatory=$true)]
        [int]$Port
    )
    Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue | 
        Select-Object LocalPort, RemoteAddress, State, 
        @{Name="ProcessName";Expression={(Get-Process -Id $_.OwningProcess).ProcessName}}
}

# Environment variables
$env:EDITOR = "code"
$env:GIT_EDITOR = "code --wait"

# Trading-specific functions
function Start-TradingServices {
    Write-Host "🚀 Starting trading services..." -ForegroundColor Cyan
    
    # Start Docker services
    if (Test-Path "D:\Dropbox (Personal)\docker-compose.yml") {
        Push-Location "D:\Dropbox (Personal)"
        docker-compose up -d
        Pop-Location
    }
    
    # Start MetaTrader if installed
    $mt5Path = "C:\Program Files\MetaTrader 5\terminal64.exe"
    if (Test-Path $mt5Path) {
        Start-Process -FilePath $mt5Path
    }
    
    Write-Host "✅ Trading services started." -ForegroundColor Green
}

function Stop-TradingServices {
    Write-Host "🛑 Stopping trading services..." -ForegroundColor Cyan
    
    # Stop MetaTrader
    Stop-Process -Name "terminal64" -ErrorAction SilentlyContinue
    Stop-Process -Name "terminal" -ErrorAction SilentlyContinue
    
    # Stop Docker services
    if (Test-Path "D:\Dropbox (Personal)\docker-compose.yml") {
        Push-Location "D:\Dropbox (Personal)"
        docker-compose down
        Pop-Location
    }
    
    Write-Host "✅ Trading services stopped." -ForegroundColor Green
}

function Get-TradingStatus {
    Write-Host "`n📊 Trading Services Status" -ForegroundColor Cyan
    Write-Host "=========================" -ForegroundColor Cyan
    
    # Check Docker
    Write-Host "`n🐳 Docker Services:" -ForegroundColor Yellow
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>$null
    
    # Check MetaTrader
    Write-Host "`n📈 MetaTrader:" -ForegroundColor Yellow
    $mt4 = Get-Process -Name "terminal" -ErrorAction SilentlyContinue
    $mt5 = Get-Process -Name "terminal64" -ErrorAction SilentlyContinue
    
    if ($mt4) { Write-Host "  ✅ MT4 Running" -ForegroundColor Green }
    else { Write-Host "  ❌ MT4 Not Running" -ForegroundColor Red }
    
    if ($mt5) { Write-Host "  ✅ MT5 Running" -ForegroundColor Green }
    else { Write-Host "  ❌ MT5 Not Running" -ForegroundColor Red }
    
    # Check ports
    Write-Host "`n🔌 Port Status:" -ForegroundColor Yellow
    $ports = @(8000, 5555, 5432, 6379)
    foreach ($port in $ports) {
        $connection = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
        if ($connection) {
            $process = (Get-Process -Id $connection.OwningProcess -ErrorAction SilentlyContinue).ProcessName
            Write-Host "  ✅ Port $port ($process)" -ForegroundColor Green
        } else {
            Write-Host "  ❌ Port $port (not in use)" -ForegroundColor Red
        }
    }
    
    Write-Host ""
}
Set-Alias -Name tstat -Value Get-TradingStatus

function Update-TradingPlatform {
    Write-Host "🔄 Updating GenZ Trading Platform..." -ForegroundColor Cyan
    
    Push-Location "D:\Dropbox (Personal)"
    
    # Pull latest changes
    git pull origin main
    
    # Update dependencies
    if (Test-Path "package.json") {
        npm install
    }
    
    if (Test-Path "requirements.txt") {
        pip install -r requirements.txt
    }
    
    # Rebuild Docker containers
    if (Test-Path "docker-compose.yml") {
        docker-compose build
    }
    
    Pop-Location
    
    Write-Host "✅ Update complete!" -ForegroundColor Green
}

function Backup-TradingData {
    Write-Host "💾 Backing up trading data..." -ForegroundColor Cyan
    
    $backupPath = "D:\Backups\Trading_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss')"
    New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
    
    # Backup important directories
    $sourceDirs = @(
        "D:\Dropbox (Personal)\.env",
        "D:\Dropbox (Personal)\logs",
        "D:\Dropbox (Personal)\signal_output",
        "D:\Dropbox (Personal)\data"
    )
    
    foreach ($dir in $sourceDirs) {
        if (Test-Path $dir) {
            Copy-Item -Path $dir -Destination $backupPath -Recurse -Force
        }
    }
    
    Write-Host "✅ Backup complete: $backupPath" -ForegroundColor Green
}

# Custom prompt
function prompt {
    $path = $PWD.Path.Replace($HOME, "~")
    
    # Git branch info
    $gitBranch = git rev-parse --abbrev-ref HEAD 2>$null
    
    # Color scheme
    $pathColor = "Green"
    $branchColor = "Yellow"
    $promptColor = "Cyan"
    
    # Build prompt
    Write-Host "$path " -NoNewline -ForegroundColor $pathColor
    
    if ($gitBranch) {
        Write-Host "[$gitBranch]" -NoNewline -ForegroundColor $branchColor
    }
    
    Write-Host " $" -NoNewline -ForegroundColor $promptColor
    
    return " "
}

# Welcome message
Clear-Host
Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  🚀 GenZ Trading Platform Terminal   ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "📁 Working Directory: " -NoNewline -ForegroundColor White
Write-Host (Get-Location) -ForegroundColor Yellow
Write-Host "💻 PowerShell Version: " -NoNewline -ForegroundColor White
Write-Host $PSVersionTable.PSVersion -ForegroundColor Yellow
Write-Host ""
Write-Host "📚 Quick Commands:" -ForegroundColor Cyan
Write-Host "  • Start-TradingServices  - Start all services" -ForegroundColor White
Write-Host "  • Stop-TradingServices   - Stop all services" -ForegroundColor White
Write-Host "  • Get-TradingStatus      - Check service status" -ForegroundColor White
Write-Host "  • Update-TradingPlatform - Update platform" -ForegroundColor White
Write-Host "  • Backup-TradingData     - Backup trading data" -ForegroundColor White
Write-Host ""
