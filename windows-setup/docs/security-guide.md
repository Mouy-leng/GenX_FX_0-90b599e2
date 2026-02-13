# Windows Security Guide

Comprehensive security configuration and best practices for Windows systems running the GenZ Trading Platform.

## Overview

This guide covers security hardening, best practices, and configurations to protect your Windows system while running trading applications.

## Security Checklist

### System Security
- [ ] Enable Windows Defender Real-time Protection
- [ ] Configure Windows Firewall
- [ ] Enable BitLocker Drive Encryption (if available)
- [ ] Disable unnecessary services
- [ ] Configure Windows Update
- [ ] Enable User Account Control (UAC)
- [ ] Configure Windows Security settings

### Network Security
- [ ] Configure firewall rules for trading ports
- [ ] Enable Windows Defender Firewall
- [ ] Disable SMBv1 protocol
- [ ] Configure network profile (Private/Public)
- [ ] Set up VPN (if trading remotely)
- [ ] Review open ports and services

### Application Security
- [ ] Run applications with least privilege
- [ ] Configure AppLocker (Windows Pro/Enterprise)
- [ ] Enable Windows Defender Application Control
- [ ] Review startup programs
- [ ] Configure credential storage
- [ ] Use Windows Credential Manager

## Windows Defender Configuration

### Real-time Protection

```powershell
# Enable Real-time Protection
Set-MpPreference -DisableRealtimeMonitoring $false

# Enable Cloud-delivered Protection
Set-MpPreference -MAPSReporting Advanced

# Enable Automatic Sample Submission
Set-MpPreference -SubmitSamplesConsent SendAllSamples
```

### Exclusions for Trading Applications

Add exclusions for MetaTrader and trading applications to prevent performance issues:

```powershell
# Add MetaTrader directory exclusion
Add-MpPreference -ExclusionPath "C:\Program Files\MetaTrader 4"
Add-MpPreference -ExclusionPath "C:\Program Files\MetaTrader 5"
Add-MpPreference -ExclusionPath "C:\Users\$env:USERNAME\AppData\Roaming\MetaQuotes"

# Add project directory exclusion
Add-MpPreference -ExclusionPath "D:\Dropbox (Personal)"
```

## Firewall Configuration

### Trading Platform Ports

Configure firewall rules for trading applications:

```powershell
# Allow MetaTrader 4/5
New-NetFirewallRule -DisplayName "MetaTrader 4" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 443
New-NetFirewallRule -DisplayName "MetaTrader 5" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 443,8080

# Allow Trading Bridge
New-NetFirewallRule -DisplayName "Trading Bridge API" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8000
New-NetFirewallRule -DisplayName "Trading Bridge Port" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 5555

# Allow Docker services (if using Docker)
New-NetFirewallRule -DisplayName "Docker API" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 2375
```

### Block Unnecessary Ports

```powershell
# Block common attack vectors
New-NetFirewallRule -DisplayName "Block Telnet" -Direction Inbound -Action Block -Protocol TCP -LocalPort 23
New-NetFirewallRule -DisplayName "Block SMBv1" -Direction Inbound -Action Block -Protocol TCP -LocalPort 445
```

## User Account Control (UAC)

Configure UAC for security without constant prompts:

```powershell
# Set UAC to notify only when programs try to make changes
# 0 = Never notify
# 1 = Notify only when apps try to make changes (no dimming)
# 2 = Notify only when apps try to make changes (default)
# 3 = Always notify
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 2
```

## Privacy Settings

### Disable Telemetry and Data Collection

```powershell
# Disable telemetry
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0

# Disable activity history
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Value 0

# Disable location tracking
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny"
```

## Service Hardening

### Disable Unnecessary Services

```powershell
# Disable Remote Registry (if not needed)
Set-Service -Name "RemoteRegistry" -StartupType Disabled

# Disable Print Spooler (if not printing)
Set-Service -Name "Spooler" -StartupType Disabled

# Disable Windows Error Reporting
Set-Service -Name "WerSvc" -StartupType Disabled
```

### Essential Services for Trading

Keep these services enabled:
- Windows Defender Antivirus Service
- Windows Time
- Windows Update
- Network Connection Broker
- TCP/IP NetBIOS Helper

## Credential Management

### Secure Credential Storage

```powershell
# Store API credentials securely
$credential = Get-Credential
$credential.Password | ConvertFrom-SecureString | Set-Content "C:\secure\api-key.txt"

# Retrieve credentials
$password = Get-Content "C:\secure\api-key.txt" | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PSCredential("api-user", $password)
```

### Environment Variables

Store non-sensitive configuration in environment variables:

```powershell
# Set user environment variable
[Environment]::SetEnvironmentVariable("BROKER_API_URL", "https://api.broker.com", "User")

# Set system environment variable (requires admin)
[Environment]::SetEnvironmentVariable("TRADING_MODE", "PRODUCTION", "Machine")
```

## Network Security

### VPN Configuration

For remote trading, use a VPN:

1. Configure Windows VPN client
2. Use split tunneling to route only trading traffic through VPN
3. Enable automatic reconnection
4. Configure DNS settings

### Proxy Configuration

If using a proxy:

```powershell
# Set proxy for current user
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyEnable -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyServer -Value "proxy.example.com:8080"

# Configure proxy bypass
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyOverride -Value "localhost;127.0.0.1;*.local"
```

## BitLocker Encryption

### Enable BitLocker

```powershell
# Check BitLocker status
Get-BitLockerVolume

# Enable BitLocker on C: drive
Enable-BitLocker -MountPoint "C:" -EncryptionMethod XtsAes256 -UsedSpaceOnly

# Backup recovery key
Backup-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $KeyProtector.KeyProtectorId
```

## Security Monitoring

### Event Log Monitoring

Monitor security events:

```powershell
# Check failed login attempts
Get-EventLog -LogName Security -InstanceId 4625 -Newest 10

# Check successful logins
Get-EventLog -LogName Security -InstanceId 4624 -Newest 10

# Check firewall rule changes
Get-EventLog -LogName Security -InstanceId 4946,4947,4948 -Newest 10
```

### Performance Monitoring

```powershell
# Check system performance
Get-Counter -Counter "\Processor(_Total)\% Processor Time","\Memory\Available MBytes"

# Check network usage
Get-Counter -Counter "\Network Interface(*)\Bytes Total/sec"
```

## Regular Security Tasks

### Weekly Tasks
- [ ] Review Windows Update status
- [ ] Check Windows Defender scan results
- [ ] Review firewall logs
- [ ] Check for suspicious processes
- [ ] Review installed programs

### Monthly Tasks
- [ ] Full system scan with Windows Defender
- [ ] Review and update firewall rules
- [ ] Check for Windows updates
- [ ] Review user accounts and permissions
- [ ] Backup important configurations

### Quarterly Tasks
- [ ] Security audit
- [ ] Password rotation
- [ ] Review and update security policies
- [ ] Test backup and restore procedures
- [ ] Review and update documentation

## Emergency Response

### Suspected Compromise

1. Disconnect from network immediately
2. Run full system scan
3. Review recent login attempts
4. Check for unauthorized changes
5. Review firewall and application logs
6. Change all passwords
7. Contact security team

### Ransomware Protection

```powershell
# Enable Controlled Folder Access
Set-MpPreference -EnableControlledFolderAccess Enabled

# Add protected folders
Add-MpPreference -ControlledFolderAccessProtectedFolders "D:\Dropbox (Personal)","C:\Trading"

# Allow trusted applications
Add-MpPreference -ControlledFolderAccessAllowedApplications "C:\Program Files\MetaTrader 4\terminal.exe"
```

## Resources

- [Microsoft Security Baseline](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-security-baselines)
- [CIS Windows Benchmarks](https://www.cisecurity.org/benchmark/microsoft_windows_desktop)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

## Related Documents

- [Profile Setup Guide](profile-setup.md)
- [Troubleshooting Guide](troubleshooting.md)
- [Main README](../README.md)
