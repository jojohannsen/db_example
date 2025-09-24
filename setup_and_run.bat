@echo off
REM Setup and run script for db_example project - No conda version
REM Uses system Python directly

setlocal

REM Configuration
set SCRIPT_DIR=%~dp0
set PROJECT_DIR=%SCRIPT_DIR:~0,-1%
set CURRENT_DIR=%cd%

echo === DB Example Setup and Run Script (No Virtual Environment) ===
echo Current directory: %CURRENT_DIR%
echo Project directory: %PROJECT_DIR%
echo.

echo Checking if project directory exists...
if not exist "%PROJECT_DIR%" (
    echo Error: Project directory %PROJECT_DIR% does not exist!
    echo Please run this script from the db_example project directory
    pause
    exit /b 1
)

if not exist "%PROJECT_DIR%\requirements.txt" (
    echo Error: requirements.txt not found in project directory
    pause
    exit /b 1
)

if not exist "%PROJECT_DIR%\runit.sh" (
    echo Error: runit.sh not found in project directory
    pause
    exit /b 1
)

echo Project files found: OK
echo.

echo Checking if Python is available...
python --version
if errorlevel 1 (
    echo Error: Python is not available in PATH
    echo Please install Python and add it to your PATH
    pause
    exit /b 1
)
echo.

echo === Step 1: Installing requirements ===
echo Installing Python packages from requirements.txt...
pip install -r "%PROJECT_DIR%\requirements.txt"
if errorlevel 1 (
    echo Error: Failed to install requirements
    echo Make sure pip is available and working
    pause
    exit /b 1
)
echo Requirements installed successfully
echo.

echo === Step 2: Setting up working directory ===
REM Create a working directory in current location
set WORK_DIR=%CURRENT_DIR%\db_example_work
if not exist "%WORK_DIR%" mkdir "%WORK_DIR%"
cd /d "%WORK_DIR%"
echo Working directory: %WORK_DIR%
echo.

echo === Step 3: Running the example ===
REM Check for ANTHROPIC_API_KEY
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

REM Run the project script
echo Running the example...
cd /d "%WORK_DIR%"

REM Check if Git Bash is available for running the shell script
where bash >nul 2>&1
if not errorlevel 1 (
    echo Found bash, running runit.sh...
    bash "%PROJECT_DIR%\runit.sh"
) else (
    echo bash not found. Running Python script directly...
    if exist "%PROJECT_DIR%\chat_with_data.py" (
        python "%PROJECT_DIR%\chat_with_data.py"
    ) else (
        echo Error: chat_with_data.py not found
        echo Please install Git for Windows to run the shell script, or ensure chat_with_data.py exists
        pause
        exit /b 1
    )
)

echo.
echo === Execution Complete ===
echo Working directory: %WORK_DIR%
echo Database created at: %WORK_DIR%\fake.db
echo.
echo To run custom queries, use:
echo   python "%PROJECT_DIR%\query_data.py" "Your question here"
echo.

pause