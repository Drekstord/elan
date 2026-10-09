@echo off
rem Installe ou met a jour ELAN (Windows). Double-cliquer ce fichier.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\windows\installer.ps1" %*
echo.
pause
