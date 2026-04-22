#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
DIST_DIR="$ROOT_DIR/dist"
PORT="${PORT:-8080}"

if [[ ! -f "$DIST_DIR/index.html" ]]; then
  echo "[INFO] 未发现 dist/index.html，先执行打包..."
  "$ROOT_DIR/scripts/package_download_site.sh"
fi

cd "$DIST_DIR"
echo "[OK] 本地下载页已启动：http://127.0.0.1:${PORT}"
echo "[OK] 手机同局域网访问：http://<你的电脑IP>:${PORT}"
python -m http.server "$PORT"
