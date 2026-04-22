#!/usr/bin/env bash
set -euo pipefail

# 一键打包：Flutter APK + Flutter Web + 下载落地页
# 输出目录：dist/

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
APP_DIR="$ROOT_DIR/flutter_app"
LANDING_DIR="$ROOT_DIR/landing_page"
DIST_DIR="$ROOT_DIR/dist"

if ! command -v flutter >/dev/null 2>&1; then
  echo "[ERROR] flutter 未安装。请先安装 Flutter SDK。"
  exit 1
fi

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR/downloads" "$DIST_DIR/web"

pushd "$APP_DIR" >/dev/null
flutter pub get
flutter build apk --release
flutter build web --release
popd >/dev/null

cp -R "$LANDING_DIR"/* "$DIST_DIR"/
cp "$APP_DIR/build/app/outputs/flutter-apk/app-release.apk" "$DIST_DIR/downloads/app-release.apk"
cp -R "$APP_DIR/build/web"/* "$DIST_DIR/web/"

# 把落地页中的占位链接替换成本地相对路径
python - <<'PY'
from pathlib import Path
p = Path('dist/index.html')
s = p.read_text(encoding='utf-8')
s = s.replace('/downloads/couple-task-latest.apk', './downloads/app-release.apk')
s = s.replace('https://your-web-demo-url.example.com', './web/index.html')
s = s.replace('https://testflight.apple.com/join/your-code', '#')
p.write_text(s, encoding='utf-8')
PY

echo "[OK] 打包完成：$DIST_DIR"
echo "[OK] 下载页：$DIST_DIR/index.html"
