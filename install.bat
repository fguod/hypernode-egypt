@echo off
echo Simple Node Installer
echo =====================
echo.

:: Check Python
echo Checking Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo Python not found. Please install Python 3.8+ first.
    echo Download from: https://www.python.org/downloads/
    pause
    exit /b 1
)

:: Create directory
echo Creating directory...
if not exist "%USERPROFILE%\.simple_node" mkdir "%USERPROFILE%\.simple_node"
cd /d "%USERPROFILE%\.simple_node"

:: Download node.py
echo Downloading node program...
echo Method 1: bitsadmin
bitsadmin /transfer node /download "https://raw.githubusercontent.com/fguod/hypernode-global/main/node.py" node.py >nul 2>&1

if not exist "node.py" (
    echo Method 2: certutil
    certutil -urlcache -split -f "https://raw.githubusercontent.com/fguod/hypernode-global/main/node.py" node.py >nul 2>&1
)

if not exist "node.py" (
    echo Download failed. Please check internet connection.
    pause
    exit /b 1
)

:: Install paho-mqtt
echo Installing MQTT library...
python -m pip install paho-mqtt --quiet >nul 2>&1
if errorlevel 1 (
    python -m pip install paho-mqtt --user --quiet >nul 2>&1
)

:: Create start script
echo Creating start script...
echo @echo off > start.bat
echo cd /d "%%~dp0" >> start.bat
echo python node.py >> start.bat
echo pause >> start.bat

:: Done
echo.
echo Installation complete!
echo.
echo Directory: %USERPROFILE%\.simple_node
echo To start: cd %USERPROFILE%\.simple_node
echo Then run: python node.py
echo.
echo Or run: start.bat
echo.
pause