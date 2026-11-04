# CampusConnect — Windows Setup & Run Guide

This document describes the complete procedure for setting up, configuring, and running CampusConnect on a Windows development laptop.

---

## Architecture Overview

CampusConnect consists of three components:
1. **`campus_connect_mobile`**: Flutter client application for students/faculty (Android / iOS / Desktop).
2. **`campus_connect_admin`**: Flutter client dashboard for administrative operations (Web / Chrome).
3. **`backend`**: Firebase Cloud Functions (TypeScript), Firestore rules, and Storage rules.

### Runtime Modes
* **Emulator Mode (`USE_FIREBASE_EMULATOR=true`)**:
  Connects both Flutter apps to the local Firebase Emulator Suite running Auth (9099), Firestore (8080), Functions (5001), and Storage (9199). Preloaded test data is preserved via `./emulator-data`.
* **Cloud Mode (`USE_FIREBASE_EMULATOR=false`)**:
  Connects directly to the live Firebase Cloud project `campusconnect-25317`.

---

## 1. Prerequisites Check

Open **PowerShell** or **Git Bash** and check the installed tool versions:

```bash
# 1. Flutter & Dart
flutter --version

# 2. Node.js (Version 20+ required, 22 recommended) & npm
node --version
npm --version

# 3. Git
git --version

# 4. Firebase CLI
firebase --version

# 5. Java Development Kit (JDK 21 or newer required for Firebase Emulators)
java -version
javac -version
```

### Java JDK 21+ Configuration
Firebase Emulator Suite requires Java version 21 or above. If your system defaults to Java 8, configure `JAVA_HOME` to point to a modern JDK (such as Android Studio's bundled OpenJDK / JetBrains Runtime):

In **PowerShell**:
```powershell
[Environment]::SetEnvironmentVariable('JAVA_HOME', 'C:\Program Files\Android\Android Studio\jbr', 'User')
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if ($userPath -notlike '*Android Studio\jbr\bin*') {
  [Environment]::SetEnvironmentVariable('Path', "C:\Program Files\Android\Android Studio\jbr\bin;$userPath", 'User')
}
```

In **Command Prompt (current session)**:
```cmd
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
set PATH=%JAVA_HOME%\bin;%PATH%
```

---

## 2. Cloning the Repository

From **Git Bash**:
```bash
cd /c
git clone <repository_url> CampusConnect
cd CampusConnect
```

---

## 3. Install Project Dependencies

Run the dependency installations using the existing lockfiles:

### A. Backend Functions
```bash
cd backend/functions
npm ci
npm run build
cd ../..
```

### B. Admin Flutter Application
```bash
cd campus_connect_admin
flutter pub get
cd ..
```

### C. Mobile Flutter Application
```bash
cd campus_connect_mobile
flutter pub get
cd ..
```

*(Alternatively, run the automated setup script: `setup_windows.cmd` from the root directory).*

---

## 4. Local Environment Configuration

> ⚠️ **SECURITY WARNING**:
> - Never commit `.env` or `.env.local` files to Git.
> - Never paste real API keys or passwords into chat prompts, public logs, or issue trackers.
> - `.gitignore` is already configured to ignore `.env*` files.

### Backend Functions (`backend/functions/.env`)

Copy the template to create your local `.env`:
```bash
cp backend/functions/.env.example backend/functions/.env
```

Open `backend/functions/.env` and configure the values:

```env
# ── Email Service Configuration ──────────────────────────────────────────────
# For local emulator testing without sending real emails:
SMTP_HOST=mock
SMTP_PORT=587
SMTP_USER=test@campusconnect.local
SMTP_PASSWORD=dummy_password
EMAIL_FROM=CampusConnect Administration <admin@campusconnect.local>

# ── For Real Gmail Delivery (Optional / Human Step) ──────────────────────────
# 1. Enable 2-Step Verification on your Google Account.
# 2. Generate an App Password at: https://myaccount.google.com/apppasswords
# 3. Fill in:
# SMTP_HOST=smtp.gmail.com
# SMTP_PORT=587
# SMTP_USER=your-email@gmail.com
# SMTP_PASSWORD=your-16-char-app-password
# EMAIL_FROM=CampusConnect Administration <your-email@gmail.com>

# ── Gemini API Key (Optional for Duplicate Detection) ────────────────────────
# Used by complaint_service.ts for semantic duplicate analysis.
# If omitted or invalid, the backend automatically falls back to keyword matching.
# To obtain a key: visit https://aistudio.google.com/app/apikey
GEMINI_API_KEY=your_gemini_api_key_here
```

---

## 5. Firebase CLI Authentication & Project Selection

Log in to Firebase CLI:
```cmd
firebase login
```
*(A browser window will open asking for authentication).*

Verify the active project:
```cmd
cd campus_connect_admin
firebase use
```
Ensure it points to `default (campusconnect-25317)`. **Do not run `firebase deploy`**.

---

## 6. Running in Local Emulator Mode (Recommended for Development)

### Step 1: Start the Firebase Emulator Suite
The Firebase emulators must be run from `campus_connect_admin` so that initial seed data is loaded and exported on exit:

In **Command Prompt**:
```cmd
cd campus_connect_admin
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
set PATH=%JAVA_HOME%\bin;%PATH%
firebase.cmd emulators:start --import=./emulator-data --export-on-exit=./emulator-data
```

In **PowerShell**:
```powershell
cd campus_connect_admin
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:Path = "$env:JAVA_HOME\bin;" + $env:Path
firebase.cmd emulators:start --import=./emulator-data --export-on-exit=./emulator-data
```

Once running, the Emulator UI will be available at:
👉 **http://127.0.0.1:4000**

* Auth Emulator: `127.0.0.1:9099`
* Firestore Emulator: `127.0.0.1:8080`
* Functions Emulator: `127.0.0.1:5001`
* Storage Emulator: `127.0.0.1:9199`

---

### Step 2: Run the Admin Web Application

Open a new terminal window:
```cmd
cd campus_connect_admin
flutter run -d chrome --dart-define=USE_FIREBASE_EMULATOR=true
```

---

### Step 3: Run the Mobile Application

1. Start your Android Emulator via Android Studio or command line:
   ```cmd
   flutter emulators --launch Pixel_6a
   ```
2. Once the emulator boots, run the app in emulator mode:
   ```cmd
   cd campus_connect_mobile
   flutter run -d android --dart-define=USE_FIREBASE_EMULATOR=true
   ```

*(The mobile app automatically connects to `10.0.2.2` to communicate with the host machine's Firebase emulator).*

---

## 7. Running in Cloud Mode (Live Project)

> ⚠️ **CAUTION**: Cloud mode connects to live production/staging databases and triggers live Cloud Functions.

* **Admin Web**:
  ```cmd
  cd campus_connect_admin
  flutter run -d chrome --dart-define=USE_FIREBASE_EMULATOR=false
  ```
* **Mobile App**:
  ```cmd
  cd campus_connect_mobile
  flutter run -d android --dart-define=USE_FIREBASE_EMULATOR=false
  ```

---

## 8. Basic Verification & Functional Tests

When running in Emulator Mode:

1. **Authentication & Login**:
   - Check the Auth Emulator UI at `http://127.0.0.1:4000/auth` to inspect pre-seeded users.
   - Log in to the Admin Dashboard or Mobile App using a seeded account.
2. **User Creation & Email**:
   - Create a new member account via Admin Dashboard.
   - If `SMTP_HOST=mock`, verify the Functions terminal logs:
     `[email_service] MOCK – welcome email accepted by mock server...`
   - If real SMTP credentials are used, verify email reception in the destination inbox.
3. **Complaint Submission & Tracking**:
   - From the mobile app, submit a complaint with a title, description, and location.
   - Verify that the complaint appears in Firestore (`http://127.0.0.1:4000/firestore`) in the `ISSUES` collection.
   - Update the status in the Admin dashboard and verify real-time status changes in the mobile app.
4. **Event Management**:
   - In the Admin Dashboard, create an Event with an image poster.
   - Verify that the poster uploads to Storage (`http://127.0.0.1:4000/storage`) and appears in the Mobile App feed.

---

## 9. Troubleshooting

### Port Conflicts
If a message indicates that ports `8080`, `9099`, `5001`, `9199`, or `4000` are in use:
```cmd
netstat -ano | findstr :8080
taskkill /PID <PID> /F
```

### Execution Policy Restrictions in PowerShell
If PowerShell blocks running `npm.ps1` or `firebase.ps1`:
- Use `firebase.cmd` and `npm.cmd` instead of calling `.ps1` files.
- Or set execution policy for the current user:
  ```powershell
  Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
  ```

### Emulator Data Lock
If the emulator fails to start due to a lock file:
- Check `campus_connect_admin/firestore-debug.log` or terminate any hanging Java processes:
  ```cmd
  taskkill /IM java.exe /F
  ```
