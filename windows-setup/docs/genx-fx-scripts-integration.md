# GenX FX Scripts Integration

This document provides information about integrating GenX FX Scripts from the OneNote Knowledge Base.

## OneNote Reference

The GenX FX Scripts are documented in the project's OneNote notebook:
- **Location**: Quick Notes → 📚 GenX FX Scripts
- **Web Link**: [View in OneNote Online](https://onedrive.live.com/view.aspx?resid=C2A387A2E5F8E82F%21s46a641de030b454da4f3527bf2985073&id=documents&wd=target%28Quick%20Notes.one%7C4E83547D-BE66-0C41-A75C-5E54B5E32B77%2F%F0%9F%93%9A%20GenX%20FX%20Scripts%7CABAA5693-EC59-BA49-9E1F-CAF64D450021%2F%29)
- **OneNote Protocol**: `onenote:https://d.docs.live.net/C2A387A2E5F8E82F/Documents/GenX's%20Notebook/Quick%20Notes.one#📚%20GenX%20FX%20Scripts`

## Available Scripts

The GenX FX Scripts collection includes various automation and utility scripts for:

### Trading Operations
- Signal generation and analysis
- Trade execution automation
- Risk management utilities
- Performance monitoring

### System Management
- Environment setup and configuration
- Service health checks
- Backup and restore operations
- Log management

### Data Processing
- Market data collection
- Pattern recognition
- Indicator calculations
- Report generation

## Integration Points

### Windows Scripts Directory

The scripts integrate with the existing Windows scripts in:
- `/scripts/windows/` - Windows-specific batch files
- `/scripts/setup/` - Setup and installation scripts
- `/scripts/maintenance/` - Maintenance and cleanup scripts

### Windows-Setup Directory

Configuration and profiles for:
- `windows-setup/scripts/` - Setup automation scripts
- `windows-setup/configs/` - Application configurations
- `windows-setup/profiles/` - User profile templates

## Usage

### Accessing Scripts

1. **From OneNote**:
   - Open the OneNote link above
   - Copy scripts to your local environment
   - Follow setup instructions in the notes

2. **From Repository**:
   ```bash
   # Navigate to scripts directory
   cd scripts/windows
   
   # Run setup scripts
   .\setup-complete-system.bat
   ```

3. **From Windows-Setup**:
   ```powershell
   # Navigate to windows-setup
   cd windows-setup/scripts
   
   # Run configuration
   .\configure-security.bat
   .\setup-dev-environment.bat
   ```

### Script Categories

#### Setup Scripts
Located in `scripts/windows/`:
- `setup-complete-system.bat` - Complete system setup
- `setup-credentials.bat` - Credential configuration
- `setup-auth.bat` - Authentication setup

#### Trading Scripts
Located in `scripts/windows/`:
- `start-genx-complete.bat` - Start complete trading system
- `start-gold-signals.bat` - Start gold signal generation
- `start-24-7-backend.bat` - Start 24/7 backend service

#### Maintenance Scripts
Located in `scripts/windows/`:
- `backup_to_usb.bat` - Backup to USB drive
- `cleanup-c-drive.bat` - Clean up C drive
- `organize-d-drive.bat` - Organize D drive structure

## Configuration

### Environment Variables

Scripts may require these environment variables:

```powershell
# Trading configuration
$env:TRADING_MODE = "LIVE"  # or "DEMO"
$env:BROKER_API_URL = "https://api.broker.com"
$env:LOG_LEVEL = "INFO"

# Path configuration
$env:MT4_PATH = "C:\Program Files\MetaTrader 4"
$env:MT5_PATH = "C:\Program Files\MetaTrader 5"
$env:TRADING_LOGS = "D:\Dropbox (Personal)\logs"
```

### Script Configuration Files

Configuration files are stored in:
- `.env` - Environment variables
- `config.json` - Application configuration
- `windows-setup/profiles/*.json` - Profile configurations

## Synchronization

### OneNote to Repository

To sync scripts from OneNote to the repository:

1. Export script content from OneNote
2. Save to appropriate directory:
   - Windows batch scripts → `scripts/windows/`
   - PowerShell scripts → `windows-setup/scripts/`
   - Configuration files → `windows-setup/configs/`
3. Update documentation
4. Commit and push changes

### Script Templates

Create new scripts based on templates in:
- `windows-setup/scripts/` - PowerShell templates
- `scripts/windows/` - Batch file templates

## Best Practices

### Script Development

1. **Documentation**:
   - Add header comments with script purpose
   - Document parameters and usage
   - Include examples

2. **Error Handling**:
   - Check for prerequisites
   - Validate inputs
   - Provide clear error messages

3. **Security**:
   - Don't hardcode credentials
   - Use environment variables for sensitive data
   - Validate file paths

### Script Organization

```
scripts/
├── windows/          # Windows batch scripts
│   ├── setup/       # Setup scripts
│   ├── trading/     # Trading automation
│   └── maintenance/ # Maintenance tasks
└── ...

windows-setup/
├── scripts/         # PowerShell scripts
│   ├── configure-security.bat
│   ├── setup-dev-environment.bat
│   ├── install-dependencies.ps1
│   └── backup-settings.ps1
└── ...
```

## Troubleshooting

### Common Issues

1. **Script Not Found**:
   - Check file path
   - Verify script exists
   - Check permissions

2. **Execution Policy**:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **Missing Dependencies**:
   - Run `install-dependencies.ps1`
   - Check OneNote for requirements

### Getting Help

1. Check OneNote documentation
2. Review troubleshooting guide: `windows-setup/docs/troubleshooting.md`
3. Check logs in `logs/` directory
4. Review setup status: `SETUP-STATUS.md`

## Additional Resources

- [Windows Setup README](README.md)
- [Security Guide](docs/security-guide.md)
- [Profile Setup Guide](docs/profile-setup.md)
- [Troubleshooting Guide](docs/troubleshooting.md)
- [NotebookLM Knowledge Base](https://notebooklm.google.com/notebook/e8f4c29d-9aec-4d5f-8f51-2ca168687616)

## Contributing

To add new scripts to the collection:

1. Document script in OneNote
2. Add script file to appropriate directory
3. Update this integration guide
4. Test on clean Windows installation
5. Submit pull request

## Notes

- Keep OneNote as the primary documentation source
- Sync important scripts to repository
- Maintain consistency between OneNote and repository
- Document all changes in both locations
