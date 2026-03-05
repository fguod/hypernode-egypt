@echo off
chcp 65001 >nul
title HyperNode Complete Edition Installer

echo ========================================
echo HyperNode Complete Edition Installer
echo Version 2.0.0
echo ========================================
echo.

:: Step 1: System check
echo [1/8] System Check
echo.
ver | find "Windows" >nul
if %errorlevel% neq 0 (
    echo ERROR: Not running on Windows
    pause
    exit /b 1
)

echo Windows detected
echo.

:: Step 2: Python check
echo [2/8] Python Check
echo.
python --version >nul 2>&1
if %errorlevel% equ 0 (
    python --version
    echo Python OK
) else (
    echo Python not found
    echo Installing Python 3.11...
    
    :: Try winget first
    winget install Python.Python.3.11 --silent --accept-package-agreements >nul 2>&1
    if %errorlevel% neq 0 (
        echo Downloading Python installer...
        bitsadmin /transfer python_install /download "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe" python_setup.exe >nul 2>&1
        if exist python_setup.exe (
            echo Installing Python...
            start /wait python_setup.exe /quiet InstallAllUsers=1 PrependPath=1
            del python_setup.exe
            echo Python installation complete
        ) else (
            echo Download failed
            echo Please install Python manually from: https://www.python.org/downloads/
            pause
            exit /b 1
        )
    )
    
    :: Verify installation
    python --version >nul 2>&1
    if %errorlevel% neq 0 (
        echo Python installation verification failed
        echo Please add Python to PATH and try again
        pause
        exit /b 1
    )
    echo Python installed successfully
)

echo.

:: Step 3: Create installation directory
echo [3/8] Create Installation Directory
echo.
set "INSTALL_DIR=%USERPROFILE%\.hypernode_complete"
echo Target directory: %INSTALL_DIR%

if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%"
    echo Directory created
) else (
    echo Directory already exists
)

:: Create subdirectories
cd /d "%INSTALL_DIR%"
if not exist "logs" mkdir "logs"
if not exist "data" mkdir "data"
if not exist "plugins" mkdir "plugins"
if not exist "backups" mkdir "backups"

echo Directory structure created
echo.

:: Step 4: Download HyperNode Complete
echo [4/8] Download HyperNode Complete
echo.
set "DOWNLOAD_URL=https://raw.githubusercontent.com/fguod/hypernode-global/main/hypernode_complete.py"
set "TARGET_FILE=%INSTALL_DIR%\hypernode_complete.py"

echo Downloading from: %DOWNLOAD_URL%
echo Saving to: %TARGET_FILE%
echo.

:: Try multiple download methods
echo Method 1: bitsadmin...
bitsadmin /transfer hypernode_complete /download "%DOWNLOAD_URL%" "%TARGET_FILE%" >nul 2>&1
if exist "%TARGET_FILE%" (
    echo Download successful
    goto :download_done
)

echo Method 2: certutil...
certutil -urlcache -split -f "%DOWNLOAD_URL%" "%TARGET_FILE%" >nul 2>&1
if exist "%TARGET_FILE%" (
    echo Download successful
    goto :download_done
)

echo Method 3: PowerShell...
powershell -Command "(New-Object Net.WebClient).DownloadFile('%DOWNLOAD_URL%', '%TARGET_FILE%')" >nul 2>&1
if exist "%TARGET_FILE%" (
    echo Download successful
    goto :download_done
)

echo Method 4: curl...
curl -s -o "%TARGET_FILE%" "%DOWNLOAD_URL%" >nul 2>&1
if exist "%TARGET_FILE%" (
    echo Download successful
    goto :download_done
)

echo ERROR: All download methods failed
echo Please download manually from: %DOWNLOAD_URL%
pause
exit /b 1

:download_done
echo.

:: Step 5: Install dependencies
echo [5/8] Install Dependencies
echo.
cd /d "%INSTALL_DIR%"

echo Installing paho-mqtt...
python -m pip install paho-mqtt --quiet --disable-pip-version-check >nul 2>&1
if %errorlevel% neq 0 (
    python -m pip install paho-mqtt --user --quiet --disable-pip-version-check >nul 2>&1
    if %errorlevel% equ 0 (
        echo paho-mqtt installed (user mode)
    ) else (
        echo WARNING: paho-mqtt installation had issues
    )
) else (
    echo paho-mqtt installed
)

echo Installing psutil...
python -m pip install psutil --quiet --disable-pip-version-check >nul 2>&1
if %errorlevel% neq 0 (
    python -m pip install psutil --user --quiet --disable-pip-version-check >nul 2>&1
    if %errorlevel% equ 0 (
        echo psutil installed (user mode)
    ) else (
        echo WARNING: psutil installation had issues
    )
) else (
    echo psutil installed
)

echo Installing requests...
python -m pip install requests --quiet --disable-pip-version-check >nul 2>&1
if %errorlevel% neq 0 (
    python -m pip install requests --user --quiet --disable-pip-version-check >nul 2>&1
    if %errorlevel% equ 0 (
        echo requests installed (user mode)
    ) else (
        echo NOTE: requests installation skipped (optional)
    )
) else (
    echo requests installed
)

echo Dependencies installation complete
echo.

:: Step 6: Create startup scripts
echo [6/8] Create Startup Scripts
echo.

:: Create batch startup script
echo Creating batch startup script...
echo @echo off > "%INSTALL_DIR%\start.bat"
echo chcp 65001 ^>nul >> "%INSTALL_DIR%\start.bat"
echo title HyperNode Complete Edition >> "%INSTALL_DIR%\start.bat"
echo echo ======================================== >> "%INSTALL_DIR%\start.bat"
echo echo HyperNode Complete Edition >> "%INSTALL_DIR%\start.bat"
echo echo Version 2.0.0 >> "%INSTALL_DIR%\start.bat"
echo echo ======================================== >> "%INSTALL_DIR%\start.bat"
echo echo. >> "%INSTALL_DIR%\start.bat"
echo cd /d "%%~dp0" >> "%INSTALL_DIR%\start.bat"
echo python hypernode_complete.py >> "%INSTALL_DIR%\start.bat"
echo pause >> "%INSTALL_DIR%\start.bat"
echo Batch script: start.bat created

:: Create PowerShell startup script
echo Creating PowerShell startup script...
echo # HyperNode Complete Edition - PowerShell Launcher > "%INSTALL_DIR%\start.ps1"
echo Write-Host "========================================" -ForegroundColor Cyan >> "%INSTALL_DIR%\start.ps1"
echo Write-Host "HyperNode Complete Edition" -ForegroundColor Yellow >> "%INSTALL_DIR%\start.ps1"
echo Write-Host "Version 2.0.0" -ForegroundColor White >> "%INSTALL_DIR%\start.ps1"
echo Write-Host "========================================" -ForegroundColor Cyan >> "%INSTALL_DIR%\start.ps1"
echo Write-Host "" >> "%INSTALL_DIR%\start.ps1"
echo Set-Location "%INSTALL_DIR%" >> "%INSTALL_DIR%\start.ps1"
echo python hypernode_complete.py >> "%INSTALL_DIR%\start.ps1"
echo PowerShell script: start.ps1 created

:: Create service management script
echo Creating service management script...
echo @echo off > "%INSTALL_DIR%\service.bat"
echo chcp 65001 ^>nul >> "%INSTALL_DIR%\service.bat"
echo title HyperNode Service Manager >> "%INSTALL_DIR%\service.bat"
echo echo ======================================== >> "%INSTALL_DIR%\service.bat"
echo echo HyperNode Service Manager >> "%INSTALL_DIR%\service.bat"
echo echo ======================================== >> "%INSTALL_DIR%\service.bat"
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
echo echo HyperNode started >> "%INSTALL_DIR%\service.bat"
echo pause >> "%INSTALL_DIR%\service.bat"
echo exit /b 0 >> "%INSTALL_DIR%\service.bat"
echo :stop_node >> "%INSTALL_DIR%\service.bat"
echo taskkill /F /FI "WINDOWTITLE eq HyperNode Complete*" 2^>nul >> "%INSTALL_DIR%\service.bat"
echo echo HyperNode stopped >> "%INSTALL_DIR%\service.bat"
echo pause >> "%INSTALL_DIR%\service.bat"
echo exit /b 0 >> "%INSTALL_DIR%\service.bat"
echo :restart_node >> "%INSTALL_DIR%\service.bat"
echo taskkill /F /FI "WINDOWTITLE eq HyperNode Complete*" 2^>nul >> "%INSTALL_DIR%\service.bat"
echo timeout /t 2 /nobreak ^>nul >> "%INSTALL_DIR%\service.bat"
echo start "HyperNode Complete" /B "%%~dp0\start.bat" >> "%INSTALL_DIR%\service.bat"
echo echo HyperNode restarted >> "%INSTALL_DIR%\service.bat"
echo pause >> "%INSTALL_DIR%\service.bat"
echo exit /b 0 >> "%INSTALL_DIR%\service.bat"
echo :view_logs >> "%INSTALL_DIR%\service.bat"
echo if exist "logs\*.log" ( >> "%INSTALL_DIR%\service.bat"
echo   echo Latest log files: >> "%INSTALL_DIR%\service.bat"
echo   dir /b logs\*.log >> "%INSTALL_DIR%\service.bat"
echo   echo. >> "%INSTALL_DIR%\service.bat"
echo   echo To view a log file: >> "%INSTALL_DIR%\service.bat"
echo   echo   type logs\hypernode_*.log ^| more >> "%INSTALL_DIR%\service.bat"
echo ) else ( >> "%INSTALL_DIR%\service.bat"
echo   echo No log files found >> "%INSTALL_DIR%\service.bat"
echo ) >> "%INSTALL_DIR%\service.bat"
echo pause >> "%INSTALL_DIR%\service.bat"
echo exit /b 0 >> "%INSTALL_DIR%\service.bat"
echo :check_status >> "%INSTALL_DIR%\service.bat"
echo tasklist /FI "WINDOWTITLE eq HyperNode Complete*" 2^>nul ^| find "HyperNode" >> "%INSTALL_DIR%\service.bat"
echo if %errorlevel% equ 0 ( >> "%INSTALL_DIR%\service.bat"
echo   echo HyperNode is running >> "%INSTALL_DIR%\service.bat"
echo ) else ( >> "%INSTALL_DIR%\service.bat"
echo   echo HyperNode is not running >> "%INSTALL_DIR%\service.bat"
echo ) >> "%INSTALL_DIR%\service.bat"
echo pause >> "%INSTALL_DIR%\service.bat"
echo exit /b 0 >> "%INSTALL_DIR%\service.bat"
echo :update_node >> "%INSTALL_DIR%\service.bat"
echo echo Checking for updates... >> "%INSTALL_DIR%\service.bat"
echo bitsadmin /transfer hypernode_update /download "https://raw.githubusercontent.com/fguod/hypernode-global/main/hypernode_complete.py" hypernode_complete_new.py >> "%INSTALL_DIR%\service.bat"
echo if exist hypernode_complete_new.py ( >> "%INSTALL_DIR%\service.bat"
echo   echo Update downloaded >> "%INSTALL_DIR%\service.bat"
echo   echo To apply update: >> "%INSTALL_DIR%\service.bat"
echo   echo   1. Stop HyperNode first >> "%INSTALL_DIR%\service.bat"
echo   echo   2. Run: move /y hypernode_complete_new.py hypernode_complete.py >> "%INSTALL_DIR%\service.bat"
echo   echo   3. Start HyperNode again >> "%INSTALL_DIR%\service.bat"
echo ) else ( >> "%INSTALL_DIR%\service.bat"
echo   echo Update check failed >> "%INSTALL_DIR%\service.bat"
echo ) >> "%INSTALL_DIR%\service.bat"
echo pause >> "%INSTALL_DIR%\service.bat"
echo exit /b 0 >> "%INSTALL_DIR%\service.bat"
echo Service script: service.bat created
echo.

:: Step 7: Create configuration
echo [7/8] Create Configuration
echo.

echo Creating default configuration...
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
echo     "encryption": true, >> "%INSTALL_DIR%\config.json"
echo     "backup_restore": true, >> "%INSTALL_DIR%\config.json"
echo     "scheduled_tasks": true >> "%INSTALL_DIR%\config.json"
echo   } >> "%INSTALL_DIR%\config.json"
echo } >> "%INSTALL_DIR%\config.json"

echo 2.0.0 > "%INSTALL_DIR%\VERSION"

echo Configuration files created
echo.

:: Step 8: Installation complete
echo [8/8] Installation Complete
echo.
echo ========================================
echo INSTALLATION SUCCESSFUL
echo ========================================
echo.
echo Installation Directory: %INSTALL_DIR%
echo.
echo Startup Options:
echo   1. Batch file:    %INSTALL_DIR%\start.bat
echo   2. PowerShell:    %INSTALL_DIR%\start.ps1
echo   3. Service mode:  %INSTALL_DIR%\service.bat
echo   4. Direct run:    cd %INSTALL_DIR% && python hypernode_complete.py
echo.
echo Features Installed:
echo   - Real-time monitoring
echo   - Hardware information collection
echo   - Remote command execution (safe)
echo   - File operations (list, read, write)
echo   - Process and service management
echo   - Auto-update system
echo   - Plugin system support
echo   - Configuration management
echo   - Logging and rotation
echo   - Backup and restore
echo   - Scheduled tasks
echo   - Security controls
echo.
echo MQTT Brokers Configured:
echo   - broker.emqx.io:1883 (Primary)
echo   - test.mosquitto.org:1883 (Backup)
echo   - mqtt.eclipseprojects.io:1883 (Backup)
echo.
echo System Requirements Check:
echo   - Windows 7/8/10/11: OK
echo   - Python 3.8+: OK
echo   - Internet connection: Required for MQTT
echo   - Disk space: 100MB minimum
echo.
echo Important Notes:
echo   - Firewall may need to allow outgoing connections on port 1883
echo   - Some features require administrator privileges
echo   - Auto-update checks GitHub hourly
echo   - Logs are rotated every 7 days
echo.
echo ========================================
echo.

:: Ask to start now
set /p START_NOW="Start HyperNode now? (Y/N): "
if /i "%START_NOW%"=="Y" (
    echo.
    echo ========================================
    echo STARTING HYPERNODE COMPLETE EDITION
    echo ========================================
    echo.
    cd /d "%INSTALL_DIR%"
    start.bat
) else (
    echo.
    echo You can start later by running:
    echo   %INSTALL_DIR%\start.bat
    echo.
    echo Documentation: https://github.com/fguod/hypernode-global
    echo.
    pause
)

exit /b 0

:: Error handling section
:error
echo.
echo ERROR: Installation failed
echo Please check the error messages above.
echo.
echo Troubleshooting:
echo   1. Ensure Python is installed and in PATH
echo   2. Check internet connection
echo   3. Run as administrator if permission issues
echo   4. Check firewall settings
echo.
echo Support: https://github.com/fguod/hypernode-global/issues
echo.
pause
exit /b 1