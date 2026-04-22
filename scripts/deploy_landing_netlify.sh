#!/usr/bin/env bash
set -euo pipefail

# 用法：
# NETLIFY_AUTH_TOKEN=xxx NETLIFY_SITE_ID=xxx ./scripts/deploy_landing_netlify.sh

if [[ -z "${NETLIFY_AUTH_TOKEN:-}" || -z "${NETLIFY_SITE_ID:-}" ]]; then
  echo "[ERROR] 请先设置 NETLIFY_AUTH_TOKEN 与 NETLIFY_SITE_ID"
  exit 1
fi

if ! command -v npx >/dev/null 2>&1; then
  echo "[ERROR] 需要 node + npx"
  exit 1
fi

npx netlify-cli deploy \
  --dir=landing_page \
  --site="$NETLIFY_SITE_ID" \
  --prod \
  --auth="$NETLIFY_AUTH_TOKEN"
