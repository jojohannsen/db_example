@echo off
REM Simple setup and run script for db_example project
REM Run this from the db_example project directory

setlocal

REM Configuration
set ENV_NAME=db_example_env
set PROJECT_DIR=%cd%
set WORK_DIR=%cd%\db_example_work

echo === DB Example Setup and Run Script (Simple Version) ===
echo Current directory: %PROJECT_DIR%
echo.

echo Checking for required files...
if not exist "requirements.txt" (
    echo Error: requirements.txt not found in current directory
    echo Please run this script from the db_example project directory
    echo.
    pause
    exit /b 1
)

if not exist "runit.sh" (
    echo Error: runit.sh not found in current directory
    echo Please run this script from the db_example project directory
    echo.
    pause
    exit /b 1
)

echo Found required files: requirements.txt and runit.sh
echo.

echo Checking if Python is available...
python --version
if errorlevel 1 (
    echo Error: Python is not available
    echo Please install Python and add it to your PATH
    echo.
    pause
    exit /b 1
)

echo.
echo === Step 1: Installing requirements ===
echo Installing Python packages from requirements.txt...
pip install -r requirements.txt
if errorlevel 1 (
    echo Error: Failed to install requirements
    echo Make sure pip is available and working
    pause
    exit /b 1
)

echo.
echo === Step 2: Setting up working directory ===
if not exist "%WORK_DIR%" mkdir "%WORK_DIR%"
echo Working directory: %WORK_DIR%

echo.
echo === Step 3: Running the example ===

REM Check for API key
if "%ANTHROPIC_API_KEY%"=="" (
    echo Warning: ANTHROPIC_API_KEY environment variable is not set
    echo Please set it with: set ANTHROPIC_API_KEY=your-api-key-here
    echo.
    set /p CONTINUE="Do you want to continue anyway? (y/N): "
    if /i not "%CONTINUE%"=="y" (
        echo Exiting. Please set ANTHROPIC_API_KEY and run again.
        pause
        exit /b 1
    )
)

REM Run the example
cd /d "%WORK_DIR%"
echo Running from: %cd%

REM Try to run with bash (Git Bash, WSL, etc.)
where bash >nul 2>&1
if not errorlevel 1 (
    echo Found bash, running runit.sh...
    bash "%PROJECT_DIR%\runit.sh"
) else (
    echo bash not found. Trying to run Python script directly...
    if exist "%PROJECT_DIR%\chat_with_data.py" (
        python "%PROJECT_DIR%\chat_with_data.py"
    ) else (
        echo Error: Neither bash nor chat_with_data.py found
        echo Please install Git for Windows or WSL to run the shell script
        pause
        exit /b 1
    )
)

echo.
echo === Execution Complete ===
echo Working directory: %WORK_DIR%
echo.
echo To run queries: python "%PROJECT_DIR%\query_data.py" "Your question"
echo.
pause