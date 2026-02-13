# Windows Setup & Configuration

Personal Windows settings and profile setup for security and daily use with the GenZ Trading Platform.

## Overview

This directory contains Windows-specific configuration, setup scripts, and documentation for:
- System security configuration
- Development environment setup
- Daily use optimizations
- Trading platform integration

## Quick Start

### Prerequisites
- Windows 10/11
- Administrator access
- PowerShell 5.1 or later

### Initial Setup

1. **Run the main setup script:**
   ```powershell
   .\scripts\windows\setup-complete-system.bat
   ```

2. **Configure security settings:**
   ```powershell
   .\windows-setup\scripts\configure-security.bat
   ```

3. **Set up development environment:**
   ```powershell
   .\windows-setup\scripts\setup-dev-environment.bat
   ```

## Directory Structure

```
windows-setup/
├── README.md                          # This file
├── docs/                              # Documentation
│   ├── security-guide.md             # Security best practices
│   ├── profile-setup.md              # User profile configuration
│   └── troubleshooting.md            # Common issues and solutions
├── scripts/                           # Setup and configuration scripts
│   ├── configure-security.bat        # Security hardening script
│   ├── setup-dev-environment.bat     # Development tools setup
│   ├── install-dependencies.ps1      # Install required software
│   └── backup-settings.ps1           # Backup current settings
├── configs/                           # Configuration files
│   ├── windows-terminal/             # Windows Terminal settings
│   ├── vscode/                       # VS Code settings
│   └── powershell/                   # PowerShell profile
└── profiles/                          # User profiles
    ├── developer.json                # Developer profile
    ├── trader.json                   # Trading profile
    └── default.json                  # Default profile
```

## Features

### Security Configuration
- Windows Defender optimization
- Firewall rules for trading platforms
- Privacy settings
- Network security

### Development Environment
- Git configuration
- Node.js and Python setup
- VS Code extensions
- Docker and WSL2

### Trading Platform Integration
- MetaTrader 4/5 setup
- Trading bridge configuration
- Port forwarding and networking
- Service monitoring

### Daily Use Optimizations
- Startup programs management
- System cleanup scripts
- Backup automation
- Performance optimization

## Documentation

Detailed documentation is available in the `docs/` directory:

- [Security Guide](docs/security-guide.md) - Security best practices and hardening
- [Profile Setup](docs/profile-setup.md) - User profile configuration
- [Troubleshooting](docs/troubleshooting.md) - Common issues and solutions
- [GenX FX Scripts Integration](docs/genx-fx-scripts-integration.md) - Integration with OneNote scripts

## Integration with GenZ Trading Platform

This Windows setup integrates with:
- **Expert Advisors**: MT4/MT5 EA configuration
- **Trading Bridge**: Network and port configuration
- **Backend Services**: Docker and service setup
- **Monitoring**: System health and performance monitoring

## Contributing

When adding new Windows configurations:
1. Add scripts to `scripts/` directory
2. Document in appropriate `docs/` file
3. Update this README with new features
4. Test on clean Windows installation

## Related Resources

- [Main Project Documentation](../README.md)
- [Windows Scripts](../scripts/windows/)
- [Deployment Guide](../DEPLOYMENT_SETUP_INSTRUCTIONS.md)
- [Quick Start Guide](../QUICK-START.md)
- [OneNote: GenX FX Scripts](https://onedrive.live.com/view.aspx?resid=C2A387A2E5F8E82F%21s46a641de030b454da4f3527bf2985073) - Script documentation and examples

## Support

For issues or questions:
1. Check [Troubleshooting Guide](docs/troubleshooting.md)
2. Review [Setup Status](../SETUP-STATUS.md)
3. Consult [NotebookLM Knowledge Base](https://notebooklm.google.com/notebook/e8f4c29d-9aec-4d5f-8f51-2ca168687616)

## License

This configuration is part of the GenZ FX Trading Platform.
See [LICENSE](../LICENSE) for details.
