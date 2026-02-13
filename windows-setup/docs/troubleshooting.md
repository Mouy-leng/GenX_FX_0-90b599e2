# Windows Setup Troubleshooting Guide

Common issues and solutions when setting up Windows for the GenZ Trading Platform.

## Table of Contents

1. [Installation Issues](#installation-issues)
2. [Network and Connectivity](#network-and-connectivity)
3. [Docker and WSL2](#docker-and-wsl2)
4. [MetaTrader Issues](#metatrader-issues)
5. [PowerShell and Scripts](#powershell-and-scripts)
6. [Performance Issues](#performance-issues)
7. [Security and Permissions](#security-and-permissions)

## Installation Issues

### Node.js Installation Failed

**Problem**: Node.js installation via winget fails or is not recognized.

**Solution**:
```powershell
# Method 1: Restart terminal after installation
# Close and reopen PowerShell/Terminal

# Method 2: Manual installation
# Download from https://nodejs.org
# Verify PATH includes C:\Program Files\nodejs\

# Method 3: Check installation
node --version
npm --version

# Method 4: Add to PATH manually
$env:Path += ";C:\Program Files\nodejs\"
[Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)
```

### Python Installation Issues

**Problem**: Python not found or wrong version.

**Solution**:
```powershell
# Check Python version
python --version

# Install specific version via winget
winget install Python.Python.3.11

# Add Python to PATH
$pythonPath = "C:\Users\$env:USERNAME\AppData\Local\Programs\Python\Python311"
[Environment]::SetEnvironmentVariable("Path", "$env:Path;$pythonPath;$pythonPath\Scripts", "User")

# Verify pip
pip --version
```

### Git Installation Problems

**Problem**: Git commands not recognized.

**Solution**:
```powershell
# Install Git
winget install Git.Git

# Configure Git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Verify installation
git --version
```

## Network and Connectivity

### Port Already in Use

**Problem**: "Port 8000 is already in use" when starting services.

**Solution**:
```powershell
# Find process using port
netstat -ano | findstr :8000

# Kill process by PID
taskkill /PID <PID> /F

# Or change port in configuration
# Edit docker-compose.yml or .env file
```

### Firewall Blocking Connections

**Problem**: Trading platform cannot connect to broker or API.

**Solution**:
```powershell
# Check firewall status
Get-NetFirewallProfile | Select-Object Name, Enabled

# Allow application through firewall
New-NetFirewallRule -DisplayName "Trading Bridge" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8000

# Temporary disable (for testing only)
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# Re-enable firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
```

### DNS Resolution Issues

**Problem**: Cannot resolve domain names.

**Solution**:
```powershell
# Flush DNS cache
ipconfig /flushdns

# Reset DNS settings
netsh int ip reset
netsh winsock reset

# Set DNS servers manually
Set-DnsClientServerAddress -InterfaceIndex (Get-NetAdapter).InterfaceIndex -ServerAddresses ("8.8.8.8","8.8.4.4")
```

### Proxy Configuration

**Problem**: Network requests fail due to proxy.

**Solution**:
```powershell
# Check proxy settings
netsh winhttp show proxy

# Set proxy
netsh winhttp set proxy proxy-server="proxy.example.com:8080" bypass-list="localhost;127.0.0.1"

# Remove proxy
netsh winhttp reset proxy

# Configure for specific tools
# npm
npm config set proxy http://proxy.example.com:8080
npm config set https-proxy http://proxy.example.com:8080

# git
git config --global http.proxy http://proxy.example.com:8080
git config --global https.proxy http://proxy.example.com:8080
```

## Docker and WSL2

### Docker Desktop Won't Start

**Problem**: Docker Desktop fails to start or crashes.

**Solution**:
```powershell
# Check WSL2 status
wsl --status

# Update WSL2
wsl --update

# Set WSL2 as default
wsl --set-default-version 2

# Restart Docker Desktop
Stop-Process -Name "Docker Desktop" -Force
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"

# Reset Docker Desktop (last resort)
# Settings > Troubleshoot > Reset to factory defaults
```

### WSL2 Installation Failed

**Problem**: WSL2 fails to install or enable.

**Solution**:
```powershell
# Enable WSL
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# Enable Virtual Machine Platform
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Restart computer
Restart-Computer

# Install WSL2 kernel update
# Download from https://aka.ms/wsl2kernel

# Set WSL2 as default
wsl --set-default-version 2

# Install Ubuntu
wsl --install -d Ubuntu
```

### Docker Compose Errors

**Problem**: docker-compose commands fail.

**Solution**:
```powershell
# Check Docker is running
docker ps

# Verify docker-compose version
docker-compose --version

# Use docker compose (v2 syntax)
docker compose up -d

# Check logs
docker-compose logs -f

# Rebuild containers
docker-compose down -v
docker-compose up --build -d
```

## MetaTrader Issues

### MetaTrader Won't Connect to Broker

**Problem**: MetaTrader cannot connect to broker server.

**Solution**:
1. Check internet connection
2. Verify broker server address
3. Check firewall settings
4. Allow MetaTrader through Windows Defender
5. Try different server if available

```powershell
# Allow MetaTrader through firewall
New-NetFirewallRule -DisplayName "MetaTrader 5" -Direction Inbound -Action Allow -Program "C:\Program Files\MetaTrader 5\terminal64.exe"
```

### Expert Advisor Not Running

**Problem**: EA doesn't start or stops immediately.

**Solution**:
1. Enable AutoTrading (Ctrl+E)
2. Check "Allow automated trading" in Options
3. Verify EA is not disabled
4. Check Expert Advisor logs
5. Ensure DLL imports are allowed (if EA uses DLLs)

```powershell
# Check EA logs
Get-Content "C:\Users\$env:USERNAME\AppData\Roaming\MetaQuotes\Terminal\<TERMINAL_ID>\MQL5\Logs\*" | Select-Object -Last 50
```

### Trading Signals Not Received

**Problem**: EA not receiving signals from backend.

**Solution**:
```powershell
# Test backend API
Invoke-WebRequest -Uri "http://localhost:8000/health" -Method GET

# Check EA configuration
# Verify API endpoint in EA settings
# Check network connectivity

# Test signal endpoint
Invoke-WebRequest -Uri "http://localhost:8000/api/signals" -Method GET

# Check logs
Get-Content "D:\Dropbox (Personal)\logs\trading-bridge.log" | Select-Object -Last 50
```

## PowerShell and Scripts

### Execution Policy Error

**Problem**: "cannot be loaded because running scripts is disabled on this system."

**Solution**:
```powershell
# Check current execution policy
Get-ExecutionPolicy

# Set execution policy for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or for specific script
PowerShell.exe -ExecutionPolicy Bypass -File .\script.ps1

# Unblock downloaded scripts
Unblock-File -Path .\script.ps1
```

### Script Fails with Permission Error

**Problem**: "Access is denied" when running script.

**Solution**:
```powershell
# Run PowerShell as Administrator
Start-Process powershell -Verb RunAs

# Or for specific command
Start-Process powershell -ArgumentList "-Command <command>" -Verb RunAs

# Check file permissions
Get-Acl .\script.ps1 | Format-List
```

### PATH Not Updated

**Problem**: Newly installed commands not found.

**Solution**:
```powershell
# Refresh environment variables (without restart)
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Or restart PowerShell/Terminal

# Verify PATH
$env:Path -split ';'
```

## Performance Issues

### High CPU Usage

**Problem**: System running slow, high CPU usage.

**Solution**:
```powershell
# Check top processes
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 ProcessName, CPU, WorkingSet

# Kill process
Stop-Process -Name "ProcessName" -Force

# Disable unnecessary startup programs
Get-CimInstance Win32_StartupCommand | Select-Object Name, Command
```

### High Memory Usage

**Problem**: System running out of memory.

**Solution**:
```powershell
# Check memory usage
Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 ProcessName, @{Name="Memory(MB)";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}}

# Clear RAM
[System.GC]::Collect()

# Increase virtual memory
# Control Panel > System > Advanced system settings > Performance Settings > Advanced > Virtual memory
```

### Disk Space Issues

**Problem**: Running out of disk space.

**Solution**:
```powershell
# Check disk space
Get-PSDrive -PSProvider FileSystem

# Find large files
Get-ChildItem -Path C:\ -Recurse -ErrorAction SilentlyContinue | Sort-Object Length -Descending | Select-Object -First 20 FullName, @{Name="Size(GB)";Expression={[math]::Round($_.Length / 1GB, 2)}}

# Clean temp files
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue

# Run disk cleanup
cleanmgr /sagerun:1

# Clean Docker
docker system prune -a --volumes
```

## Security and Permissions

### Windows Defender Blocking Application

**Problem**: Windows Defender quarantines or blocks application.

**Solution**:
```powershell
# Add exclusion
Add-MpPreference -ExclusionPath "C:\Program Files\Application"

# Add process exclusion
Add-MpPreference -ExclusionProcess "application.exe"

# Check quarantine
Get-MpThreat

# Restore from quarantine
# Windows Security > Virus & threat protection > Protection history
```

### Administrator Rights Required

**Problem**: Operation requires administrator privileges.

**Solution**:
```powershell
# Run PowerShell as Administrator
Start-Process powershell -Verb RunAs

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Write-Host "Running as Admin: $isAdmin"

# Run specific command as admin
Start-Process powershell -ArgumentList "-Command <command>" -Verb RunAs -Wait
```

### File Access Denied

**Problem**: Cannot access or modify file.

**Solution**:
```powershell
# Take ownership
takeown /F "path\to\file" /R /D Y

# Grant permissions
icacls "path\to\file" /grant "$env:USERNAME:(F)" /T

# Or use PowerShell
$acl = Get-Acl "path\to\file"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($env:USERNAME,"FullControl","Allow")
$acl.SetAccessRule($accessRule)
Set-Acl "path\to\file" $acl
```

## Common Error Messages

### "The system cannot find the path specified"

**Solution**: Check path exists and use correct separators (backslashes on Windows).

```powershell
# Check if path exists
Test-Path "D:\Dropbox (Personal)"

# Use proper path format
$path = "D:\Dropbox (Personal)\file.txt"

# Or use forward slashes
$path = "D:/Dropbox (Personal)/file.txt"
```

### "Cannot bind argument to parameter 'Path'"

**Solution**: Ensure path is properly quoted and exists.

```powershell
# Correct
Get-Content -Path "D:\Dropbox (Personal)\file.txt"

# With spaces
Get-Content -Path 'D:\Dropbox (Personal)\file.txt'

# Escaping
Get-Content -Path "D:\Dropbox `(Personal`)\file.txt"
```

### "Access to the cloud file is denied"

**Solution**: OneDrive/Dropbox file is being synced.

```powershell
# Wait for sync to complete
# Or work with local copy
# Disable cloud syncing temporarily

# Check sync status
Get-Process | Where-Object {$_.Name -like "*Dropbox*"}
```

## Getting Help

### Log Files

Check log files for detailed error information:

```powershell
# Trading logs
Get-Content "D:\Dropbox (Personal)\logs\trading.log" -Tail 50

# Application logs
Get-EventLog -LogName Application -Newest 10

# System logs
Get-EventLog -LogName System -Newest 10

# Docker logs
docker-compose logs -f

# MetaTrader logs
Get-Content "C:\Users\$env:USERNAME\AppData\Roaming\MetaQuotes\Terminal\<ID>\Logs\*.log" -Tail 50
```

### System Information

Collect system information for troubleshooting:

```powershell
# System info
systeminfo

# PowerShell version
$PSVersionTable

# Windows version
Get-ComputerInfo | Select-Object WindowsVersion, OsHardwareAbstractionLayer

# Network configuration
ipconfig /all

# Installed software
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion

# Services status
Get-Service | Where-Object {$_.Status -eq "Running"}
```

## Additional Resources

- [Windows Setup FAQ](https://docs.microsoft.com/en-us/windows/)
- [PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/)
- [Docker Documentation](https://docs.docker.com/)
- [MetaTrader Forum](https://www.mql5.com/en/forum)

## Related Documents

- [Security Guide](security-guide.md)
- [Profile Setup Guide](profile-setup.md)
- [Main README](../README.md)
