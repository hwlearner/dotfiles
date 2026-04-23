@echo off
setlocal

set SCRIPT_DIR=%~dp0

if "%~1"=="" (
  powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%sync-vscode-windows.ps1" -InstallExtensions
  set SCRIPT_EXIT=%ERRORLEVEL%
  echo.
  pause
  exit /b %SCRIPT_EXIT%
)

powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%sync-vscode-windows.ps1" %*
exit /b %ERRORLEVEL%
