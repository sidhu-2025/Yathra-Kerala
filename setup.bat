@echo off
setlocal

echo ==========================================
echo   Hostel Smart Leave - Setup Script
echo ==========================================

:: 1. Check for Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed or not in PATH.
    pause
    exit /b 1
)

:: 2. Setup Backend
echo.
echo [1/3] Setting up Backend Virtual Environment...
cd backend
if not exist venv (
    python -m venv venv
)
call .\venv\Scripts\activate

echo [2/3] Installing Dependencies...
pip install -r requirements.txt

:: 3. Check for MySQL and Migrate
echo.
echo [3/3] Attempting Database Migrations...
echo Note: This requires MySQL to be running and a database named 'hostel_db' to exist.
python manage.py migrate
if %errorlevel% neq 0 (
    echo.
    echo [WARNING] Migration failed. Please ensure:
    echo 1. MySQL Server is running.
    echo 2. Database 'hostel_db' is created.
    echo 3. Credentials in 'hostel_project/settings.py' are correct.
) else (
    echo [SUCCESS] Database migrations completed.
)

echo.
echo ==========================================
echo   Setup completed! 
echo   To start the backend, run: cd backend; .\venv\Scripts\activate; python manage.py runserver
echo   To run the app, ensure Flutter is installed and run: cd frontend; flutter run
echo ==========================================
pause
