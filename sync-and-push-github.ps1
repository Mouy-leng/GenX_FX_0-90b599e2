# Sync Local Files and Push to GitHub
# Pulls latest changes, syncs local files, commits, and pushes to GitHub

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Sync Local & Push to GitHub" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# Check Git installation
Write-Host "[1/6] Checking Git..." -ForegroundColor Yellow
try {
    $gitVersion = git --version 2>&1
    Write-Host "✓ $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Git is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

# Check if Git repository
Write-Host ""
Write-Host "[2/6] Checking Git repository..." -ForegroundColor Yellow
try {
    git rev-parse --git-dir 2>&1 | Out-Null
    Write-Host "✓ Git repository found" -ForegroundColor Green
} catch {
    Write-Host "⚠ Not a git repository" -ForegroundColor Yellow
    Write-Host "  Initializing git repository..." -ForegroundColor Gray
    git init
    Write-Host "✓ Git repository initialized" -ForegroundColor Green
}

# Check remote
Write-Host ""
Write-Host "[3/6] Checking remote repository..." -ForegroundColor Yellow
$remote = git remote get-url origin 2>&1
if ($remote -and $remote -notmatch "fatal") {
    Write-Host "✓ Remote: $remote" -ForegroundColor Green
    $hasRemote = $true
} else {
    Write-Host "⚠ No remote repository configured" -ForegroundColor Yellow
    Write-Host "  Run: git remote add origin YOUR_REPO_URL" -ForegroundColor Gray
    $hasRemote = $false
}

# Pull latest changes
if ($hasRemote) {
    Write-Host ""
    Write-Host "[4/6] Pulling latest changes from GitHub..." -ForegroundColor Yellow
    try {
        $branch = git branch --show-current 2>&1
        if ($branch -and $branch -notmatch "fatal") {
            $branch = $branch.Trim()
            Write-Host "  Branch: $branch" -ForegroundColor Gray
            git pull origin $branch 2>&1 | ForEach-Object {
                if ($_ -match "error|fatal|conflict") {
                    Write-Host "  $_" -ForegroundColor Yellow
                } else {
                    Write-Host "  $_" -ForegroundColor Gray
                }
            }
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✓ Pull completed" -ForegroundColor Green
            } else {
                Write-Host "⚠ Pull had issues (may be normal if no changes)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  No branch found, skipping pull" -ForegroundColor Gray
        }
    } catch {
        Write-Host "⚠ Could not pull: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host ""
    Write-Host "[4/6] Skipping pull (no remote configured)" -ForegroundColor Gray
}

# Check status
Write-Host ""
Write-Host "[5/6] Checking local changes..." -ForegroundColor Yellow
$status = git status --short 2>&1
if ($status -and $status.Count -gt 0) {
    Write-Host "  Changes found:" -ForegroundColor Green
    $status | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }
    
    # Stage changes
    Write-Host ""
    Write-Host "  Staging changes..." -ForegroundColor Yellow
    git add . 2>&1 | Out-Null
    Write-Host "✓ Files staged" -ForegroundColor Green
    
    # Commit
    Write-Host ""
    Write-Host "  Committing changes..." -ForegroundColor Yellow
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $commitMessage = "Sync local changes - $timestamp"
    
    git commit -m $commitMessage 2>&1 | ForEach-Object {
        if ($_ -match "nothing to commit") {
            Write-Host "  ⚠ $_" -ForegroundColor Yellow
        } else {
            Write-Host "  $_" -ForegroundColor Gray
        }
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Commit created" -ForegroundColor Green
        $hasChanges = $true
    } else {
        Write-Host "  No changes to commit" -ForegroundColor Gray
        $hasChanges = $false
    }
} else {
    Write-Host "  No changes to commit" -ForegroundColor Gray
    $hasChanges = $false
}

# Push to GitHub
if ($hasRemote) {
    Write-Host ""
    Write-Host "[6/6] Pushing to GitHub..." -ForegroundColor Yellow
    if ($hasChanges) {
        try {
            $branch = git branch --show-current 2>&1
            if ($branch -and $branch -notmatch "fatal") {
                $branch = $branch.Trim()
                git push origin $branch 2>&1 | ForEach-Object {
                    if ($_ -match "error|fatal|denied") {
                        Write-Host "  $_" -ForegroundColor Red
                    } elseif ($_ -match "success|done|pushed") {
                        Write-Host "  $_" -ForegroundColor Green
                    } else {
                        Write-Host "  $_" -ForegroundColor Gray
                    }
                }
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "✓ Push completed successfully" -ForegroundColor Green
                } else {
                    Write-Host "⚠ Push failed - check authentication or network" -ForegroundColor Yellow
                }
            }
        } catch {
            Write-Host "✗ Push error: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "  No changes to push" -ForegroundColor Gray
    }
} else {
    Write-Host ""
    Write-Host "[6/6] Skipping push (no remote configured)" -ForegroundColor Gray
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Sync Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
if ($hasRemote) {
    Write-Host "Repository: $remote" -ForegroundColor White
} else {
    Write-Host "⚠ No remote configured" -ForegroundColor Yellow
    Write-Host "  To add remote: git remote add origin YOUR_REPO_URL" -ForegroundColor Gray
}
Write-Host ""

