#!/usr/bin/env bash
# Slack接続テスト + 投稿テスト
# Usage: ./test-connection.sh [channel-id]
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

ok()   { echo -e "${GREEN}[OK]${NC} $*"; }
err()  { echo -e "${RED}[ERROR]${NC} $*"; }
info() { echo -e "${BLUE}[INFO]${NC} $*"; }

if [[ -z "${SLACK_BOT_TOKEN:-}" ]]; then
  err "SLACK_BOT_TOKEN が設定されていません"
  exit 1
fi

# 1. 認証テスト
info "認証テスト..."
AUTH=$(curl -s -X POST "https://slack.com/api/auth.test" \
  -H "Authorization: Bearer ${SLACK_BOT_TOKEN}")
AUTH_OK=$(echo "$AUTH" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('ok'))")

if [[ "$AUTH_OK" == "True" ]]; then
  BOT=$(echo "$AUTH" | python3 -c "import sys,json; d=json.load(sys.stdin); print(f\"{d.get('user')} @ {d.get('team')}\")")
  ok "認証成功: ${BOT}"
else
  AUTH_ERR=$(echo "$AUTH" | python3 -c "import sys,json; print(json.load(sys.stdin).get('error','unknown'))")
  err "認証失敗: ${AUTH_ERR}"
  exit 1
fi

# 2. 投稿テスト（チャンネルID指定時）
CHANNEL="${1:-}"
if [[ -n "$CHANNEL" ]]; then
  info "投稿テスト → ${CHANNEL}..."
  POST=$(curl -s -X POST "https://slack.com/api/chat.postMessage" \
    -H "Authorization: Bearer ${SLACK_BOT_TOKEN}" \
    -H "Content-Type: application/json; charset=utf-8" \
    -d "{\"channel\": \"${CHANNEL}\", \"text\": \":white_check_mark: cursor-times-agent 接続テスト成功\"}")
  POST_OK=$(echo "$POST" | python3 -c "import sys,json; print(json.load(sys.stdin).get('ok'))")

  if [[ "$POST_OK" == "True" ]]; then
    ok "投稿テスト成功"
  else
    POST_ERR=$(echo "$POST" | python3 -c "import sys,json; print(json.load(sys.stdin).get('error','unknown'))")
    err "投稿テスト失敗: ${POST_ERR}"
  fi
else
  info "投稿テストをスキップ（チャンネルID未指定）"
  echo "  Usage: $0 <channel-id>"
fi
