@echo off
chcp 65001 >nul
title HyperNode Complete Edition Installer

echo ╔══════════════════════════════════════════════════════════════╗
echo ║                    HYPERNODE COMPLETE EDITION                ║
echo ║                         Version 2.0.0                        ║
echo ╠══════════════════════════════════════════════════════════════╣
echo ║  Full-featured distributed AI node with enterprise features  ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

:: ==================== STEP 1: SYSTEM CHECK ====================
echo [1/8] System Check
echo ====================
echo.

:: Check Windows version
ver | find "Windows" >nul
if %errorlevel% neq 0 (
    echo ❌ Not running on Windows
    pause
    exit /b 1
)

:: Check architecture
echo Processor Architecture:
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    echo   ✅ 64-bit (x64)
) else if "%PROCESSOR_ARCHITECTURE%"=="x86" (
    echo   ⚠️  32-bit (x86) - Some features may be limited
) else (
    echo   ⚠️  Unknown architecture: %PROCESSOR_ARCHITECTURE%
)

:: Check memory
systeminfo | find "Total Physical Memory" >nul
if %errorlevel% equ 0 (
    for /f "tokens=2 delims=:" %%i in ('systeminfo ^| find "Total Physical Memory"') do (
        set "MEMORY=%%i"
        set "MEMORY=!MEMORY:~1!"
        echo   📊 Memory: !MEMORY!
    )
)

:: ==================== STEP 2: PYTHON CHECK ====================
echo.
echo [2/8] Python Check
echo ====================
echo.

python --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=2" %%i in ('python --version 2^>^&1') do (
        echo   ✅ Python %%i detected
        set "PYTHON_VERSION=%%i"
    )
    
    :: Check Python version
    for /f "tokens=1,2,3 delims=." %%a in ("%PYTHON_VERSION%") do (
        set "PY_MAJOR=%%a"
        set "PY_MINOR=%%b"
        set "PY_PATCH=%%c"
    )
    
    if %PY_MAJOR% lss 3 (
        echo   ❌ Python 3+ required, found version %PYTHON_VERSION%
        goto :install_python
    ) else if %PY_MAJOR% equ 3 (
        if %PY_MINOR% lss 8 (
            echo   ❌ Python 3.8+ required, found version %PYTHON_VERSION%
            goto :install_python
        ) else (
            echo   ✅ Python version meets requirements
        )
    )
) else (
    echo   ❌ Python not found
    goto :install_python
)

goto :python_check_done

:install_python
echo.
echo   Installing Python 3.11...
echo   ========================
echo.
echo   Method 1: Using winget (recommended)
winget install Python.Python.3.11 --silent --accept-package-agreements >nul 2>&1
if %errorlevel% equ 0 (
    echo   ✅ Python installed via winget
) else (
    echo   ⚠️  winget failed, trying direct download...
    
    echo   Method 2: Direct download
    bitsadmin /transfer python_install /download "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe" python_installer.exe >nul 2>&1
    if exist python_installer.exe (
        echo   ✅ Download complete, running installer...
        start /wait python_installer.exe /quiet InstallAllUsers=1 PrependPath=1
        del python_installer.exe
        echo   ✅ Python installation complete
    ) else (
        echo   ❌ Download failed
        echo   Please install Python manually from: https://www.python.org/downloads/
        pause
        exit /b 1
    )
)

:: Verify installation
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo   ❌ Python installation verification failed
    echo   Please add Python to PATH and try again
    pause
    exit /b 1
)

:python_check_done

:: ==================== STEP 3: CREATE INSTALLATION DIRECTORY ====================
echo.
echo [3/8] Creating Installation Directory
echo ======================================
echo.

set "INSTALL_DIR=%USERPROFILE%\.hypernode_complete"
echo   Target directory: %INSTALL_DIR%

if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%"
    echo   ✅ Directory created
) else (
    echo   📁 Directory already exists
)

:: Create subdirectories
if not exist "%INSTALL_DIR%\logs" mkdir "%INSTALL_DIR%\logs"
if not exist "%INSTALL_DIR%\data" mkdir "%INSTALL_DIR%\data"
if not exist "%INSTALL_DIR%\plugins" mkdir "%INSTALL_DIR%\plugins"
if not exist "%INSTALL_DIR%\backups" mkdir "%INSTALL_DIR%\backups"

echo   ✅ Directory structure created

:: ==================== STEP 4: DOWNLOAD HYPERNODE COMPLETE ====================
echo.
echo [4/8] Downloading HyperNode Complete
echo =====================================
echo.

set "DOWNLOAD_URL=https://raw.githubusercontent.com/fguod/hypernode-global/main/hypernode_complete.py"
set "TARGET_FILE=%INSTALL_DIR%\hypernode_complete.py"

echo   Downloading from: %DOWNLOAD_URL%
echo   Saving to: %TARGET_FILE%
echo.

:: Method 1: bitsadmin
echo   Method 1: bitsadmin...
bitsadmin /transfer hypernode_complete /download "%DOWNLOAD_URL%" "%TARGET_FILE%" >nul 2>&1
if exist "%TARGET_FILE%" (
    echo   ✅ Download successful
    goto :download_done
)

:: Method 2: certutil
echo   Method 2: certutil...
certutil -urlcache -split -f "%DOWNLOAD_URL%" "%TARGET_FILE%" >nul 2>&1
if exist "%TARGET_FILE%" (
    echo   ✅ Download successful
    goto :download_done
)

:: Method 3: PowerShell
echo   Method 3: PowerShell...
powershell -Command "(New-Object Net.WebClient).DownloadFile('%DOWNLOAD_URL%', '%TARGET_FILE%')" >nul 2>&1
if exist "%TARGET_FILE%" (
    echo   ✅ Download successful
    goto :download_done
)

:: Method 4: curl (if available)
echo   Method 4: curl...
curl -s -o "%TARGET_FILE%" "%DOWNLOAD_URL%" >nul 2>&1
if exist "%TARGET_FILE%" (
    echo   ✅ Download successful
    goto :download_done
)

echo   ❌ All download methods failed
echo   Please download manually from: %DOWNLOAD_URL%
pause
exit /b 1

:download_done

:: ==================== STEP 5: INSTALL DEPENDENCIES ====================
echo.
echo [5/8] Installing Dependencies
echo ==============================
echo.

cd /d "%INSTALL_DIR%"

echo   Installing required Python packages...
echo   =====================================
echo.

:: Install paho-mqtt
echo   Installing paho-mqtt...
python -m pip install paho-mqtt --quiet --disable-pip-version-check >nul 2>&1
if %errorlevel% equ 0 (
    echo   ✅ paho-mqtt installed
) else (
    python -m pip install paho-mqtt --user --quiet --disable-pip-version-check >nul 2>&1
    if %errorlevel% equ 0 (
        echo   ✅ paho-mqtt installed (user mode)
    ) else (
        echo   ⚠️  paho-mqtt installation had issues
    )
)

:: Install psutil
echo   Installing psutil...
python -m pip install psutil --quiet --disable-pip-version-check >nul 2>&1
if %errorlevel% equ 0 (
    echo   ✅ psutil installed
) else (
    python -m pip install psutil --user --quiet --disable-pip-version-check >nul 2>&1
    if %errorlevel% equ 0 (
        echo   ✅ psutil installed (user mode)
    ) else (
        echo   ⚠️  psutil installation had issues
    )
)

:: Install requests (optional but recommended)
echo   Installing requests...
python -m pip install requests --quiet --disable-pip-version-check >nul 2>&1
if %errorlevel% equ 0 (
    echo   ✅ requests installed
) else (
    echo   ⚠️  requests installation skipped (optional)
)

:: Install cryptography (optional but recommended)
echo   Installing cryptography...
python -m pip install cryptography --quiet --disable-pip-version-check >nul 2>&1
if %errorlevel% equ 0 (
    echo   ✅ cryptography installed
) else (
    echo   ⚠️  cryptography installation skipped (optional)
)

:: ==================== STEP 6: CREATE STARTUP SCRIPTS ====================
echo.
echo [6/8] Creating Startup Scripts
echo ===============================
echo.

:: Create batch startup script
echo   Creating batch startup script...
echo @echo off > "%INSTALL_DIR%\start.bat"
echo chcp 65001 ^>nul >> "%INSTALL_DIR%\start.bat"
echo title HyperNode Complete Edition >> "%INSTALL_DIR%\start.bat"
echo echo ╔══════════════════════════════════════════════════════════════╗ >> "%INSTALL_DIR%\start.bat"
echo echo ║                    HYPERNODE COMPLETE EDITION                ║ >> "%INSTALL_DIR%\start.bat"
echo echo ║                         Version 2.0.0                        ║ >> "%INSTALL_DIR%\start.bat"
echo echo ╚══════════════════════════════════════════════════════════════╝ >> "%INSTALL_DIR%\start.bat"
echo echo. >> "%INSTALL_DIR%\start.bat"
echo cd /d "%%~dp0" >> "%INSTALL_DIR%\start.bat"
echo python hypernode_complete.py >> "%INSTALL_DIR%\start.bat"
echo pause >> "%INSTALL_DIR%\start.bat"
echo   ✅ start.bat created

:: Create PowerShell startup script
echo   Creating PowerShell startup script...
echo # HyperNode Complete Edition - PowerShell Launcher > "%INSTALL_DIR%\start.ps1"
echo Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan >> "%INSTALL_DIR%\start.ps1"
echo Write-Host "║                    HYPERNODE COMPLETE EDITION                ║" -ForegroundColor Yellow >> "%INSTALL_DIR%\start.ps1"
echo Write-Host "║                         Version 2.0.0                        ║" -ForegroundColor Yellow >> "%INSTALL_DIR%\start.ps1"
echo Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan >> "%INSTALL_DIR%\start.ps1"
echo Write-Host "" >> "%INSTALL_DIR%\start.ps1"
echo Set-Location "%INSTALL_DIR%" >> "%INSTALL_DIR%\start.ps1"
echo python hypernode_complete.py >> "%INSTALL_DIR%\start.ps1"
echo   ✅ start.ps1 created

:: Create service script (for advanced users)
echo   Creating service management script...
echo @echo off > "%INSTALL_DIR%\service.bat"
echo chcp 65001 ^>nul >> "%INSTALL_DIR%\service.bat"
echo title HyperNode Service Manager >> "%INSTALL_DIR%\service.bat"
echo echo ╔══════════════════════════════════════════════════════════════╗ >> "%INSTALL_DIR%\service.bat"
echo echo ║                HYPERNODE SERVICE MANAGER                     ║ >> "%INSTALL_DIR%\service.bat"
echo echo ╚══════════════════════════════════════════════════════════════╝ >> "%INSTALL_DIR%\service.bat"
echo echo. >> "%INSTALL_DIR%\service.bat"
echo echo 1. Start HyperNode >> "%INSTALL_DIR%\service.bat"
echo echo 2. Stop HyperNode >> "%INSTALL_DIR%\service.bat"
echo echo 3. Restart HyperNode >> "%INSTALL_DIR%\service.bat"
echo echo 4. View logs >> "%INSTALL_DIR%\service.bat"
echo echo 5. Check status >> "%INSTALL_DIR%\service.bat"
echo echo 6. Update HyperNode >> "%INSTALL_DIR%\service.bat"
echo echo 7. Exit >> "%INSTALL_DIR%\service.bat"
echo echo. >> "%INSTALL_DIR%\service.bat"
echo set /p choice="Select option (1-7): " >> "%INSTALL_DIR%\service.bat"
echo if "%%choice%%"=="1" goto start_node >> "%INSTALL_DIR%\service.bat"
echo if "%%choice%%"=="2" goto stop_node >> "%INSTALL_DIR%\service.bat"
echo if "%%choice%%"=="3" goto restart_node >> "%INSTALL_DIR%\service.bat"
echo if "%%choice%%"=="4" goto view_logs >> "%INSTALL_DIR%\service.bat"
echo if "%%choice%%"=="5" goto check_status >> "%INSTALL_DIR%\service.bat"
echo if "%%choice%%"=="6" goto update_node >> "%INSTALL_DIR%\service.bat"
echo if "%%choice%%"=="7" exit /b 0 >> "%INSTALL_DIR%\service.bat"
echo echo Invalid choice >> "%INSTALL_DIR%\service.bat"
echo pause >> "%INSTALL_DIR%\service.bat"
echo exit /b 1 >> "%INSTALL_DIR%\service.bat"
echo :start_node >> "%INSTALL_DIR%\service.bat"
echo start "HyperNode Complete" /B "%%~dp0\start.bat" >> "%INSTALL_DIR%\service.bat"
echo echo Node started >> "%INSTALL_DIR%\service.bat"
echo pause >> "%INSTALL_DIR%\service.bat"
echo exit /b 0 >> "%INSTALL_DIR%\service.bat"
echo :stop_node >> "%INSTALL_DIR%\service.bat"
echo taskkill /F /FI "WINDOWTITLE eq HyperNode Complete*" 2^>nul >> "%INSTALL_DIR%\service.bat"
echo echo Node stopped >> "%INSTALL_DIR%\service.bat"
echo pause >> "%INSTALL_DIR%\service.bat"
echo exit /b 0 >> "%INSTALL_DIR%\service.bat"
echo   ✅ service.bat created

:: ==================== STEP 7: CREATE CONFIGURATION ====================
echo.
echo [7/8] Creating Configuration
echo =============================
echo.

echo   Creating default configuration...
echo { > "%INSTALL_DIR%\config.json"
echo   "version": "2.0.0", >> "%INSTALL_DIR%\config.json"
echo   "node_id": "AUTO_GENERATED", >> "%INSTALL_DIR%\config.json"
echo   "mqtt_broker": "broker.emqx.io", >> "%INSTALL_DIR%\config.json"
echo   "mqtt_port": 1883, >> "%INSTALL_DIR%\config.json"
echo   "auto_update": true, >> "%INSTALL_DIR%\config.json"
echo   "heartbeat_interval": 30, >> "%INSTALL_DIR%\config.json"
echo   "log_level": "INFO", >> "%INSTALL_DIR%\config.json"
echo   "features": { >> "%INSTALL_DIR%\config.json"
echo     "real_time_monitoring": true, >> "%INSTALL_DIR%\config.json"
echo     "hardware_info": true, >> "%INSTALL_DIR%\config.json"
echo     "remote_execution": true, >> "%INSTALL_DIR%\config.json"
echo     "file_transfer": true, >> "%INSTALL_DIR%\config.json"
echo     "auto_update": true, >> "%INSTALL_DIR%\config.json"
echo     "plugin_system": true, >> "%INSTALL_DIR%\config.json"
echo     "web_interface": false, >> "%INSTALL_DIR%\config.json"
echo     "encryption": true, >> "%INSTALL_DIR%\config.json"
echo     "backup_restore": true, >> "%INSTALL_DIR%\config.json"
echo     "scheduled_tasks": true >> "%INSTALL_DIR%\config.json"
echo   } >> "%INSTALL_DIR%\config.json"
echo } >> "%INSTALL_DIR%\config.json"
echo   ✅ config.json created

:: Create version file
echo 2.0.0 > "%INSTALL_DIR%\VERSION"
echo   ✅ VERSION file created

:: ==================== STEP 8: INSTALLATION COMPLETE ====================
echo.
echo [8/8] Installation Complete
echo ============================
echo.

echo ╔══════════════════════════════════════════════════════════════╗
echo ║                    INSTALLATION COMPLETE                     ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo 📁 Installation Directory: %INSTALL_DIR%
echo.
echo 🚀 Startup Options:
echo   1. Batch file:    %INSTALL_DIR%\start.bat
echo   2. PowerShell:    %INSTALL_DIR%\start.ps1
echo   3. Service mode:  %INSTALL_DIR%\service.bat
echo   4. Direct run:    cd %INSTALL_DIR% && python hypernode_complete.py
echo.
echo 🔧 Features Installed:
echo   • Real-time monitoring and heartbeat
echo   • Hardware information collection
echo   • Remote command execution (safe)
echo   • File operations (list, read, write)
echo   • Process and service management
echo   • Auto-update system
echo   • Plugin system support
echo   • Configuration management
echo   • Logging and rotation
echo   • Backup and restore
echo   • Scheduled tasks
echo   • Security controls
echo.
echo 📊 System Requirements Check:
echo   ✅ Windows 7/8/10/11
echo   ✅ Python 3.8+
echo   ✅ Internet connection (for MQTT)
echo   ✅ 100MB disk space
echo.
echo 🔗 MQTT Brokers Configured:
echo   • broker.emqx.io:1883 (Primary)
echo   • test.mosquitto.org:1883 (Backup)
echo   • mqtt.eclipseprojects.io:1883 (Backup)
echo.
echo ⚠️  Important Notes:
echo   • Firewall may need to allow outgoing connections on port 1883
echo   • Some features require administrator privileges
echo   • Auto-update checks GitHub hourly
echo   • Logs are rotated every 7 days
echo.
echo ============================================
echo.

:: Ask to start now
set /p START_NOW="Start HyperNode Complete now? (Y/N): "
if /i "%START_NOW%"=="Y" (
    echo.
    echo ╔══════════════════════════════════════════════════════════════╗
    echo ║                    STARTING HYPERNODE                        ║
    echo ╚══════════════════════════════════════════════════════════════╝
    echo.
    cd /d "%INSTALL_DIR%"
    start.bat
) else (
    echo.
    echo 💡 You can start later by running:
    echo   %INSTALL_DIR%\start.bat
    echo.
    echo 📚 Documentation: https://github.com/fguod/hypernode-global
    echo.
    pause
)

exit /b 0

:: ==================== ERROR HANDLING ====================
:error
echo.
echo ❌ Installation failed at step: %ERROR_STEP%
echo Please check the error messages above.
echo.
echo 💡 Troubleshooting:
echo   1. Ensure Python is installed and in PATH
echo   2. Check internet connection
echo   3. Run as administrator if permission issues
echo   4. Check firewall settings
echo.
echo 🔗 Support: https://github.com/fguod/hypernode-global/issues
echo.
pause
exit /b 1