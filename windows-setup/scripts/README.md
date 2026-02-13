# Windows Setup Scripts

This directory contains automation scripts for setting up and configuring Windows for the GenZ Trading Platform.

## Scripts Overview

### Master Setup
- **master-setup.bat** - Interactive menu-driven setup wizard
  - Complete setup (all features)
  - Quick setup (essentials only)
  - Developer setup
  - Trader setup
  - Security configuration
  - Backup/restore functionality

### Setup Scripts
- **setup-dev-environment.bat** - Development tools setup
  - Installs Git, Node.js, Python, Docker, VS Code
  - Configures Git basics
  - Sets up Windows Terminal and PowerShell 7

- **install-dependencies.ps1** - Comprehensive dependency installation
  - Uses Chocolatey for package management
  - Installs all required development tools
  - Configures Python and Node.js packages

### Configuration Scripts
- **configure-security.bat** - Security hardening
  - Windows Defender configuration
  - Firewall rules for trading platforms
  - User Account Control settings
  - Service hardening

- **apply-profile.ps1** - Apply profile configurations
  - Loads profile JSON files
  - Applies environment variables
  - Installs tools and extensions
  - Configures firewall and security

### Backup Scripts
- **backup-settings.ps1** - Backup Windows configurations
  - PowerShell profile
  - VS Code settings
  - Git configuration
  - SSH keys (optional)
  - Environment variables
  - Firewall rules
  - Scheduled tasks

## Usage

### Quick Start

Run the master setup script with administrator privileges:

```batch
REM Right-click and select "Run as administrator"
master-setup.bat
```

### Individual Scripts

#### Setup Development Environment
```batch
setup-dev-environment.bat
```

#### Install Dependencies
```powershell
powershell -ExecutionPolicy Bypass -File install-dependencies.ps1
```

#### Configure Security
```batch
configure-security.bat
```

#### Apply Profile
```powershell
# Apply developer profile
powershell -ExecutionPolicy Bypass -File apply-profile.ps1 -ProfileName "developer"

# Apply trader profile
powershell -ExecutionPolicy Bypass -File apply-profile.ps1 -ProfileName "trader"

# Apply default profile
powershell -ExecutionPolicy Bypass -File apply-profile.ps1 -ProfileName "default"
```

#### Backup Settings
```powershell
# Standard backup (excludes secrets)
powershell -ExecutionPolicy Bypass -File backup-settings.ps1

# Full backup (includes private keys)
powershell -ExecutionPolicy Bypass -File backup-settings.ps1 -IncludeSecrets
```

## Prerequisites

### Required
- Windows 10/11
- PowerShell 5.1 or later
- Administrator privileges

### Recommended
- Internet connection for downloading packages
- 20 GB free disk space
- Windows Terminal

## Script Execution Policy

If you encounter execution policy errors:

```powershell
# Set execution policy for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or bypass for single script
powershell -ExecutionPolicy Bypass -File script.ps1
```

## Profiles

Profiles are stored in `../profiles/` directory:

- **developer.json** - Development tools and configurations
- **trader.json** - Trading platform configurations
- **default.json** - Basic Windows setup

See [Profile Setup Guide](../docs/profile-setup.md) for details.

## Troubleshooting

### Common Issues

1. **"Running scripts is disabled"**
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **"Access is denied"**
   - Run PowerShell as Administrator
   - Right-click script → Run as administrator

3. **"winget is not available"**
   - Install App Installer from Microsoft Store
   - Update Windows to latest version

4. **Tools not found after installation**
   - Restart terminal/PowerShell
   - Or restart computer
   - Check PATH environment variable

See [Troubleshooting Guide](../docs/troubleshooting.md) for more solutions.

## Script Details

### master-setup.bat

Interactive menu with options:
1. Complete Setup - Full installation and configuration
2. Quick Setup - Essential tools only
3. Developer Setup - Development environment
4. Trader Setup - Trading platform configuration
5. Security Configuration - Security hardening only
6. Backup Settings - Create backup
7. Restore Settings - Restore from backup
8. View Status - Check installed tools

### install-dependencies.ps1

Installs:
- Chocolatey package manager
- Git version control
- Node.js and npm
- Python 3.11
- Docker Desktop
- Visual Studio Code
- Windows Terminal
- PowerShell 7

### apply-profile.ps1

Applies profile configuration:
- Environment variables
- Git configuration
- Directory structure
- VS Code extensions
- npm/pip packages
- Firewall rules
- Security settings

### backup-settings.ps1

Backs up:
- PowerShell profile
- VS Code settings and extensions
- Git configuration
- SSH keys (optional)
- Windows Terminal settings
- Environment variables
- Firewall rules
- Scheduled tasks
- Registry keys
- Docker configuration

## Safety Features

- Checks for administrator rights
- Validates prerequisites
- Creates backups before changes
- Provides error messages
- Allows step-by-step execution

## Related Documentation

- [Main README](../README.md)
- [Security Guide](../docs/security-guide.md)
- [Profile Setup](../docs/profile-setup.md)
- [Troubleshooting](../docs/troubleshooting.md)
- [GenX FX Scripts Integration](../docs/genx-fx-scripts-integration.md)

## Support

For issues or questions:
1. Check [Troubleshooting Guide](../docs/troubleshooting.md)
2. Review script output for errors
3. Check log files in `logs/` directory
4. Consult [NotebookLM Knowledge Base](https://notebooklm.google.com/notebook/e8f4c29d-9aec-4d5f-8f51-2ca168687616)
