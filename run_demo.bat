@echo off
echo ========================================================
echo   Starting YathraKerala Multi-Modal Journey Planner
echo ========================================================
echo.

echo 1. Starting Python FastAPI Backend on http://127.0.0.1:8000 ...
start "YathraKerala Backend" cmd /k "python -m uvicorn backend_yathra.main:app --host 0.0.0.0 --port 8000 --reload"

timeout /t 3 >nul

echo.
echo 2. Launching Flutter App (Chrome / Emulator) ...
cd yathra_kerala_app
start "YathraKerala App" cmd /k "flutter run -d chrome"

echo.
echo ========================================================
echo   Backend and App launched successfully!
echo   To launch on Android Emulator:
echo     flutter emulators --launch Medium_Phone_API_36.1
echo     flutter run -d android
echo ========================================================
