# HyperNode Complete Edition - Pure PowerShell Installer
# No BAT commands, pure PowerShell

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "HyperNode Complete Edition Installer" -ForegroundColor Yellow
Write-Host "Version 2.0.0" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: System check
Write-Host "[1/8] System Check" -ForegroundColor Yellow
Write-Host "Operating System: $($env:OS)"
Write-Host "Architecture: $($env:PROCESSOR_ARCHITECTURE)"

if ($env:OS -ne "Windows_NT") {
    Write-Host "ERROR: Not running on Windows" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Windows detected" -ForegroundColor Green
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
        Write-Host "  Trying winget..." -NoNewline
        winget install Python.Python.3.11 --silent --accept-package-agreements 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host " ✓" -ForegroundColor Green
        } else {
            Write-Host " ✗" -ForegroundColor Red
            Write-Host "  Downloading Python installer..." -ForegroundColor Yellow
            $pythonUrl = "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe"
            $pythonInstaller = "$env:TEMP\python_installer.exe"
            
            try {
                Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonInstaller
                Write-Host "  Installing Python..." -ForegroundColor Yellow
                Start-Process -FilePath $pythonInstaller -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
                Remove-Item $pythonInstaller -Force
                Write-Host "  Python installation complete" -ForegroundColor Green
            } catch {
                Write-Host "  Python installation failed" -ForegroundColor Red
                Write-Host "  Please install manually: https://www.python.org/downloads/" -ForegroundColor Yellow
                Read-Host "Press Enter to exit"
                exit 1
            }
        }
        
        # Verify installation
        python --version 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Python installation verification failed" -ForegroundColor Red
            Write-Host "Please add Python to PATH and try again" -ForegroundColor Yellow
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
Write-Host "[3/8] Create Installation Directory" -ForegroundColor Yellow
$installDir = "$env:USERPROFILE\.hypernode_complete"
Write-Host "Target directory: $installDir"

if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    Write-Host "Directory created" -ForegroundColor Green
} else {
    Write-Host "Directory already exists" -ForegroundColor Gray
}

Set-Location $installDir

# Create subdirectories
@("logs", "data", "plugins", "backups") | ForEach-Object {
    $subDir = Join-Path $installDir $_
    if (-not (Test-Path $subDir)) {
        New-Item -ItemType Directory -Path $subDir -Force | Out-Null
    }
}

Write-Host "Directory structure created" -ForegroundColor Green
Write-Host ""

# Step 4: Download HyperNode Complete
Write-Host "[4/8] Download HyperNode Complete" -ForegroundColor Yellow
$programUrl = "https://raw.githubusercontent.com/fguod/hypernode-global/main/hypernode_complete.py"
$programPath = "$installDir\hypernode_complete.py"

Write-Host "Downloading from: $programUrl"
Write-Host "Saving to: $programPath"
Write-Host ""

# Try multiple download methods
$downloadSuccess = $false
$methods = @(
    @{ Name = "Invoke-WebRequest"; Script = { 
        try {
            Invoke-WebRequest -Uri $programUrl -OutFile $programPath -ErrorAction Stop
            return $true
        } catch {
            return $false
        }
    } },
    @{ Name = "WebClient"; Script = { 
        try {
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFile($programUrl, $programPath)
            return $true
        } catch {
            return $false
        }
    } },
    @{ Name = "bitsadmin"; Script = { 
        & bitsadmin /transfer hypernode_complete /download $programUrl $programPath 2>&1 | Out-Null
        return (Test-Path $programPath)
    } },
    @{ Name = "certutil"; Script = { 
        & certutil -urlcache -split -f $programUrl $programPath 2>&1 | Out-Null
        return (Test-Path $programPath)
    } }
)

foreach ($method in $methods) {
    try {
        Write-Host "  Trying $($method.Name)..." -NoNewline
        $result = & $method.Script
        if ($result -and (Test-Path $programPath)) {
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
    Write-Host "ERROR: All download methods failed" -ForegroundColor Red
    Write-Host "Please download manually: $programUrl" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Download successful" -ForegroundColor Green
Write-Host ""

# Step 5: Install dependencies
Write-Host "[5/8] Install Dependencies" -ForegroundColor Yellow
Set-Location $installDir

$dependencies = @("paho-mqtt", "psutil", "requests")

foreach ($dep in $dependencies) {
    try {
        Write-Host "  Installing $dep..." -NoNewline
        $installCmd = "python -m pip install $dep --quiet --disable-pip-version-check"
        $output = Invoke-Expression $installCmd 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host " ✓" -ForegroundColor Green
        } else {
            # Try with --user
            $installCmd = "python -m pip install $dep --user --quiet --disable-pip-version-check"
            $output = Invoke-Expression $installCmd 2>&1
            
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

Write-Host "Dependencies installation complete" -ForegroundColor Green
Write-Host ""

# Step 6: Create startup scripts
Write-Host "[6/8] Create Startup Scripts" -ForegroundColor Yellow

# Create PowerShell startup script
$psContent = @"
# HyperNode Complete Edition - PowerShell Launcher
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "HyperNode Complete Edition" -ForegroundColor Yellow
Write-Host "Version 2.0.0" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Set-Location "$installDir"
python hypernode_complete.py
"@

$psContent | Out-File -FilePath "$installDir\start.ps1" -Encoding UTF8
Write-Host "  PowerShell script: start.ps1 created" -ForegroundColor Green

# Create batch startup script (ASCII only)
$batchContent = @"
@echo off
cd /d "%~dp0"
python hypernode_complete.py
pause
"@

$batchContent | Out-File -FilePath "$installDir\start.bat" -Encoding ASCII
Write-Host "  Batch script: start.bat created" -ForegroundColor Green

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
Write-Host "INSTALLATION SUCCESSFUL" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Installation Directory: $installDir" -ForegroundColor Yellow
Write-Host ""
Write-Host "Startup Options:" -ForegroundColor Yellow
Write-Host "  1. PowerShell:    $installDir\start.ps1" -ForegroundColor Gray
Write-Host "  2. Batch file:    $installDir\start.bat" -ForegroundColor Gray
Write-Host "  3. Direct run:    cd $installDir && python hypernode_complete.py" -ForegroundColor Gray
Write-Host ""
Write-Host "Features Installed:" -ForegroundColor Yellow
Write-Host "  - Real-time monitoring" -ForegroundColor White
Write-Host "  - Hardware information collection" -ForegroundColor White
Write-Host "  - Remote command execution (safe)" -ForegroundColor White
Write-Host "  - File operations (list, read, write)" -ForegroundColor White
Write-Host "  - Process and service management" -ForegroundColor White
Write-Host "  - Auto-update system" -ForegroundColor White
Write-Host "  - Plugin system support" -ForegroundColor White
Write-Host "  - Configuration management" -ForegroundColor White
Write-Host "  - Logging and rotation" -ForegroundColor White
Write-Host "  - Backup and restore" -ForegroundColor White
Write-Host "  - Scheduled tasks" -ForegroundColor White
Write-Host "  - Security controls" -ForegroundColor White
Write-Host ""
Write-Host "MQTT Brokers Configured:" -ForegroundColor Cyan
Write-Host "  - broker.emqx.io:1883 (Primary)" -ForegroundColor Gray
Write-Host "  - test.mosquitto.org:1883 (Backup)" -ForegroundColor Gray
Write-Host "  - mqtt.eclipseprojects.io:1883 (Backup)" -ForegroundColor Gray
Write-Host ""

# Ask to start now
$choice = Read-Host "Start HyperNode now? (Y/N)"
if ($choice -eq 'Y' -or $choice -eq 'y') {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "STARTING HYPERNODE COMPLETE EDITION" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Set-Location $installDir
    python hypernode_complete.py
} else {
    Write-Host ""
    Write-Host "You can start later by running:" -ForegroundColor Yellow
    Write-Host "  cd $installDir" -ForegroundColor Gray
    Write-Host "  python hypernode_complete.py" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Documentation: https://github.com/fguod/hypernode-global" -ForegroundColor Cyan
    Write-Host ""
    Read-Host "Press Enter to exit installer"
}