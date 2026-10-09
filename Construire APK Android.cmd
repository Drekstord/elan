@echo off
rem Construit dist\ELAN.apk (Android). Double-cliquer ce fichier.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\android\build_apk.ps1"
echo.
pause
