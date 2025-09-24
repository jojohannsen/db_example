@echo off
setlocal enabledelayedexpansion

echo Testing conda check logic exactly like main script
echo.

echo Step 1: Run conda --version
conda --version
echo.

echo Step 2: Check errorlevel immediately
echo Errorlevel right after conda: %errorlevel%
set CONDA_CHECK=%errorlevel%
echo Stored CONDA_CHECK: %CONDA_CHECK%
echo.

echo Step 3: Test the conditional
if %CONDA_CHECK% neq 0 (
    echo CONDA_CHECK is NOT zero - this means conda failed
    echo This branch should NOT execute if conda worked
) else (
    echo CONDA_CHECK is zero - conda worked fine
)

echo.
echo Step 4: Alternative conditional test
if %CONDA_CHECK% equ 0 (
    echo Alternative test: conda is working
) else (
    echo Alternative test: conda failed
)

echo.
echo Step 5: Direct errorlevel test
if errorlevel 1 (
    echo Direct errorlevel test: conda failed
) else (
    echo Direct errorlevel test: conda worked
)

echo.
echo All tests complete
pause