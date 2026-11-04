@echo off
setlocal

echo =====================================================================
echo  Starting Firebase Local Emulator Suite
echo =====================================================================
echo.

if exist "C:\Program Files\Android\Android Studio\jbr\bin\java.exe" (
    set "JAVA_HOME=C:\Program Files\Android\Android Studio\jbr"
    set "PATH=C:\Program Files\Android\Android Studio\jbr\bin;%PATH%"
)

cd /d "%~dp0campus_connect_admin"

echo [*] Starting emulators with persistent data from ./emulator-data...
echo [*] UI will be available at: http://127.0.0.1:4000
echo.

call firebase.cmd emulators:start --import=./emulator-data --export-on-exit=./emulator-data
