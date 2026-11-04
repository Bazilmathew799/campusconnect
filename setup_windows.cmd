@echo off
setlocal enabledelayedexpansion

echo =====================================================================
echo  CampusConnect Windows Setup Helper
echo =====================================================================
echo.

echo [1/5] Checking Git...
where git >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Git is not found in PATH. Please install Git for Windows.
    exit /b 1
) else (
    echo [OK] Git is installed.
)

echo.
echo [2/5] Checking Node.js and npm...
where node >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Node.js is not found in PATH. Please install Node.js 20 or 22.
    exit /b 1
) else (
    for /f "tokens=*" %%v in ('node -v') do echo [OK] Node.js version: %%v
)

where npm >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] npm is not found in PATH.
    exit /b 1
) else (
    for /f "tokens=*" %%v in ('npm -v') do echo [OK] npm version: %%v
)

echo.
echo [3/5] Checking Flutter and Dart...
where flutter >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Flutter is not found in PATH. Please install Flutter SDK.
    exit /b 1
) else (
    echo [OK] Flutter is available.
)

echo.
echo [4/5] Checking Java version for Firebase Emulators...
set "FOUND_JDK="
if exist "C:\Program Files\Android\Android Studio\jbr\bin\java.exe" (
    set "JAVA_HOME=C:\Program Files\Android\Android Studio\jbr"
    set "PATH=C:\Program Files\Android\Android Studio\jbr\bin;%PATH%"
    set "FOUND_JDK=Android Studio JBR (JDK 21+)"
)

java -version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [WARNING] Java not found. Firebase Emulators require JDK 21+.
) else (
    echo [OK] Java environment configured using: %FOUND_JDK%
)

echo.
echo [5/5] Checking Firebase CLI...
where firebase >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [WARNING] Firebase CLI not found. You can install it via: npm install -g firebase-tools
) else (
    for /f "tokens=*" %%v in ('firebase --version') do echo [OK] Firebase CLI version: %%v
)

echo.
echo =====================================================================
echo  Installing Dependencies (using existing lockfiles)
echo =====================================================================

echo.
echo [*] Installing backend functions dependencies...
cd /d "%~dp0backend\functions"
call npm ci
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Backend npm ci failed.
    exit /b 1
)
echo [*] Building TypeScript functions...
call npm run build
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Backend build failed.
    exit /b 1
)

echo.
echo [*] Installing campus_connect_admin dependencies...
cd /d "%~dp0campus_connect_admin"
call flutter pub get
if %ERRORLEVEL% neq 0 (
    echo [ERROR] campus_connect_admin flutter pub get failed.
    exit /b 1
)

echo.
echo [*] Installing campus_connect_mobile dependencies...
cd /d "%~dp0campus_connect_mobile"
call flutter pub get
if %ERRORLEVEL% neq 0 (
    echo [ERROR] campus_connect_mobile flutter pub get failed.
    exit /b 1
)

cd /d "%~dp0"

echo.
echo =====================================================================
echo  Verifying Local Configuration
echo =====================================================================
if not exist "backend\functions\.env" (
    echo [INFO] Creating backend\functions\.env from .env.example (mock mode)
    copy "backend\functions\.env.example" "backend\functions\.env" >nul
    echo [IMPORTANT] Created backend\functions\.env. Default SMTP_HOST is set to mock.
    echo If you want real email sending or Gemini duplicate detection, edit backend\functions\.env.
) else (
    echo [OK] backend\functions\.env exists.
)

echo.
echo =====================================================================
echo  Setup Completed Successfully!
echo =====================================================================
echo.
echo Next steps:
echo 1. To start emulators: run_emulators.cmd
echo 2. To run admin dashboard: run_admin.cmd
echo 3. To run mobile app: run_mobile.cmd
echo.
pause
