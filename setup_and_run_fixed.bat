@echo off
REM Setup and run script for db_example project - Fixed version
REM Can be executed from any directory

setlocal enabledelayedexpansion

REM Configuration
set SCRIPT_DIR=%~dp0
set PROJECT_DIR=%SCRIPT_DIR:~0,-1%
set ENV_NAME=db_example_env
set CURRENT_DIR=%cd%

echo === DB Example Setup and Run Script (Fixed) ===
echo Current directory: %CURRENT_DIR%
echo Project directory: %PROJECT_DIR%
echo SCRIPT_DIR: %SCRIPT_DIR%
echo.

echo Checking if project directory exists...
if not exist "%PROJECT_DIR%" (
    echo Error: Project directory %PROJECT_DIR% does not exist!
    echo Please run this script from the db_example project directory
    pause
    exit /b 1
)
echo Project directory exists: OK
echo.

echo Checking if conda is available...
conda --version
echo Assuming conda is available since it printed version above
echo.

echo === Step 1: Creating conda environment '%ENV_NAME%' ===

REM Check if environment exists and remove it
echo Checking for existing environment...
conda env list | findstr "%ENV_NAME%"
if not errorlevel 1 (
    echo Environment '%ENV_NAME%' already exists. Removing it...
    conda env remove -n "%ENV_NAME%" -y
    if errorlevel 1 (
        echo Warning: Could not remove existing environment
    )
)

REM Create new environment with Python 3.12
echo Creating new conda environment with Python 3.12...
conda create -n "%ENV_NAME%" python=3.12 -y
if errorlevel 1 (
    echo Error: Failed to create conda environment
    pause
    exit /b 1
)
echo Environment created successfully
echo.

echo === Step 2: Installing requirements ===
echo Activating environment and installing requirements...
call conda activate "%ENV_NAME%"
if errorlevel 1 (
    echo Error: Failed to activate conda environment
    pause
    exit /b 1
)

REM Install requirements from the project directory
pip install -r "%PROJECT_DIR%\requirements.txt"
if errorlevel 1 (
    echo Error: Failed to install requirements
    pause
    exit /b 1
)
echo Requirements installed successfully
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
        pause
        exit /b 1
    )
)

REM Run the project script from the project directory but in our working directory
echo Executing runit.sh...
cd /d "%WORK_DIR%"

REM Check if Git Bash is available for running the shell script
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