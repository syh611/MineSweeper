$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$distDir = Join-Path $root 'dist'
$port = if ($env:PORT) { $env:PORT } else { '8080' }

if (-not (Test-Path (Join-Path $distDir 'index.html'))) {
  Write-Host '[INFO] 未发现 dist/index.html，先执行打包...'
  & (Join-Path $PSScriptRoot 'package_download_site.ps1')
}

$prefix = "http://127.0.0.1:$port/"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)
$listener.Start()

Write-Host "[OK] 本地下载页已启动：$prefix"
Write-Host "[OK] 手机同局域网访问：http://<你的电脑IP>:$port"
Write-Host '[OK] 按 Ctrl+C 停止服务'

try {
  while ($listener.IsListening) {
    $context = $listener.GetContext()
    $requestPath = $context.Request.Url.AbsolutePath.TrimStart('/')
    if ([string]::IsNullOrWhiteSpace($requestPath)) { $requestPath = 'index.html' }

    $localPath = Join-Path $distDir $requestPath
    if ((Test-Path $localPath) -and ((Get-Item $localPath).PSIsContainer)) {
      $localPath = Join-Path $localPath 'index.html'
    }

    if (-not (Test-Path $localPath)) {
      $context.Response.StatusCode = 404
      $bytes = [System.Text.Encoding]::UTF8.GetBytes('404 Not Found')
      $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
      $context.Response.Close()
      continue
    }

    $ext = [System.IO.Path]::GetExtension($localPath).ToLowerInvariant()
    $contentType = switch ($ext) {
      '.html' { 'text/html; charset=utf-8' }
      '.css'  { 'text/css; charset=utf-8' }
      '.js'   { 'application/javascript; charset=utf-8' }
      '.json' { 'application/json; charset=utf-8' }
      '.png'  { 'image/png' }
      '.jpg'  { 'image/jpeg' }
      '.jpeg' { 'image/jpeg' }
      '.svg'  { 'image/svg+xml' }
      '.apk'  { 'application/vnd.android.package-archive' }
      default { 'application/octet-stream' }
    }

    $fileBytes = [System.IO.File]::ReadAllBytes($localPath)
    $context.Response.ContentType = $contentType
    $context.Response.ContentLength64 = $fileBytes.Length
    $context.Response.OutputStream.Write($fileBytes, 0, $fileBytes.Length)
    $context.Response.Close()
  }
}
finally {
  $listener.Stop()
  $listener.Close()
}
