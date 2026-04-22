#!/usr/bin/env bash
set -euo pipefail

# 用法：./scripts/take_screenshots.sh
# 依赖：已安装 Flutter SDK + Android 模拟器或 iOS Simulator

APP_DIR="flutter_app"
OUT_DIR="artifacts/screenshots"
mkdir -p "$OUT_DIR"

cd "$APP_DIR"

if ! command -v flutter >/dev/null 2>&1; then
  echo "[ERROR] flutter 未安装，请先安装 Flutter SDK"
  exit 1
fi

flutter pub get

# 启动后通过 integration_test 或截图命令抓图（简单 MVP：使用 flutter screenshot）
# 先确保已有可用设备：flutter devices
DEVICE_ID="${DEVICE_ID:-}"
if [[ -z "$DEVICE_ID" ]]; then
  DEVICE_ID=$(flutter devices --machine | python - <<'PY'
import json,sys
arr=json.load(sys.stdin)
print(arr[0]['id'] if arr else '')
PY
)
fi

if [[ -z "$DEVICE_ID" ]]; then
  echo "[ERROR] 未找到可用设备，请先启动模拟器或真机"
  exit 1
fi

echo "使用设备: $DEVICE_ID"
flutter run -d "$DEVICE_ID" --dart-define=TAKE_SCREENSHOTS=true &
RUN_PID=$!

sleep 20
flutter screenshot -d "$DEVICE_ID" -o "../$OUT_DIR/home.png"
flutter screenshot -d "$DEVICE_ID" -o "../$OUT_DIR/tasks.png"

kill "$RUN_PID" || true

echo "截图已生成到 $OUT_DIR"
