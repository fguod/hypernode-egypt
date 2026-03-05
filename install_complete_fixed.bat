@echo off
chcp 65001 >nul
title HyperNode Complete Installer

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
    
    :: Try winget
    winget install Python.Python.3.11 --silent --accept-package-agreements >nul 2>&1
    if %errorlevel% neq 0 (
        echo Downloading Python...
        bitsadmin /transfer python_install /download "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe" python_setup.exe >nul 2>&1
        if exist python_setup.exe (
            echo Installing...
            start /wait python_setup.exe /quiet InstallAllUsers=1 PrependPath=1
            del python_setup.exe
        )
    )
    
    python --version >nul 2>&1
    if %errorlevel% neq 0 (
        echo Python installation failed
        echo Please install manually from: https://www.python.org/downloads/
        pause
        exit /b 1
    )
    echo Python installed
)

echo.

:: Step 3: Create directory
echo [3/8] Create Directory
echo.
set "INSTALL_DIR=%USERPROFILE%\.hypernode_complete"
echo Directory: %INSTALL_DIR%

if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%"
    echo Created
)

cd /d "%INSTALL_DIR%"

if not exist "logs" mkdir "logs"
if not exist "data" mkdir "data"
if not exist "plugins" mkdir "plugins"
if not exist "backups" mkdir "backups"

echo Directory ready
echo.

:: Step 4: Download main program
echo [4/8] Download Program
echo.
set "URL=https://raw.githubusercontent.com/fguod/hypernode-global/main/hypernode_complete.py"
set "FILE=hypernode_complete.py"

echo Downloading: %URL%
echo.

:: Try multiple download methods
bitsadmin /transfer hypernode /download "%URL%" "%FILE%" >nul 2>&1
if not exist "%FILE%" (
    certutil -urlcache -split -f "%URL%" "%FILE%" >nul 2>&1
)

if not exist "%FILE%" (
    powershell -Command "(New-Object Net.WebClient).DownloadFile('%URL%', '%FILE%')" >nul 2>&1
)

if not exist "%FILE%" (
    echo Download failed
    echo Please download manually: %URL%
    pause
    exit /b 1
)

echo Download successful
echo.

:: Step 5: Install dependencies
echo [5/8] Install Dependencies
echo.

echo Installing paho-mqtt...
python -m pip install paho-mqtt --quiet >nul 2>&1
if %errorlevel% neq 0 (
    python -m pip install paho-mqtt --user --quiet >nul 2>&1
)

echo Installing psutil...
python -m pip install psutil --quiet >nul 2>&1
if %errorlevel% neq 0 (
    python -m pip install psutil --user --quiet >nul 2>&1
)

echo Installing requests...
python -m pip install requests --quiet >nul 2>&1
if %errorlevel% neq 0 (
    python -m pip install requests --user --quiet >nul 2>&1
)

echo Dependencies installed
echo.

:: Step 6: Create startup scripts
echo [6/8] Create Startup Scripts
echo.

:: Create start.bat
echo @echo off > start.bat
echo chcp 65001 ^>nul >> start.bat
echo cd /d "%%~dp0" >> start.bat
echo python hypernode_complete.py >> start.bat
echo pause >> start.bat

echo start.bat created

:: Create service.bat
echo @echo off > service.bat
echo echo HyperNode Service Manager >> service.bat
echo echo 1. Start >> service.bat
echo echo 2. Stop >> service.bat
echo echo 3. Restart >> service.bat
echo echo 4. Exit >> service.bat
echo set /p choice="Choice: " >> service.bat
echo if "%%choice%%"=="1" goto start >> service.bat
echo if "%%choice%%"=="2" goto stop >> service.bat
echo if "%%choice%%"=="3" goto restart >> service.bat
echo if "%%choice%%"=="4" exit /b 0 >> service.bat
echo :start >> service.bat
echo start "HyperNode" /B "%%~dp0\start.bat" >> service.bat
echo echo Started >> service.bat
echo pause >> service.bat
echo exit /b 0 >> service.bat
echo :stop >> service.bat
echo taskkill /F /FI "WINDOWTITLE eq HyperNode*" 2^>nul >> service.bat
echo echo Stopped >> service.bat
echo pause >> service.bat
echo exit /b 0 >> service.bat
echo :restart >> service.bat
echo taskkill /F /FI "WINDOWTITLE eq HyperNode*" 2^>nul >> service.bat
echo timeout /t 2 /nobreak ^>nul >> service.bat
echo start "HyperNode" /B "%%~dp0\start.bat" >> service.bat
echo echo Restarted >> service.bat
echo pause >> service.bat
echo exit /b 0 >> service.bat

echo service.bat created
echo.

:: Step 7: Create config
echo [7/8] Create Configuration
echo.

echo { > config.json
echo   "version": "2.0.0", >> config.json
echo   "mqtt_broker": "broker.emqx.io", >> config.json
echo   "mqtt_port": 1883, >> config.json
echo   "auto_update": true, >> config.json
echo   "log_level": "INFO" >> config.json
echo } >> config.json

echo 2.0.0 > VERSION

echo Configuration created
echo.

:: Step 8: Installation complete
echo [8/8] Installation Complete
echo.
echo ========================================
echo Installation Successful!
echo ========================================
echo.
echo Directory: %INSTALL_DIR%
echo.
echo To start:
echo   %INSTALL_DIR%\start.bat
echo.
echo Or:
echo   cd %INSTALL_DIR%
echo   python hypernode_complete.py
echo.
echo Features:
echo   - Real-time monitoring
echo   - Remote command execution
echo   - File operations
echo   - Process management
echo   - Auto-update
echo   - Plugin system
echo   - Backup and restore
echo.
echo ========================================
echo.

set /p START_NOW="Start now? (Y/N): "
if /i "%START_NOW%"=="Y" (
    echo.
    echo Starting HyperNode...
    echo.
    start.bat
) else (
    echo.
    echo You can start later with: %INSTALL_DIR%\start.bat
    echo.
    pause
)

exit /b 0