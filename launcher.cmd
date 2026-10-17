@echo off
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -nologo -Noninteractive -WindowStyle Hidden -File "%~dp0launcher.ps1" %*
