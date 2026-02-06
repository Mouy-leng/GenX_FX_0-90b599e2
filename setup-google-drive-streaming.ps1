# Google Drive Streaming Setup
# Configure Google Drive to stream files (online-only) instead of storing locally
# Only specific files/folders will be stored locally

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Google Drive Streaming Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This will configure Google Drive to:" -ForegroundColor Yellow
Write-Host "  - Stream files (online-only, not stored locally)" -ForegroundColor White
Write-Host "  - Only download files when accessed" -ForegroundColor White
Write-Host "  - Keep specific folders/files stored locally" -ForegroundColor White
Write-Host ""

# Check if Google Drive for Desktop is installed
Write-Host "[1/5] Checking Google Drive for Desktop..." -ForegroundColor Yellow

$googleDrivePaths = @(
    "$env:LOCALAPPDATA\Google\DriveFS",
    "$env:ProgramFiles\Google\Drive File Stream",
    "$env:ProgramFiles(x86)\Google\Drive File Stream",
    "$env:LOCALAPPDATA\Programs\Google\Drive"
)

$googleDriveInstalled = $false
$googleDrivePath = $null

foreach ($path in $googleDrivePaths) {
    if (Test-Path $path) {
        $googleDriveInstalled = $true
        $googleDrivePath = $path
        Write-Host "✓ Google Drive found at: $path" -ForegroundColor Green
        break
    }
}

if (-not $googleDriveInstalled) {
    Write-Host "✗ Google Drive for Desktop not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Google Drive for Desktop:" -ForegroundColor Yellow
    Write-Host "  https://www.google.com/drive/download/" -ForegroundColor Cyan
    exit 1
}

# Check Google Drive service
Write-Host ""
Write-Host "[2/5] Checking Google Drive service..." -ForegroundColor Yellow

$services = @("GoogleDriveFS", "Google Drive File Stream")
$serviceRunning = $false

foreach ($serviceName in $services) {
    try {
        $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
        if ($service -and $service.Status -eq "Running") {
            Write-Host "✓ Service '$serviceName' is running" -ForegroundColor Green
            $serviceRunning = $true
            break
        }
    } catch {
        # Service not found
    }
}

if (-not $serviceRunning) {
    Write-Host "⚠ Google Drive service not running" -ForegroundColor Yellow
    Write-Host "  Please start Google Drive for Desktop" -ForegroundColor Yellow
}

# Find Google Drive sync folder
Write-Host ""
Write-Host "[3/5] Finding Google Drive sync folder..." -ForegroundColor Yellow

$possibleDrivePaths = @(
    "G:\My Drive",
    "$env:USERPROFILE\Google Drive",
    "$env:USERPROFILE\My Drive",
    "C:\Users\$env:USERNAME\Google Drive"
)

$drivePath = $null
foreach ($path in $possibleDrivePaths) {
    if (Test-Path $path) {
        $drivePath = $path
        Write-Host "✓ Google Drive folder found: $path" -ForegroundColor Green
        break
    }
}

if (-not $drivePath) {
    Write-Host "⚠ Google Drive folder not found in common locations" -ForegroundColor Yellow
    Write-Host "  You may need to configure it manually" -ForegroundColor Yellow
}

# Configuration instructions
Write-Host ""
Write-Host "[4/5] Configuration Instructions" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To enable streaming mode (online-only):" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Open Google Drive for Desktop:" -ForegroundColor White
Write-Host "   - Right-click Google Drive icon in system tray" -ForegroundColor Gray
Write-Host "   - Click 'Settings' or 'Preferences'" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Go to 'Preferences' → 'Google Drive' tab" -ForegroundColor White
Write-Host ""
Write-Host "3. Select 'Stream files' (recommended):" -ForegroundColor White
Write-Host "   - Files stay in the cloud" -ForegroundColor Gray
Write-Host "   - Only downloaded when you open them" -ForegroundColor Gray
Write-Host "   - Saves local disk space" -ForegroundColor Gray
Write-Host ""
Write-Host "4. For specific folders to store locally:" -ForegroundColor White
Write-Host "   - Right-click folder in Google Drive" -ForegroundColor Gray
Write-Host "   - Select 'Available offline'" -ForegroundColor Gray
Write-Host "   - Or use 'Mirror files' for specific folders only" -ForegroundColor Gray
Write-Host ""

# Cleanup local Google Drive files (if in mirror mode)
Write-Host "[5/5] Checking for local files to clean..." -ForegroundColor Yellow

if ($drivePath) {
    $localFiles = Get-ChildItem -Path $drivePath -Recurse -File -ErrorAction SilentlyContinue | 
        Where-Object { $_.FullName -notmatch "\.gdoc$|\.gsheet$|\.gslides$" }
    
    if ($localFiles.Count -gt 0) {
        Write-Host "  Found $($localFiles.Count) files in Google Drive folder" -ForegroundColor White
        Write-Host ""
        Write-Host "⚠ If you switch to streaming mode, these files will:" -ForegroundColor Yellow
        Write-Host "  - Remain in the cloud" -ForegroundColor Gray
        Write-Host "  - Be removed from local disk (freed up space)" -ForegroundColor Gray
        Write-Host "  - Be downloaded automatically when accessed" -ForegroundColor Gray
        Write-Host ""
        
        $totalSize = ($localFiles | Measure-Object -Property Length -Sum).Sum
        $sizeGB = [math]::Round($totalSize / 1GB, 2)
        Write-Host "  Total size: $sizeGB GB" -ForegroundColor Cyan
    } else {
        Write-Host "  ✓ No local files found (already in streaming mode?)" -ForegroundColor Green
    }
}

# Create configuration guide
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Configuration Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Recommended Setup:" -ForegroundColor Yellow
Write-Host "  Mode: Stream files (online-only)" -ForegroundColor Green
Write-Host "  Benefits:" -ForegroundColor White
Write-Host "    - Saves local disk space" -ForegroundColor Gray
Write-Host "    - Files accessible from any device" -ForegroundColor Gray
Write-Host "    - Automatic cloud sync" -ForegroundColor Gray
Write-Host ""
Write-Host "  For scripts/files that need local storage:" -ForegroundColor White
Write-Host "    - Right-click → 'Available offline'" -ForegroundColor Gray
Write-Host "    - Or move to a non-synced local folder" -ForegroundColor Gray
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Open Google Drive for Desktop settings" -ForegroundColor White
Write-Host "  2. Switch to 'Stream files' mode" -ForegroundColor White
Write-Host "  3. Mark specific folders as 'Available offline' if needed" -ForegroundColor White
Write-Host ""

