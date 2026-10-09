@echo off
rem Prepare le serveur ELAN : cree le fichier .env avec des secrets neufs. Double-cliquer ce fichier.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0systeme\preparer.ps1" %*
echo.
pause
