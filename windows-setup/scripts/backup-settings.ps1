# PowerShell Script to Backup Windows Settings and Configurations
# Run with: powershell -ExecutionPolicy Bypass -File backup-settings.ps1

param(
    [string]$BackupPath = "D:\Backups\WindowsSetup",
    [switch]$IncludeSecrets = $false
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Windows Settings Backup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Create backup directory with timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$backupDir = Join-Path $BackupPath $timestamp
Write-Host "Creating backup directory: $backupDir" -ForegroundColor Yellow

try {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    Write-Host "Backup directory created successfully." -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to create backup directory: $_" -ForegroundColor Red
    exit 1
}

# Backup PowerShell Profile
Write-Host "`n[1/12] Backing up PowerShell profile..." -ForegroundColor Yellow
if (Test-Path $PROFILE) {
    $profileBackup = Join-Path $backupDir "PowerShell"
    New-Item -ItemType Directory -Path $profileBackup -Force | Out-Null
    Copy-Item -Path $PROFILE -Destination (Join-Path $profileBackup "Microsoft.PowerShell_profile.ps1") -Force
    Write-Host "PowerShell profile backed up." -ForegroundColor Green
} else {
    Write-Host "No PowerShell profile found." -ForegroundColor Gray
}

# Backup VS Code Settings
Write-Host "`n[2/12] Backing up VS Code settings..." -ForegroundColor Yellow
$vscodeSettings = "$env:APPDATA\Code\User\settings.json"
if (Test-Path $vscodeSettings) {
    $vscodeBackup = Join-Path $backupDir "VSCode"
    New-Item -ItemType Directory -Path $vscodeBackup -Force | Out-Null
    Copy-Item -Path $vscodeSettings -Destination $vscodeBackup -Force
    Copy-Item -Path "$env:APPDATA\Code\User\keybindings.json" -Destination $vscodeBackup -Force -ErrorAction SilentlyContinue
    Copy-Item -Path "$env:APPDATA\Code\User\snippets" -Destination $vscodeBackup -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "VS Code settings backed up." -ForegroundColor Green
} else {
    Write-Host "No VS Code settings found." -ForegroundColor Gray
}

# Backup Git Config
Write-Host "`n[3/12] Backing up Git configuration..." -ForegroundColor Yellow
$gitConfig = "$HOME\.gitconfig"
if (Test-Path $gitConfig) {
    $gitBackup = Join-Path $backupDir "Git"
    New-Item -ItemType Directory -Path $gitBackup -Force | Out-Null
    Copy-Item -Path $gitConfig -Destination $gitBackup -Force
    Write-Host "Git configuration backed up." -ForegroundColor Green
} else {
    Write-Host "No Git configuration found." -ForegroundColor Gray
}

# Backup SSH Keys (without private keys unless specified)
Write-Host "`n[4/12] Backing up SSH keys..." -ForegroundColor Yellow
$sshDir = "$HOME\.ssh"
if (Test-Path $sshDir) {
    $sshBackup = Join-Path $backupDir "SSH"
    New-Item -ItemType Directory -Path $sshBackup -Force | Out-Null
    
    if ($IncludeSecrets) {
        Copy-Item -Path "$sshDir\*" -Destination $sshBackup -Recurse -Force
        Write-Host "SSH keys backed up (including private keys)." -ForegroundColor Yellow
    } else {
        Copy-Item -Path "$sshDir\*.pub" -Destination $sshBackup -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$sshDir\config" -Destination $sshBackup -Force -ErrorAction SilentlyContinue
        Write-Host "SSH public keys backed up (private keys excluded)." -ForegroundColor Green
    }
} else {
    Write-Host "No SSH keys found." -ForegroundColor Gray
}

# Backup Windows Terminal Settings
Write-Host "`n[5/12] Backing up Windows Terminal settings..." -ForegroundColor Yellow
$wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $wtSettings) {
    $wtBackup = Join-Path $backupDir "WindowsTerminal"
    New-Item -ItemType Directory -Path $wtBackup -Force | Out-Null
    Copy-Item -Path $wtSettings -Destination $wtBackup -Force
    Write-Host "Windows Terminal settings backed up." -ForegroundColor Green
} else {
    Write-Host "No Windows Terminal settings found." -ForegroundColor Gray
}

# Backup Environment Variables
Write-Host "`n[6/12] Backing up environment variables..." -ForegroundColor Yellow
$envBackup = Join-Path $backupDir "Environment"
New-Item -ItemType Directory -Path $envBackup -Force | Out-Null

$userEnv = [Environment]::GetEnvironmentVariables("User")
$machineEnv = [Environment]::GetEnvironmentVariables("Machine")

$userEnv | ConvertTo-Json | Out-File (Join-Path $envBackup "user_environment.json") -Force
$machineEnv | ConvertTo-Json | Out-File (Join-Path $envBackup "machine_environment.json") -Force
Write-Host "Environment variables backed up." -ForegroundColor Green

# Backup Firewall Rules
Write-Host "`n[7/12] Backing up firewall rules..." -ForegroundColor Yellow
$firewallBackup = Join-Path $backupDir "Firewall"
New-Item -ItemType Directory -Path $firewallBackup -Force | Out-Null

Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*Trading*" -or $_.DisplayName -like "*MetaTrader*"} | 
    Export-Csv -Path (Join-Path $firewallBackup "firewall_rules.csv") -NoTypeInformation -Force
Write-Host "Firewall rules backed up." -ForegroundColor Green

# Backup Scheduled Tasks
Write-Host "`n[8/12] Backing up scheduled tasks..." -ForegroundColor Yellow
$tasksBackup = Join-Path $backupDir "ScheduledTasks"
New-Item -ItemType Directory -Path $tasksBackup -Force | Out-Null

Get-ScheduledTask | Where-Object {$_.TaskName -like "*Trading*" -or $_.TaskName -like "*Backup*"} | 
    ForEach-Object {
        $taskName = $_.TaskName
        Export-ScheduledTask -TaskName $taskName -TaskPath $_.TaskPath | 
            Out-File (Join-Path $tasksBackup "$taskName.xml") -Force
    }
Write-Host "Scheduled tasks backed up." -ForegroundColor Green

# Backup Installed Software List
Write-Host "`n[9/12] Backing up installed software list..." -ForegroundColor Yellow
$softwareBackup = Join-Path $backupDir "Software"
New-Item -ItemType Directory -Path $softwareBackup -Force | Out-Null

Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | 
    Where-Object {$_.DisplayName -ne $null} | 
    Export-Csv -Path (Join-Path $softwareBackup "installed_software.csv") -NoTypeInformation -Force
Write-Host "Installed software list backed up." -ForegroundColor Green

# Backup Registry Keys (selected)
Write-Host "`n[10/12] Backing up registry keys..." -ForegroundColor Yellow
$registryBackup = Join-Path $backupDir "Registry"
New-Item -ItemType Directory -Path $registryBackup -Force | Out-Null

# Export important registry keys
$regKeys = @(
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer",
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
)

foreach ($key in $regKeys) {
    $keyName = $key.Replace("\", "_").Replace(":", "")
    $regFile = Join-Path $registryBackup "$keyName.reg"
    reg export $key $regFile /y | Out-Null
}
Write-Host "Registry keys backed up." -ForegroundColor Green

# Backup Docker Configuration
Write-Host "`n[11/12] Backing up Docker configuration..." -ForegroundColor Yellow
$dockerConfig = "$HOME\.docker\config.json"
if (Test-Path $dockerConfig) {
    $dockerBackup = Join-Path $backupDir "Docker"
    New-Item -ItemType Directory -Path $dockerBackup -Force | Out-Null
    Copy-Item -Path $dockerConfig -Destination $dockerBackup -Force
    Write-Host "Docker configuration backed up." -ForegroundColor Green
} else {
    Write-Host "No Docker configuration found." -ForegroundColor Gray
}

# Backup Trading Platform Configurations
Write-Host "`n[12/12] Backing up trading platform configurations..." -ForegroundColor Yellow
$tradingBackup = Join-Path $backupDir "Trading"
New-Item -ItemType Directory -Path $tradingBackup -Force | Out-Null

# Backup MetaTrader configurations
$mt4Path = "C:\Users\$env:USERNAME\AppData\Roaming\MetaQuotes\Terminal"
$mt5Path = "C:\Program Files\MetaTrader 5\MQL5"

if (Test-Path $mt4Path) {
    Copy-Item -Path "$mt4Path\*.ini" -Destination $tradingBackup -Force -ErrorAction SilentlyContinue
}

# Backup .env files (without secrets unless specified)
if (Test-Path "D:\Dropbox (Personal)\.env.example") {
    Copy-Item -Path "D:\Dropbox (Personal)\.env.example" -Destination $tradingBackup -Force
}

Write-Host "Trading platform configurations backed up." -ForegroundColor Green

# Create backup manifest
Write-Host "`nCreating backup manifest..." -ForegroundColor Yellow
$manifest = @{
    BackupDate = $timestamp
    BackupPath = $backupDir
    ComputerName = $env:COMPUTERNAME
    UserName = $env:USERNAME
    WindowsVersion = (Get-ComputerInfo).WindowsVersion
    IncludeSecrets = $IncludeSecrets
    BackupItems = @(
        "PowerShell Profile",
        "VS Code Settings",
        "Git Configuration",
        "SSH Keys",
        "Windows Terminal Settings",
        "Environment Variables",
        "Firewall Rules",
        "Scheduled Tasks",
        "Installed Software List",
        "Registry Keys",
        "Docker Configuration",
        "Trading Platform Configurations"
    )
}

$manifest | ConvertTo-Json | Out-File (Join-Path $backupDir "backup_manifest.json") -Force
Write-Host "Backup manifest created." -ForegroundColor Green

# Create README
$readme = @"
# Windows Settings Backup

**Backup Date:** $timestamp
**Computer:** $env:COMPUTERNAME
**User:** $env:USERNAME

## Backup Contents

- PowerShell Profile
- VS Code Settings
- Git Configuration
- SSH Keys $(if ($IncludeSecrets) { "(including private keys)" } else { "(public keys only)" })
- Windows Terminal Settings
- Environment Variables
- Firewall Rules
- Scheduled Tasks
- Installed Software List
- Registry Keys
- Docker Configuration
- Trading Platform Configurations

## Restoration

To restore settings, run:

``````powershell
.\restore-settings.ps1 -BackupPath "$backupDir"
``````

## Security Note

$(if ($IncludeSecrets) {
    "⚠️ This backup includes sensitive data (private keys, secrets). Store securely!"
} else {
    "✓ This backup excludes sensitive data (private keys not included)."
})

For full backup including secrets, run:

``````powershell
.\backup-settings.ps1 -IncludeSecrets
``````

"@

$readme | Out-File (Join-Path $backupDir "README.md") -Force

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Backup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Backup location: $backupDir" -ForegroundColor Cyan
Write-Host "Backup size: $((Get-ChildItem $backupDir -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB) MB" -ForegroundColor Cyan
Write-Host ""
Write-Host "To restore this backup, run:" -ForegroundColor Yellow
Write-Host "  .\restore-settings.ps1 -BackupPath `"$backupDir`"" -ForegroundColor White
Write-Host ""

if (-not $IncludeSecrets) {
    Write-Host "Note: Private keys were not backed up. Use -IncludeSecrets to include them." -ForegroundColor Yellow
}

pause
