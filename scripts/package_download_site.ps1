$ErrorActionPreference = 'Stop'

# 一键打包：Flutter APK + Flutter Web + 下载落地页（Windows PowerShell）

$root = Split-Path -Parent $PSScriptRoot
$appDir = Join-Path $root 'flutter_app'
$landingDir = Join-Path $root 'landing_page'
$distDir = Join-Path $root 'dist'

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw '未检测到 flutter，请先安装 Flutter 并加入 PATH。'
}

if (Test-Path $distDir) {
  Remove-Item $distDir -Recurse -Force
}
New-Item -ItemType Directory -Path (Join-Path $distDir 'downloads') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $distDir 'web') -Force | Out-Null

Push-Location $appDir
flutter pub get
flutter build apk --release
flutter build web --release
Pop-Location

Copy-Item (Join-Path $landingDir '*') $distDir -Recurse -Force
Copy-Item (Join-Path $appDir 'build/app/outputs/flutter-apk/app-release.apk') (Join-Path $distDir 'downloads/app-release.apk') -Force
Copy-Item (Join-Path $appDir 'build/web/*') (Join-Path $distDir 'web') -Recurse -Force

$indexPath = Join-Path $distDir 'index.html'
$content = Get-Content $indexPath -Raw
$content = $content.Replace('/downloads/couple-task-latest.apk', './downloads/app-release.apk')
$content = $content.Replace('https://your-web-demo-url.example.com', './web/index.html')
$content = $content.Replace('https://testflight.apple.com/join/your-code', '#')
Set-Content -Path $indexPath -Value $content -Encoding UTF8

Write-Host "[OK] 打包完成：$distDir"
Write-Host "[OK] 下载页：$indexPath"
