@echo off
echo ========================================
echo Testing Login Fix
echo ========================================
echo.

cd /d "c:\Study\2026-1st\android app\apiu bulletin\https---github.com-Niu-Boen-apiu-church-bulltin"

echo [1/3] Cleaning previous builds...
flutter clean

echo.
echo [2/3] Getting dependencies...
flutter pub get

echo.
echo [3/3] Running app with verbose logging...
echo.
echo ========================================
echo Use these credentials to test:
echo   Admin: admin / admin123
echo   Editor: editor / editor123
echo   Guest: Click "CONTINUE AS GUEST"
echo ========================================
echo.
echo Watch the console for debug output!
echo.
flutter run -v

pause
