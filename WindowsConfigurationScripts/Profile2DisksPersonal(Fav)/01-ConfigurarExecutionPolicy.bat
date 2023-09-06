@echo off
REM This script will run a PowerShell command to set the execution policy to bypass for the current user
powershell -Command "Set-ExecutionPolicy Bypass -Scope CurrentUser"
pause
