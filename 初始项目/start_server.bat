@echo off
chcp 65001 >nul

where wsl >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] WSL not found - please install WSL first
    pause
    exit /b 1
)

echo Starting MySQL and backend server...
echo.

wsl bash /tmp/testserver/start.sh

pause
