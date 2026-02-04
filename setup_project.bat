@echo off
setlocal

echo 📚 Setup documentation (Sphinx)...

set VENV_DIR=.venv
set URL=http://127.0.0.1:9000

REM Check python
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Python not found. Please install Python.
    exit /b 1
)

REM Create venv if not exists
if not exist "%VENV_DIR%" (
    echo 📦 Creating virtual environment...
    python -m venv "%VENV_DIR%"
) else (
    echo 📦 Virtual environment already exists.
)

REM Activate venv
echo 🚀 Activating virtual environment...
call "%VENV_DIR%\Scripts\activate.bat"

REM Update pip
echo ⬆️ Updating pip...
python -m pip install --upgrade pip

REM Install dependencies
if exist "requirements.txt" (
    echo 📚 Installing dependencies...
    pip install -r requirements.txt
) else (
    echo ❌ requirements.txt not found. Please clone the project again.
    exit /b 1
)

REM Open browser after short delay
echo 🌐 Opening documentation in browser...
start "" cmd /c "timeout /t 2 >nul && start %URL%"

REM Run autobuild
echo 🔁 Running sphinx-autobuild...
sphinx-autobuild ./ ./build/ --port 9000

endlocal
