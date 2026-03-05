# HyperNode One-Line Installer
# Run this directly in PowerShell

$installDir = "$env:USERPROFILE\.hypernode_complete"
New-Item -ItemType Directory -Path $installDir -Force | Out-Null
Set-Location $installDir

Write-Host "Downloading HyperNode Complete..." -ForegroundColor Yellow
$url = "https://raw.githubusercontent.com/fguod/hypernode-global/main/hypernode_complete.py"
Invoke-WebRequest -Uri $url -OutFile "hypernode_complete.py"

Write-Host "Installing dependencies..." -ForegroundColor Yellow
python -m pip install paho-mqtt psutil --quiet --disable-pip-version-check 2>&1 | Out-Null

Write-Host "Creating startup script..." -ForegroundColor Yellow
'@echo off
cd /d "%~dp0"
python hypernode_complete.py
pause' | Out-File -FilePath "start.bat" -Encoding ASCII

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "HyperNode Complete Edition Installed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Directory: $installDir" -ForegroundColor Yellow
Write-Host "To start: .\start.bat" -ForegroundColor Yellow
Write-Host "Or: python hypernode_complete.py" -ForegroundColor Yellow
Write-Host ""
Write-Host "Starting HyperNode..." -ForegroundColor Yellow
Write-Host ""

python hypernode_complete.py