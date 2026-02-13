# Apply Windows Profile Configuration
# Run with: powershell -ExecutionPolicy Bypass -File apply-profile.ps1 -ProfileName "developer"

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("developer", "trader", "default")]
    [string]$ProfileName
)

Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Applying Profile: $ProfileName" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Load profile configuration
$profilePath = Join-Path $PSScriptRoot "..\profiles\$ProfileName.json"

if (-not (Test-Path $profilePath)) {
    Write-Host "❌ Profile not found: $profilePath" -ForegroundColor Red
    exit 1
}

Write-Host "📄 Loading profile configuration..." -ForegroundColor Yellow
$profile = Get-Content $profilePath | ConvertFrom-Json
Write-Host "✅ Profile loaded: $($profile.profileName)" -ForegroundColor Green
Write-Host ""

# Apply environment variables
if ($profile.environmentVariables) {
    Write-Host "🔧 Applying environment variables..." -ForegroundColor Yellow
    
    foreach ($key in $profile.environmentVariables.PSObject.Properties.Name) {
        $value = $profile.environmentVariables.$key
        [Environment]::SetEnvironmentVariable($key, $value, "User")
        Write-Host "  • $key = $value" -ForegroundColor White
    }
    Write-Host "✅ Environment variables applied" -ForegroundColor Green
    Write-Host ""
}

# Apply Git configuration
if ($profile.gitConfig) {
    Write-Host "🔧 Applying Git configuration..." -ForegroundColor Yellow
    
    foreach ($key in $profile.gitConfig.PSObject.Properties.Name) {
        $value = $profile.gitConfig.$key
        git config --global $key $value
        Write-Host "  • $key = $value" -ForegroundColor White
    }
    Write-Host "✅ Git configuration applied" -ForegroundColor Green
    Write-Host ""
}

# Create directories
if ($profile.directories) {
    Write-Host "📁 Creating directories..." -ForegroundColor Yellow
    
    foreach ($key in $profile.directories.PSObject.Properties.Name) {
        $dir = $profile.directories.$key
        # Expand environment variables
        $dir = [Environment]::ExpandEnvironmentVariables($dir)
        
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-Host "  • Created: $dir" -ForegroundColor White
        } else {
            Write-Host "  • Exists: $dir" -ForegroundColor Gray
        }
    }
    Write-Host "✅ Directories created" -ForegroundColor Green
    Write-Host ""
}

# Install VS Code extensions
if ($profile.vscodeExtensions) {
    Write-Host "🔌 Installing VS Code extensions..." -ForegroundColor Yellow
    
    if (Get-Command code -ErrorAction SilentlyContinue) {
        foreach ($extension in $profile.vscodeExtensions) {
            Write-Host "  • Installing: $extension" -ForegroundColor White
            code --install-extension $extension --force | Out-Null
        }
        Write-Host "✅ VS Code extensions installed" -ForegroundColor Green
    } else {
        Write-Host "⚠️  VS Code not found, skipping extensions" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Install npm packages
if ($profile.npmPackages) {
    Write-Host "📦 Installing npm packages..." -ForegroundColor Yellow
    
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        foreach ($package in $profile.npmPackages) {
            Write-Host "  • Installing: $package" -ForegroundColor White
            npm install -g $package 2>&1 | Out-Null
        }
        Write-Host "✅ npm packages installed" -ForegroundColor Green
    } else {
        Write-Host "⚠️  npm not found, skipping packages" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Install pip packages
if ($profile.pipPackages) {
    Write-Host "📦 Installing pip packages..." -ForegroundColor Yellow
    
    if (Get-Command python -ErrorAction SilentlyContinue) {
        foreach ($package in $profile.pipPackages) {
            Write-Host "  • Installing: $package" -ForegroundColor White
            python -m pip install $package 2>&1 | Out-Null
        }
        Write-Host "✅ pip packages installed" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Python not found, skipping packages" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Configure firewall rules (trader profile)
if ($profile.firewallRules) {
    Write-Host "🔥 Configuring firewall rules..." -ForegroundColor Yellow
    
    foreach ($rule in $profile.firewallRules) {
        $ruleName = $rule.name
        $protocol = $rule.protocol
        $ports = $rule.ports -join ","
        $direction = $rule.direction
        $action = $rule.action
        
        # Check if rule exists
        $existingRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
        
        if ($existingRule) {
            Write-Host "  • Rule exists: $ruleName" -ForegroundColor Gray
        } else {
            New-NetFirewallRule -DisplayName $ruleName `
                -Direction $direction `
                -Action $action `
                -Protocol $protocol `
                -LocalPort $ports `
                -ErrorAction SilentlyContinue | Out-Null
            Write-Host "  • Created: $ruleName ($ports)" -ForegroundColor White
        }
    }
    Write-Host "✅ Firewall rules configured" -ForegroundColor Green
    Write-Host ""
}

# Configure Windows Defender exclusions (trader profile)
if ($profile.securitySettings -and $profile.securitySettings.windowsDefender) {
    Write-Host "🛡️  Configuring Windows Defender..." -ForegroundColor Yellow
    
    $defender = $profile.securitySettings.windowsDefender
    
    if ($defender.realtimeProtection -ne $null) {
        Set-MpPreference -DisableRealtimeMonitoring (-not $defender.realtimeProtection) -ErrorAction SilentlyContinue
        Write-Host "  • Real-time protection: $($defender.realtimeProtection)" -ForegroundColor White
    }
    
    if ($defender.exclusions) {
        foreach ($exclusion in $defender.exclusions) {
            $expandedPath = [Environment]::ExpandEnvironmentVariables($exclusion)
            Add-MpPreference -ExclusionPath $expandedPath -ErrorAction SilentlyContinue
            Write-Host "  • Added exclusion: $expandedPath" -ForegroundColor White
        }
    }
    
    Write-Host "✅ Windows Defender configured" -ForegroundColor Green
    Write-Host ""
}

# Create scheduled tasks (trader profile)
if ($profile.scheduledTasks) {
    Write-Host "⏰ Creating scheduled tasks..." -ForegroundColor Yellow
    
    foreach ($task in $profile.scheduledTasks) {
        $taskName = $task.name
        $script = $task.script
        
        # Check if task exists
        $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        
        if ($existingTask) {
            Write-Host "  • Task exists: $taskName" -ForegroundColor Gray
        } else {
            Write-Host "  • Task needs manual creation: $taskName" -ForegroundColor Yellow
            Write-Host "    Script: $script" -ForegroundColor Gray
        }
    }
    Write-Host "✅ Scheduled tasks reviewed" -ForegroundColor Green
    Write-Host ""
}

Write-Host "════════════════════════════════════════" -ForegroundColor Green
Write-Host "  Profile Applied Successfully!" -ForegroundColor Green
Write-Host "════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Profile Summary:" -ForegroundColor Cyan
Write-Host "  • Profile: $($profile.profileName)" -ForegroundColor White
Write-Host "  • Type: $($profile.profileType)" -ForegroundColor White
Write-Host "  • Description: $($profile.description)" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  Important:" -ForegroundColor Yellow
Write-Host "  • Restart your terminal to apply environment changes" -ForegroundColor White
Write-Host "  • Some changes may require a system restart" -ForegroundColor White
Write-Host ""
