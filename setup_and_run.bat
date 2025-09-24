@echo off
REM Setup and run script for db_example project
REM Can be executed from any directory

setlocal enabledelayedexpansion

REM Configuration
set SCRIPT_DIR=%~dp0
set PROJECT_DIR=%SCRIPT_DIR:~0,-1%
set ENV_NAME=db_example_env
set CURRENT_DIR=%cd%

echo === DB Example Setup and Run Script ===
echo Current directory: %CURRENT_DIR%
echo Project directory: %PROJECT_DIR%
echo SCRIPT_DIR: %SCRIPT_DIR%
echo.

echo DEBUG: Press any key to continue after reviewing paths above...
pause

echo DEBUG: Checking if project directory exists...
REM Check if project directory exists
if not exist "%PROJECT_DIR%" (
    echo Error: Project directory %PROJECT_DIR% does not exist!
    echo Please run this script from the db_example project directory
    pause
    exit /b 1
) else (
    echo DEBUG: Project directory exists
)

echo.
echo DEBUG: Checking if conda is available...
REM Check if conda is available - let's see the actual output first
conda --version
if errorlevel 1 (
    echo Error: conda is not available in PATH
    echo Please ensure conda is installed and initialized
    echo You may need to run 'conda init cmd.exe' and restart your command prompt
    echo.
    pause
    exit /b 1
) else (
    echo DEBUG: conda is available - continuing...
)

echo.
echo DEBUG: Press any key to continue to Step 1...
pause

echo.
echo === Step 1: Creating conda environment '%ENV_NAME%' ===

REM Check if environment exists and remove it
conda env list | findstr /b "%ENV_NAME% " >nul 2>&1
if not errorlevel 1 (
    echo Environment '%ENV_NAME%' already exists. Removing it...
    conda env remove -n "%ENV_NAME%" -y
)

REM Create new environment with Python 3.12
echo Creating new conda environment with Python 3.12...
conda create -n "%ENV_NAME%" python=3.12 -y
if errorlevel 1 (
    echo Error: Failed to create conda environment
    exit /b 1
)

echo.
echo === Step 2: Installing requirements ===

REM Activate environment and install requirements
echo Activating environment and installing requirements...
call conda activate "%ENV_NAME%"
if errorlevel 1 (
    echo Error: Failed to activate conda environment
    exit /b 1
)

REM Install requirements from the project directory
pip install -r "%PROJECT_DIR%\requirements.txt"
if errorlevel 1 (
    echo Error: Failed to install requirements
    exit /b 1
)

echo.
echo === Step 3: Setting up working directory ===

REM Create a working directory in current location
set WORK_DIR=%CURRENT_DIR%\db_example_work
if not exist "%WORK_DIR%" mkdir "%WORK_DIR%"
cd /d "%WORK_DIR%"

echo Working directory: %WORK_DIR%

echo.
echo === Step 4: Running the example ===

REM Check for ANTHROPIC_API_KEY
if "%ANTHROPIC_API_KEY%"=="" (
    echo Warning: ANTHROPIC_API_KEY environment variable is not set
    echo Please set it with: set ANTHROPIC_API_KEY=your-api-key-here
    echo.
    set /p CONTINUE="Do you want to continue anyway? (y/N): "
    if /i not "!CONTINUE!"=="y" (
        echo Exiting. Please set ANTHROPIC_API_KEY and run again.
        exit /b 1
    )
)

REM Run the project script from the project directory but in our working directory
echo Executing runit.sh...
cd /d "%WORK_DIR%"

REM Check if Git Bash is available for running the shell script
where bash >nul 2>&1
if not errorlevel 1 (
    bash "%PROJECT_DIR%\runit.sh"
) else (
    echo Error: bash is not available in PATH
    echo This script requires bash to run runit.sh
    echo Please install Git for Windows or Windows Subsystem for Linux
    echo Alternatively, you can run the Python script directly:
    echo   python "%PROJECT_DIR%\chat_with_data.py"
    exit /b 1
)

echo.
echo === Execution Complete ===
echo Environment: %ENV_NAME% (still activated)
echo Working directory: %WORK_DIR%
echo Database created at: %WORK_DIR%\fake.db
echo.
echo To run custom queries, use:
echo   python "%PROJECT_DIR%\query_data.py" "Your question here"
echo.
echo To deactivate environment: conda deactivate
echo To remove environment: conda env remove -n %ENV_NAME%

pause