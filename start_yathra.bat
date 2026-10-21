@echo off
title Yathra Kerala - Launcher
cls
echo ================================================================
echo               YATHRA KERALA - SYSTEM LAUNCHER
echo ================================================================
echo.
echo  [1] Start Backend Only (Recommended if you already installed the APK)
echo  [2] Start Backend + Run Flutter Web (Chrome)
echo  [3] Start Backend + Run on Connected Android Device / Emulator
echo  [4] Install APK to connected USB Phone
echo  [5] Exit
echo.
set /p choice="Enter your choice (1, 2, 3, 4, or 5): "

if "%choice%"=="1" goto BACKEND_ONLY
if "%choice%"=="2" goto RUN_WEB
if "%choice%"=="3" goto RUN_ANDROID
if "%choice%"=="4" goto INSTALL_APK
if "%choice%"=="5" exit
goto INVALID

:BACKEND_ONLY
echo.
echo Starting FastAPI Backend on http://0.0.0.0:8000 ...
start "Yathra Kerala Backend" cmd /k "cd /d %~dp0 && python -m uvicorn backend_yathra.main:app --host 0.0.0.0 --port 8000 --reload"
echo.
echo Backend is running in a separate window!
echo You can now open the Yathra Kerala app on your phone.
pause
exit

:RUN_WEB
echo.
echo Starting FastAPI Backend ...
start "Yathra Kerala Backend" cmd /k "cd /d %~dp0 && python -m uvicorn backend_yathra.main:app --host 0.0.0.0 --port 8000 --reload"
timeout /t 3 >nul
echo.
echo Launching Flutter App on Chrome ...
start "Yathra Kerala Web" cmd /k "cd /d %~dp0yathra_kerala_app && flutter run -d chrome"
exit

:RUN_ANDROID
echo.
echo Starting FastAPI Backend ...
start "Yathra Kerala Backend" cmd /k "cd /d %~dp0 && python -m uvicorn backend_yathra.main:app --host 0.0.0.0 --port 8000 --reload"
timeout /t 3 >nul
echo.
echo Launching on Android ...
start "Yathra Kerala Android" cmd /k "cd /d %~dp0yathra_kerala_app && flutter run"
exit

:INSTALL_APK
echo.
echo Installing APK to connected phone via ADB...
adb install -r "%~dp0YathraKerala.apk"
echo.
pause
exit

:INVALID
echo Invalid choice. Exiting.
pause
exit
