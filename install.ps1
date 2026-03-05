# Simple Node - PowerShell Installer
Write-Host "========================================" -ForegroundColor Green
Write-Host "Simple Node Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Check Python
Write-Host "Checking Python..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Python found: $pythonVersion" -ForegroundColor Green
    } else {
        Write-Host "❌ Python not found" -ForegroundColor Red
        Write-Host "Please install Python 3.8+ from: https://www.python.org/downloads/" -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
        exit 1
    }
} catch {
    Write-Host "❌ Python not found" -ForegroundColor Red
    Write-Host "Please install Python 3.8+ from: https://www.python.org/downloads/" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Create directory
Write-Host "Creating directory..." -ForegroundColor Yellow
$installDir = "$env:USERPROFILE\.simple_node"
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
}
Set-Location $installDir
Write-Host "✅ Directory: $installDir" -ForegroundColor Green

# Download node.py
Write-Host "Downloading node program..." -ForegroundColor Yellow
$nodeUrl = "https://raw.githubusercontent.com/fguod/hypernode-global/main/node.py"
$nodePath = "$installDir\node.py"

# Try multiple download methods
$downloadSuccess = $false

# Method 1: Invoke-WebRequest
try {
    Write-Host "  Method 1: Invoke-WebRequest..." -NoNewline
    Invoke-WebRequest -Uri $nodeUrl -OutFile $nodePath -ErrorAction Stop
    if (Test-Path $nodePath) {
        Write-Host " ✅" -ForegroundColor Green
        $downloadSuccess = $true
    }
} catch {
    Write-Host " ❌" -ForegroundColor Red
}

# Method 2: System.Net.WebClient
if (-not $downloadSuccess) {
    try {
        Write-Host "  Method 2: WebClient..." -NoNewline
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($nodeUrl, $nodePath)
        if (Test-Path $nodePath) {
            Write-Host " ✅" -ForegroundColor Green
            $downloadSuccess = $true
        }
    } catch {
        Write-Host " ❌" -ForegroundColor Red
    }
}

# Method 3: bitsadmin (Windows built-in)
if (-not $downloadSuccess) {
    try {
        Write-Host "  Method 3: bitsadmin..." -NoNewline
        & bitsadmin /transfer node /download $nodeUrl $nodePath 2>&1 | Out-Null
        if (Test-Path $nodePath) {
            Write-Host " ✅" -ForegroundColor Green
            $downloadSuccess = $true
        }
    } catch {
        Write-Host " ❌" -ForegroundColor Red
    }
}

if (-not $downloadSuccess) {
    Write-Host "❌ All download methods failed" -ForegroundColor Red
    Write-Host "Please download manually from: $nodeUrl" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✅ Download successful" -ForegroundColor Green

# Install paho-mqtt
Write-Host "Installing MQTT library..." -ForegroundColor Yellow
try {
    Write-Host "  Installing paho-mqtt..." -NoNewline
    python -m pip install paho-mqtt --quiet 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅" -ForegroundColor Green
    } else {
        # Try with --user
        Write-Host "  Trying with --user..." -NoNewline
        python -m pip install paho-mqtt --user --quiet 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host " ✅" -ForegroundColor Green
        } else {
            Write-Host " ⚠️" -ForegroundColor Yellow
            Write-Host "  Note: You may need to install manually: pip install paho-mqtt" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host " ⚠️" -ForegroundColor Yellow
    Write-Host "  Note: You may need to install manually: pip install paho-mqtt" -ForegroundColor Yellow
}

# Create start script
Write-Host "Creating start script..." -ForegroundColor Yellow
$startScript = @"
@echo off
cd /d "%~dp0"
python node.py
pause
"@
$startScript | Out-File -FilePath "$installDir\start.bat" -Encoding ASCII
Write-Host "✅ Start script created: start.bat" -ForegroundColor Green

# Create PowerShell start script
$psStartScript = @"
# PowerShell start script
Set-Location "$installDir"
python node.py
"@
$psStartScript | Out-File -FilePath "$installDir\start.ps1" -Encoding UTF8

# Installation complete
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "✅ Installation Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Installation Directory: $installDir" -ForegroundColor Yellow
Write-Host "Main Program: node.py" -ForegroundColor Yellow
Write-Host ""
Write-Host "To start the node:" -ForegroundColor Cyan
Write-Host "  Method 1: PowerShell" -ForegroundColor White
Write-Host "    cd $installDir" -ForegroundColor Gray
Write-Host "    python node.py" -ForegroundColor Gray
Write-Host ""
Write-Host "  Method 2: Batch file" -ForegroundColor White
Write-Host "    $installDir\start.bat" -ForegroundColor Gray
Write-Host ""
Write-Host "  Method 3: PowerShell script" -ForegroundColor White
Write-Host "    $installDir\start.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "Features:" -ForegroundColor Cyan
Write-Host "  • Connects to MQTT broker" -ForegroundColor White
Write-Host "  • Responds to commands" -ForegroundColor White
Write-Host "  • Auto-reconnect" -ForegroundColor White
Write-Host "  • Simple and reliable" -ForegroundColor White
Write-Host ""

# Ask to start now
$choice = Read-Host "Start node now? (Y/N)"
if ($choice -eq 'Y' -or $choice -eq 'y') {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "🚀 Starting Simple Node..." -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Set-Location $installDir
    python node.py
} else {
    Write-Host ""
    Write-Host "You can start later by running:" -ForegroundColor Yellow
    Write-Host "  cd $installDir && python node.py" -ForegroundColor Gray
    Write-Host ""
    Read-Host "Press Enter to exit"
}