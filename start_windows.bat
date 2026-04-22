@echo off
setlocal
cd /d "%~dp0"

if not exist "scripts\package_download_site.ps1" (
  echo [ERROR] 未找到 scripts\package_download_site.ps1
  echo [ERROR] 请确保你在项目根目录运行本脚本。
  pause
  exit /b 1
)

powershell -ExecutionPolicy Bypass -File ".\scripts\package_download_site.ps1"
if errorlevel 1 (
  echo [ERROR] 打包失败。
  pause
  exit /b 1
)

powershell -ExecutionPolicy Bypass -File ".\scripts\run_download_site.ps1"
endlocal
