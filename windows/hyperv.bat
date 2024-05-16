@echo off
title Hyper-V Launch Type Switcher

:menu
cls
echo ==============================
echo Hyper-V Launch Type Switcher
echo ==============================
for /f "tokens=2 delims=: " %%a in ('bcdedit /enum /v ^| findstr /i "hypervisorlaunchtype"') do set "currentStatus=%%a"
set "currentStatus=%currentStatus: =%"
echo Current Status: %currentStatus%
echo.
echo 1. Enable Hyper-V Launch Type
echo 2. Disable Hyper-V Launch Type
echo 3. Exit
echo 4. Restart System
echo ==============================
set /p choice="Enter your choice (1/2/3/4): "

if "%choice%"=="1" goto enable
if "%choice%"=="2" goto disable
if "%choice%"=="3" goto exit
if "%choice%"=="4" goto restart

echo Invalid choice. Please try again.
pause
goto menu

:enable
bcdedit /set hypervisorlaunchtype Auto
echo Hyper-V Launch Type has been enabled.
pause
goto menu

:disable
bcdedit /set hypervisorlaunchtype Off
echo Hyper-V Launch Type has been disabled.
pause
goto menu

:restart
echo Restarting system...
shutdown /r /t 5
goto exit

:exit
echo Exiting...
pause
exit