@echo off
setlocal

echo =====================================================================
echo  CampusConnect Admin Dashboard Launcher
echo =====================================================================
echo.
echo Choose mode:
echo [1] Emulator Mode (Connects to Local Firebase Emulators) [RECOMMENDED]
echo [2] Cloud Mode (Connects to Live Firebase Project: campusconnect-25317)
echo.
set /p MODE="Enter choice (1 or 2, default is 1): "

if "%MODE%"=="2" (
    echo.
    echo [WARNING] Running in LIVE CLOUD mode!
    cd /d "%~dp0campus_connect_admin"
    call flutter run -d chrome --dart-define=USE_FIREBASE_EMULATOR=false
) else (
    echo.
    echo [*] Running in LOCAL EMULATOR mode...
    cd /d "%~dp0campus_connect_admin"
    call flutter run -d chrome --dart-define=USE_FIREBASE_EMULATOR=true
)
