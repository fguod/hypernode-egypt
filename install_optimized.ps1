# HyperNode Optimized Installer
# Customized for: User-2025ZPVXAR (Windows 11 Pro, Intel i7-14700, 16GB RAM)

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "🚀 HYPERNODE OPTIMIZED INSTALLER" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Customized for your system:" -ForegroundColor White
Write-Host "  • Device: User-2025ZPVXAR" -ForegroundColor Gray
Write-Host "  • Processor: Intel i7-14700" -ForegroundColor Gray
Write-Host "  • Memory: 16GB RAM" -ForegroundColor Gray
Write-Host "  • OS: Windows 11 Pro 24H2" -ForegroundColor Gray
Write-Host "  • Python: 3.14.3" -ForegroundColor Gray
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Verify Python
Write-Host "[1/5] Verifying Python installation..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Python found: $pythonVersion" -ForegroundColor Green
        
        # Check Python version
        $versionMatch = $pythonVersion -match "Python (\d+\.\d+\.\d+)"
        if ($versionMatch) {
            $ver = $matches[1]
            Write-Host "  📊 Version: $ver" -ForegroundColor Gray
        }
    } else {
        Write-Host "  ❌ Python not found or not in PATH" -ForegroundColor Red
        Write-Host "  💡 Please ensure Python 3.8+ is installed and in PATH" -ForegroundColor Yellow
        Write-Host "  🔗 Download: https://www.python.org/downloads/" -ForegroundColor Blue
        Read-Host "Press Enter to exit"
        exit 1
    }
} catch {
    Write-Host "  ❌ Error checking Python: $_" -ForegroundColor Red
    exit 1
}

# Step 2: Create optimized directory
Write-Host "[2/5] Creating optimized installation directory..." -ForegroundColor Yellow
$installDir = "$env:USERPROFILE\.hypernode_optimized"
try {
    if (-not (Test-Path $installDir)) {
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
        Write-Host "  ✅ Created: $installDir" -ForegroundColor Green
    } else {
        Write-Host "  📁 Directory exists: $installDir" -ForegroundColor Gray
    }
    
    # Create logs subdirectory
    $logsDir = "$installDir\logs"
    if (-not (Test-Path $logsDir)) {
        New-Item -ItemType Directory -Path $logsDir -Force | Out-Null
    }
    
    Set-Location $installDir
} catch {
    Write-Host "  ❌ Error creating directory: $_" -ForegroundColor Red
    exit 1
}

# Step 3: Download optimized node program
Write-Host "[3/5] Downloading optimized node program..." -ForegroundColor Yellow
$nodeUrl = "https://raw.githubusercontent.com/fguod/hypernode-global/main/node_optimized.py"
$nodePath = "$installDir\node_optimized.py"

$downloadMethods = @(
    @{ Name = "Invoke-WebRequest"; Script = { Invoke-WebRequest -Uri $nodeUrl -OutFile $nodePath -ErrorAction Stop } },
    @{ Name = "System.Net.WebClient"; Script = { 
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($nodeUrl, $nodePath)
    } },
    @{ Name = "bitsadmin"; Script = { & bitsadmin /transfer optimized /download $nodeUrl $nodePath 2>&1 | Out-Null } }
)

$downloadSuccess = $false
foreach ($method in $downloadMethods) {
    try {
        Write-Host "  Trying $($method.Name)..." -NoNewline
        & $method.Script
        if (Test-Path $nodePath -PathType Leaf) {
            Write-Host " ✅" -ForegroundColor Green
            $downloadSuccess = $true
            break
        } else {
            Write-Host " ❌" -ForegroundColor Red
        }
    } catch {
        Write-Host " ❌" -ForegroundColor Red
    }
}

if (-not $downloadSuccess) {
    Write-Host "  ❌ All download methods failed" -ForegroundColor Red
    Write-Host "  💡 Please download manually from:" -ForegroundColor Yellow
    Write-Host "  🔗 $nodeUrl" -ForegroundColor Blue
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "  ✅ Optimized program downloaded" -ForegroundColor Green

# Step 4: Install optimized dependencies
Write-Host "[4/5] Installing optimized dependencies..." -ForegroundColor Yellow
$dependencies = @("paho-mqtt", "psutil")

foreach ($dep in $dependencies) {
    try {
        Write-Host "  Installing $dep..." -NoNewline
        $installCmd = "python -m pip install $dep --quiet --disable-pip-version-check"
        Invoke-Expression $installCmd 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host " ✅" -ForegroundColor Green
        } else {
            # Try with --user
            Write-Host "  Installing $dep (user mode)..." -NoNewline
            $installCmd = "python -m pip install $dep --user --quiet --disable-pip-version-check"
            Invoke-Expression $installCmd 2>&1 | Out-Null
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host " ✅" -ForegroundColor Green
            } else {
                Write-Host " ⚠️" -ForegroundColor Yellow
                Write-Host "    Note: $dep installation had issues" -ForegroundColor Gray
            }
        }
    } catch {
        Write-Host " ⚠️" -ForegroundColor Yellow
        Write-Host "    Note: $dep installation error" -ForegroundColor Gray
    }
}

# Step 5: Create startup scripts
Write-Host "[5/5] Creating startup scripts..." -ForegroundColor Yellow

# Create batch file
$batchContent = @"
@echo off
chcp 65001 >nul
echo ========================================
echo 🚀 HyperNode Optimized
echo ========================================
echo Customized for: User-2025ZPVXAR
echo Processor: Intel i7-14700
echo Memory: 16GB RAM
echo ========================================
cd /d "%~dp0"
python node_optimized.py
pause
"@

$batchContent | Out-File -FilePath "$installDir\start_optimized.bat" -Encoding ASCII
Write-Host "  ✅ Batch script: start_optimized.bat" -ForegroundColor Green

# Create PowerShell script
$psContent = @"
# HyperNode Optimized - PowerShell Launcher
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "🚀 HyperNode Optimized" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Customized for: User-2025ZPVXAR" -ForegroundColor White
Write-Host "Processor: Intel i7-14700 | Memory: 16GB RAM" -ForegroundColor Gray
Write-Host "================================================" -ForegroundColor Cyan
Set-Location "$installDir"
python node_optimized.py
"@

$psContent | Out-File -FilePath "$installDir\start_optimized.ps1" -Encoding UTF8
Write-Host "  ✅ PowerShell script: start_optimized.ps1" -ForegroundColor Green

# Installation complete
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "✅ OPTIMIZED INSTALLATION COMPLETE!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📁 Installation Directory:" -ForegroundColor Yellow
Write-Host "  $installDir" -ForegroundColor Gray
Write-Host ""
Write-Host "🚀 Startup Options:" -ForegroundColor Yellow
Write-Host "  1. Batch file:    $installDir\start_optimized.bat" -ForegroundColor Gray
Write-Host "  2. PowerShell:    $installDir\start_optimized.ps1" -ForegroundColor Gray
Write-Host "  3. Direct run:    cd $installDir && python node_optimized.py" -ForegroundColor Gray
Write-Host ""
Write-Host "🔧 Optimized Features:" -ForegroundColor Yellow
Write-Host "  • Customized for your Intel i7-14700 processor" -ForegroundColor White
Write-Host "  • Optimized for 16GB RAM system" -ForegroundColor White
Write-Host "  • Detailed hardware monitoring" -ForegroundColor White
Write_Host "  • Auto-dependency installation" -ForegroundColor White
Write-Host "  • Enhanced error handling" -ForegroundColor White
Write-Host ""

# Ask to start now
$choice = Read-Host "Start optimized node now? (Y/N)"
if ($choice -eq 'Y' -or $choice -eq 'y') {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "🚀 LAUNCHING OPTIMIZED NODE..." -ForegroundColor Yellow
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
    Set-Location $installDir
    python node_optimized.py
} else {
    Write-Host ""
    Write-Host "💡 You can start later by running:" -ForegroundColor Yellow
    Write-Host "  cd $installDir" -ForegroundColor Gray
    Write-Host "  python node_optimized.py" -ForegroundColor Gray
    Write-Host ""
    Read-Host "Press Enter to exit installer"
}