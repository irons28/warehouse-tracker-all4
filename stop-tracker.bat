@echo off
setlocal

echo Stopping Warehouse Tracker processes...

for /f "tokens=2 delims=," %%A in ('tasklist /v /fo csv ^| findstr /i "WT Server"') do taskkill /PID %%~A /F >nul 2>&1
for /f "tokens=2 delims=," %%A in ('tasklist /v /fo csv ^| findstr /i "WT Tunnel"') do taskkill /PID %%~A /F >nul 2>&1

echo If any window is still open, close it manually.
echo Done.
pause
