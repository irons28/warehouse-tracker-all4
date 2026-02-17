@echo off
setlocal
cd /d "%~dp0"

if not exist "logs" mkdir "logs"

echo Starting Warehouse Tracker server...
start "WT Server" cmd /k "cd /d "%~dp0" && npm start"

timeout /t 2 /nobreak >nul

echo Starting Cloudflare tunnel...
start "WT Tunnel" cmd /k "cd /d "%~dp0" && npm run tunnel:cf"

echo.
echo Warehouse Tracker started.
echo Local URL: https://localhost:3443
if exist "logs\tunnel.log" (
  echo Check tunnel URL in logs\tunnel.log
) else (
  echo Use the WT Tunnel window to copy the trycloudflare URL.
)

echo.
echo To stop: run stop-tracker.bat
pause
