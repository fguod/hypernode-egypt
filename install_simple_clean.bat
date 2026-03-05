@echo off
echo HyperNode Installer
echo ===================
echo.

:: Check Python
echo Checking Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo Python not found
    echo Please install Python 3.8+ from: https://www.python.org/downloads/
    pause
    exit /b 1
)

:: Create directory
echo Creating directory...
set "DIR=%USERPROFILE%\.hypernode"
if not exist "%DIR%" mkdir "%DIR%"
cd /d "%DIR%"

:: Download program
echo Downloading program...
set "URL=https://raw.githubusercontent.com/fguod/hypernode-global/main/hypernode_complete.py"
set "FILE=hypernode.py"

bitsadmin /transfer node /download "%URL%" "%FILE%" >nul 2>&1
if not exist "%FILE%" (
    certutil -urlcache -split -f "%URL%" "%FILE%" >nul 2>&1
)

if not exist "%FILE%" (
    echo Download failed
    echo Please download manually: %URL%
    pause
    exit /b 1
)

:: Install dependencies
echo Installing dependencies...
python -m pip install paho-mqtt --quiet >nul 2>&1
if errorlevel 1 (
    python -m pip install paho-mqtt --user --quiet >nul 2>&1
)

:: Create start script
echo Creating start script...
echo @echo off > start.bat
echo cd /d "%%~dp0" >> start.bat
echo python hypernode.py >> start.bat
echo pause >> start.bat

:: Done
echo.
echo Installation complete!
echo.
echo Directory: %DIR%
echo To start: cd %DIR%
echo Then run: python hypernode.py
echo.
echo Or run: start.bat
echo.
pause