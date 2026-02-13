# Windows Profile Setup Guide

Guide for setting up Windows user profiles for development, trading, and daily use.

## Overview

This guide covers the setup and configuration of Windows user profiles optimized for:
- Software development
- Trading platform usage
- Daily productivity
- System administration

## Profile Types

### 1. Developer Profile

Optimized for software development with:
- Development tools (Git, Node.js, Python, Docker)
- Code editors (VS Code, Cursor)
- Build tools and compilers
- Database clients
- API testing tools

### 2. Trader Profile

Optimized for trading with:
- MetaTrader 4/5
- Trading bridges and APIs
- Market data feeds
- Analysis tools
- Monitoring dashboards

### 3. Administrator Profile

For system administration:
- PowerShell with admin rights
- System monitoring tools
- Network utilities
- Security tools
- Backup utilities

## Initial Profile Setup

### 1. Create User Profile

```powershell
# Create new user account
$Password = Read-Host -AsSecureString
New-LocalUser -Name "TradingUser" -Password $Password -FullName "Trading User" -Description "User account for trading applications"

# Add to Users group
Add-LocalGroupMember -Group "Users" -Member "TradingUser"
```

### 2. Configure Profile Directory

```powershell
# Set profile directory structure
$ProfilePath = "C:\Users\TradingUser"
New-Item -ItemType Directory -Path "$ProfilePath\Documents\Trading"
New-Item -ItemType Directory -Path "$ProfilePath\Documents\Development"
New-Item -ItemType Directory -Path "$ProfilePath\Documents\Backups"
```

## Development Environment Setup

### Git Configuration

```bash
# Configure Git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global core.autocrlf true
git config --global init.defaultBranch main

# Configure SSH
ssh-keygen -t ed25519 -C "your.email@example.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### PowerShell Profile

Create PowerShell profile at `$PROFILE`:

```powershell
# PowerShell Profile (~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1)

# Set execution policy for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Import useful modules
Import-Module posh-git -ErrorAction SilentlyContinue

# Aliases
Set-Alias -Name g -Value git
Set-Alias -Name d -Value docker
Set-Alias -Name k -Value kubectl

# Functions
function Get-GitStatus { git status }
Set-Alias -Name gs -Value Get-GitStatus

function Set-LocationProject { Set-Location "D:\Dropbox (Personal)" }
Set-Alias -Name proj -Value Set-LocationProject

# Environment variables
$env:EDITOR = "code"

# Prompt customization
function prompt {
    $path = $PWD.Path.Replace($HOME, "~")
    $gitBranch = git rev-parse --abbrev-ref HEAD 2>$null
    if ($gitBranch) {
        Write-Host "$path " -NoNewline -ForegroundColor Green
        Write-Host "[$gitBranch]" -NoNewline -ForegroundColor Yellow
    } else {
        Write-Host "$path" -NoNewline -ForegroundColor Green
    }
    Write-Host " $" -NoNewline
    return " "
}

# Trading-specific functions
function Start-TradingServices {
    Write-Host "Starting trading services..." -ForegroundColor Cyan
    Start-Process -FilePath "C:\Program Files\MetaTrader 5\terminal64.exe"
    docker-compose -f "D:\Dropbox (Personal)\docker-compose.yml" up -d
    Write-Host "Trading services started." -ForegroundColor Green
}

function Stop-TradingServices {
    Write-Host "Stopping trading services..." -ForegroundColor Cyan
    Stop-Process -Name "terminal64" -ErrorAction SilentlyContinue
    docker-compose -f "D:\Dropbox (Personal)\docker-compose.yml" down
    Write-Host "Trading services stopped." -ForegroundColor Green
}

# Welcome message
Write-Host "Welcome to GenZ Trading Platform" -ForegroundColor Cyan
Write-Host "Profile loaded: $(Split-Path $PROFILE -Leaf)" -ForegroundColor Gray
```

### VS Code Configuration

VS Code settings at `%APPDATA%\Code\User\settings.json`:

```json
{
  "editor.fontSize": 14,
  "editor.fontFamily": "Cascadia Code, Consolas, 'Courier New', monospace",
  "editor.fontLigatures": true,
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.tabSize": 2,
  "editor.rulers": [80, 120],
  "editor.minimap.enabled": true,
  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 1000,
  "terminal.integrated.defaultProfile.windows": "PowerShell",
  "terminal.integrated.fontSize": 13,
  "git.enableSmartCommit": true,
  "git.confirmSync": false,
  "python.linting.enabled": true,
  "python.linting.pylintEnabled": true,
  "python.formatting.provider": "black",
  "[python]": {
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "ms-python.black-formatter"
  },
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  }
}
```

### Essential VS Code Extensions

```powershell
# Install VS Code extensions
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension ms-python.black-formatter
code --install-extension esbenp.prettier-vscode
code --install-extension dbaeumer.vscode-eslint
code --install-extension ms-vscode.vscode-typescript-next
code --install-extension eamodio.gitlens
code --install-extension github.copilot
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-vscode-remote.remote-wsl
```

## Trading Profile Setup

### MetaTrader Configuration

1. Install MetaTrader 4/5
2. Configure data directory
3. Set up Expert Advisors
4. Configure symbols and timeframes
5. Enable automated trading

```powershell
# MetaTrader data directory
$MT4DataPath = "C:\Users\$env:USERNAME\AppData\Roaming\MetaQuotes\Terminal"
$MT5DataPath = "C:\Program Files\MetaTrader 5\MQL5"

# Copy Expert Advisors
Copy-Item -Path ".\expert-advisors\mt4_ea\*" -Destination "$MT4DataPath\MQL4\Experts\" -Recurse
Copy-Item -Path ".\expert-advisors\mt5_ea\*" -Destination "$MT5DataPath\Experts\" -Recurse
```

### Trading Environment Variables

```powershell
# Set trading environment variables
[Environment]::SetEnvironmentVariable("BROKER_API_URL", "https://api.broker.com", "User")
[Environment]::SetEnvironmentVariable("TRADING_ACCOUNT", "12345678", "User")
[Environment]::SetEnvironmentVariable("TRADING_MODE", "LIVE", "User")
[Environment]::SetEnvironmentVariable("LOG_LEVEL", "INFO", "User")

# Set paths
[Environment]::SetEnvironmentVariable("MT4_PATH", "C:\Program Files\MetaTrader 4", "User")
[Environment]::SetEnvironmentVariable("MT5_PATH", "C:\Program Files\MetaTrader 5", "User")
[Environment]::SetEnvironmentVariable("TRADING_LOGS", "D:\Dropbox (Personal)\logs", "User")
```

### Scheduled Tasks

Create scheduled tasks for automated operations:

```powershell
# Create task for daily backup
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File `"D:\Dropbox (Personal)\scripts\windows\backup_to_usb.bat`""
$Trigger = New-ScheduledTaskTrigger -Daily -At 2am
$Principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest
Register-ScheduledTask -TaskName "DailyTradingBackup" -Action $Action -Trigger $Trigger -Principal $Principal

# Create task for system monitoring
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File `"D:\Dropbox (Personal)\scripts\monitoring\system-monitor.ps1`""
$Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 15)
Register-ScheduledTask -TaskName "SystemMonitoring" -Action $Action -Trigger $Trigger
```

## Windows Terminal Configuration

Windows Terminal settings at `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`:

```json
{
  "$schema": "https://aka.ms/terminal-profiles-schema",
  "defaultProfile": "{574e775e-4f2a-5b96-ac1e-a2962a402336}",
  "copyOnSelect": true,
  "copyFormatting": false,
  "profiles": {
    "defaults": {
      "fontFace": "Cascadia Code",
      "fontSize": 11,
      "cursorShape": "bar",
      "useAcrylic": true,
      "acrylicOpacity": 0.9
    },
    "list": [
      {
        "guid": "{574e775e-4f2a-5b96-ac1e-a2962a402336}",
        "name": "PowerShell",
        "commandline": "pwsh.exe",
        "startingDirectory": "D:\\Dropbox (Personal)",
        "colorScheme": "One Half Dark"
      },
      {
        "guid": "{17bf3de4-5353-5709-bcf9-835bd952a95e}",
        "name": "Trading Shell",
        "commandline": "pwsh.exe -NoExit -Command \"Set-Location 'D:\\Dropbox (Personal)'\"",
        "startingDirectory": "D:\\Dropbox (Personal)",
        "icon": "📈",
        "colorScheme": "Campbell"
      }
    ]
  },
  "schemes": [],
  "actions": [
    { "command": "copy", "keys": "ctrl+c" },
    { "command": "paste", "keys": "ctrl+v" },
    { "command": "find", "keys": "ctrl+shift+f" },
    { "command": "newTab", "keys": "ctrl+t" },
    { "command": "closeTab", "keys": "ctrl+w" }
  ]
}
```

## System Optimization

### Startup Programs

```powershell
# List startup programs
Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location

# Disable unnecessary startup programs
Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run
Remove-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -Name "ProgramName"
```

### Performance Tweaks

```powershell
# Disable visual effects for better performance
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name VisualFXSetting -Value 2

# Disable Windows animations
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name MinAnimate -Value 0

# Adjust for best performance of programs
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name Win32PrioritySeparation -Value 38
```

## Backup Configuration

### Backup Profile Settings

```powershell
# Backup PowerShell profile
Copy-Item -Path $PROFILE -Destination "D:\Backups\Profile\PowerShell_profile.ps1" -Force

# Backup VS Code settings
Copy-Item -Path "$env:APPDATA\Code\User\settings.json" -Destination "D:\Backups\Profile\vscode_settings.json" -Force

# Backup Git config
Copy-Item -Path "$HOME\.gitconfig" -Destination "D:\Backups\Profile\gitconfig" -Force

# Backup SSH keys (encrypted)
Copy-Item -Path "$HOME\.ssh\*" -Destination "D:\Backups\Profile\ssh\" -Recurse -Force
```

### Restore Profile Settings

```powershell
# Restore PowerShell profile
Copy-Item -Path "D:\Backups\Profile\PowerShell_profile.ps1" -Destination $PROFILE -Force

# Restore VS Code settings
Copy-Item -Path "D:\Backups\Profile\vscode_settings.json" -Destination "$env:APPDATA\Code\User\settings.json" -Force

# Restore Git config
Copy-Item -Path "D:\Backups\Profile\gitconfig" -Destination "$HOME\.gitconfig" -Force

# Restore SSH keys
Copy-Item -Path "D:\Backups\Profile\ssh\*" -Destination "$HOME\.ssh\" -Recurse -Force
```

## Profile Templates

### Developer Profile JSON

```json
{
  "profileName": "Developer",
  "type": "development",
  "tools": [
    "git",
    "nodejs",
    "python",
    "docker",
    "vscode"
  ],
  "extensions": [
    "ms-python.python",
    "esbenp.prettier-vscode",
    "github.copilot"
  ],
  "environmentVariables": {
    "NODE_ENV": "development",
    "PYTHON_ENV": "development"
  }
}
```

### Trader Profile JSON

```json
{
  "profileName": "Trader",
  "type": "trading",
  "applications": [
    "MetaTrader 4",
    "MetaTrader 5",
    "Trading Bridge"
  ],
  "services": [
    "docker-compose",
    "postgresql",
    "redis"
  ],
  "environmentVariables": {
    "TRADING_MODE": "LIVE",
    "BROKER_API_URL": "https://api.broker.com",
    "LOG_LEVEL": "INFO"
  }
}
```

## Maintenance

### Regular Updates

```powershell
# Update Windows
Install-Module PSWindowsUpdate -Force
Get-WindowsUpdate -Install -AcceptAll -AutoReboot

# Update winget packages
winget upgrade --all

# Update npm packages
npm update -g

# Update pip packages
pip list --outdated --format=freeze | %{$_.split('==')[0]} | %{pip install --upgrade $_}
```

## Related Documents

- [Security Guide](security-guide.md)
- [Troubleshooting Guide](troubleshooting.md)
- [Main README](../README.md)
