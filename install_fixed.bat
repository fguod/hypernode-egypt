@echo off
echo Simple Node Installer
echo.
echo Step 1: Check Python
python --version
if errorlevel 1 (
    echo Python not found
    pause
    exit /b 1
)

echo.
echo Step 2: Create directory
if not exist "%USERPROFILE%\.simple_node" mkdir "%USERPROFILE%\.simple_node"
cd /d "%USERPROFILE%\.simple_node"

echo.
echo Step 3: Download node.py
bitsadmin /transfer node /download "https://raw.githubusercontent.com/fguod/hypernode-global/main/node.py" node.py

if not exist "node.py" (
    echo Download failed
    pause
    exit /b 1
)

echo.
echo Step 4: Install paho-mqtt
python -m pip install paho-mqtt

echo.
echo Step 5: Run node
python node.py

pause