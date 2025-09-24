@echo off
echo Starting test batch script
echo.

echo Step 1: Basic echo test
echo This should print

echo.
echo Step 2: Variable test
set TEST_VAR=hello
echo TEST_VAR is: %TEST_VAR%

echo.
echo Step 3: Conda test
echo About to run conda --version
conda --version
echo Conda command finished

echo.
echo Step 4: Errorlevel test
echo Errorlevel after conda: %errorlevel%

echo.
echo Step 5: Simple if test
if 1 equ 1 (
    echo Simple if works
) else (
    echo Simple if failed
)

echo.
echo Step 6: Final test
echo If you see this, the script is working
echo.

pause
echo Script completed