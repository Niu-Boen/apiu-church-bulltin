@echo off
echo ========================================
echo APIU Bulletin Quick Start
echo ========================================
echo.

cd /d "c:\Study\2026-1st\android app\apiu bulletin\https---github.com-Niu-Boen-apiu-church-bulltin"

echo [1/3] Installing dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo Failed to install dependencies!
    pause
    exit /b 1
)

echo.
echo [2/3] Cleaning previous builds...
flutter clean

echo.
echo [3/3] Starting application...
echo.
echo ========================================
echo Application will start in a new window
echo Close the window to stop the app
echo ========================================
echo.
flutter run

pause
