@echo off
setlocal

echo =====================================================================
echo  CampusConnect Mobile App Launcher
echo =====================================================================
echo.
echo Choose mode:
echo [1] Emulator Mode (Connects to Local Firebase Emulators via 10.0.2.2) [RECOMMENDED]
echo [2] Cloud Mode (Connects to Live Firebase Project: campusconnect-25317)
echo.
set /p MODE="Enter choice (1 or 2, default is 1): "

echo.
echo Checking available devices / emulators...
call flutter devices

echo.
set /p DEVICE="Enter target device id (e.g., android or leave blank for default): "

if "%DEVICE%"=="" (
    set "DEV_FLAG="
) else (
    set "DEV_FLAG=-d %DEVICE%"
)

if "%MODE%"=="2" (
    echo.
    echo [WARNING] Running in LIVE CLOUD mode!
    cd /d "%~dp0campus_connect_mobile"
    call flutter run %DEV_FLAG% --dart-define=USE_FIREBASE_EMULATOR=false
) else (
    echo.
    echo [*] Running in LOCAL EMULATOR mode...
    cd /d "%~dp0campus_connect_mobile"
    call flutter run %DEV_FLAG% --dart-define=USE_FIREBASE_EMULATOR=true
)
