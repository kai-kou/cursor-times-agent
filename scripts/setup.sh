#!/usr/bin/env bash
# cursor-times-agent セットアップスクリプト
# slack-fast-mcpの検出・MCP設定・接続テストを自動化
set -euo pipefail

# --- 色定義 ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()   { echo -e "${RED}[ERROR]${NC} $*"; }

# --- 定数 ---
MCP_JSON="${HOME}/.cursor/mcp.json"
AGENTS_DIR="${HOME}/.cursor/agents"
SKILLS_DIR="${HOME}/.cursor/skills"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GITHUB_REPO="kai-kou/slack-fast-mcp"

echo ""
echo "========================================"
echo "  cursor-times-agent セットアップ"
echo "========================================"
echo ""

# ============================================
# Step 1: slack-fast-mcp バイナリの検出
# ============================================
info "Step 1: slack-fast-mcp バイナリの検出..."

SFM_BIN=""

# 検索順: PATH > ローカル開発ディレクトリ > ~/bin > /usr/local/bin
for candidate in \
  "$(command -v slack-fast-mcp 2>/dev/null || true)" \
  "${HOME}/dev/01_active/slack-fast-mcp/slack-fast-mcp" \
  "${HOME}/bin/slack-fast-mcp" \
  "/usr/local/bin/slack-fast-mcp"; do
  if [[ -n "$candidate" && -x "$candidate" ]]; then
    SFM_BIN="$candidate"
    break
  fi
done

if [[ -z "$SFM_BIN" ]]; then
  warn "slack-fast-mcp バイナリが見つかりません"
  echo ""
  echo "  インストール方法:"
  echo "    # GitHub Releases からダウンロード"
  echo "    curl -LO https://github.com/${GITHUB_REPO}/releases/latest/download/slack-fast-mcp_darwin_arm64.tar.gz"
  echo "    tar xzf slack-fast-mcp_darwin_arm64.tar.gz"
  echo "    sudo mv slack-fast-mcp /usr/local/bin/"
  echo ""
  read -rp "  バイナリのパスを手動入力（スキップはEnter）: " SFM_BIN
  if [[ -z "$SFM_BIN" || ! -x "$SFM_BIN" ]]; then
    err "有効なバイナリが指定されませんでした。セットアップを中断します。"
    exit 1
  fi
fi

ok "バイナリ: ${SFM_BIN}"

# バージョン確認
SFM_VERSION=$("$SFM_BIN" version 2>/dev/null || echo "unknown")
info "バージョン: ${SFM_VERSION}"

# ============================================
# Step 2: 環境変数の確認
# ============================================
echo ""
info "Step 2: 環境変数の確認..."

if [[ -z "${SLACK_BOT_TOKEN:-}" ]]; then
  warn "SLACK_BOT_TOKEN が設定されていません"
  echo ""
  echo "  ~/.zshrc に以下を追加してください:"
  echo "    export SLACK_BOT_TOKEN=\"xoxb-your-token-here\""
  echo ""
  read -rsp "  トークンを入力（表示されません、スキップはEnter）: " TOKEN_INPUT
  echo ""
  if [[ -n "$TOKEN_INPUT" ]]; then
    export SLACK_BOT_TOKEN="$TOKEN_INPUT"
    ok "トークンを一時設定しました（永続化は ~/.zshrc への追記が必要）"
  else
    err "SLACK_BOT_TOKEN が必要です。セットアップを中断します。"
    exit 1
  fi
else
  ok "SLACK_BOT_TOKEN: 設定済み (${SLACK_BOT_TOKEN:0:10}...)"
fi

# ============================================
# Step 3: Slack接続テスト
# ============================================
echo ""
info "Step 3: Slack接続テスト..."

AUTH_RESULT=$(curl -s -X POST "https://slack.com/api/auth.test" \
  -H "Authorization: Bearer ${SLACK_BOT_TOKEN}")

AUTH_OK=$(echo "$AUTH_RESULT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('ok', False))" 2>/dev/null || echo "False")

if [[ "$AUTH_OK" == "True" ]]; then
  BOT_NAME=$(echo "$AUTH_RESULT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('user', 'unknown'))" 2>/dev/null)
  TEAM_NAME=$(echo "$AUTH_RESULT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('team', 'unknown'))" 2>/dev/null)
  ok "接続成功: ${BOT_NAME} @ ${TEAM_NAME}"
else
  AUTH_ERR=$(echo "$AUTH_RESULT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('error', 'unknown'))" 2>/dev/null)
  err "接続失敗: ${AUTH_ERR}"
  err "SLACK_BOT_TOKEN を確認してください"
  exit 1
fi

# ============================================
# Step 4: チャンネルID取得ヘルパー
# ============================================
echo ""
info "Step 4: 投稿先チャンネルの確認..."

CHANNEL_ID=""

# 人格ファイルからデフォルトチャンネルを取得
PERSONA_FILE="${REPO_ROOT}/persona/default.md"
if [[ -f "$PERSONA_FILE" ]]; then
  EXISTING_CH=$(grep -o '"C[A-Z0-9]*"' "$PERSONA_FILE" 2>/dev/null | head -1 | tr -d '"' || true)
  if [[ -n "$EXISTING_CH" ]]; then
    info "人格設定のチャンネルID: ${EXISTING_CH}"
    CHANNEL_ID="$EXISTING_CH"
  fi
fi

if [[ -z "$CHANNEL_ID" ]]; then
  echo ""
  echo "  チャンネルIDを検索します（チャンネル名の一部を入力）:"
  read -rp "  検索キーワード: " CH_KEYWORD

  if [[ -n "$CH_KEYWORD" ]]; then
    echo ""
    curl -s "https://slack.com/api/conversations.list?types=public_channel,private_channel&limit=200" \
      -H "Authorization: Bearer ${SLACK_BOT_TOKEN}" | \
      python3 -c "
import sys, json
data = json.load(sys.stdin)
keyword = '${CH_KEYWORD}'.lower()
channels = [c for c in data.get('channels', []) if keyword in c['name'].lower()]
for c in channels[:10]:
    print(f\"  {c['id']}  #{c['name']}\")
if not channels:
    print('  該当するチャンネルが見つかりません')
" 2>/dev/null

    echo ""
    read -rp "  使用するチャンネルID: " CHANNEL_ID
  fi
fi

if [[ -n "$CHANNEL_ID" ]]; then
  ok "チャンネルID: ${CHANNEL_ID}"
else
  warn "チャンネルIDが未設定です（後で人格設定ファイルに設定してください）"
fi

# ============================================
# Step 5: ~/.cursor/mcp.json の設定
# ============================================
echo ""
info "Step 5: Cursor MCP設定..."

if [[ -f "$MCP_JSON" ]]; then
  # 既存設定にslack-fast-mcpがあるか確認
  HAS_SFM=$(python3 -c "
import json
with open('${MCP_JSON}') as f:
    data = json.load(f)
print('slack-fast-mcp' in data.get('mcpServers', {}))
" 2>/dev/null || echo "False")

  if [[ "$HAS_SFM" == "True" ]]; then
    ok "mcp.json: slack-fast-mcp 設定済み"

    # トークンが直接記載されているか確認
    TOKEN_DIRECT=$(python3 -c "
import json
with open('${MCP_JSON}') as f:
    data = json.load(f)
token = data.get('mcpServers', {}).get('slack-fast-mcp', {}).get('env', {}).get('SLACK_BOT_TOKEN', '')
print('direct' if token.startswith('xoxb-') else 'env_ref' if '\${' in token else 'missing')
" 2>/dev/null || echo "unknown")

    if [[ "$TOKEN_DIRECT" == "env_ref" ]]; then
      warn "mcp.json のトークンが \${ENV_VAR} 形式です（Cursorでは展開されません）"
      read -rp "  トークン値を直接記載に更新しますか？ (y/N): " UPDATE_TOKEN
      if [[ "$UPDATE_TOKEN" =~ ^[Yy]$ ]]; then
        python3 -c "
import json
with open('${MCP_JSON}') as f:
    data = json.load(f)
data['mcpServers']['slack-fast-mcp']['env']['SLACK_BOT_TOKEN'] = '${SLACK_BOT_TOKEN}'
data['mcpServers']['slack-fast-mcp']['command'] = '${SFM_BIN}'
with open('${MCP_JSON}', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write('\n')
"
        ok "mcp.json を更新しました"
      fi
    elif [[ "$TOKEN_DIRECT" == "direct" ]]; then
      ok "トークン: 直接記載済み"
    fi
  else
    info "slack-fast-mcp を mcp.json に追加します..."
    python3 -c "
import json
data = {}
try:
    with open('${MCP_JSON}') as f:
        data = json.load(f)
except:
    pass
if 'mcpServers' not in data:
    data['mcpServers'] = {}
data['mcpServers']['slack-fast-mcp'] = {
    'command': '${SFM_BIN}',
    'args': [],
    'env': {
        'SLACK_BOT_TOKEN': '${SLACK_BOT_TOKEN}'
    }
}
with open('${MCP_JSON}', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write('\n')
"
    ok "mcp.json に slack-fast-mcp を追加しました"
  fi
else
  info "mcp.json を新規作成します..."
  mkdir -p "$(dirname "$MCP_JSON")"
  python3 -c "
import json
data = {
    'mcpServers': {
        'slack-fast-mcp': {
            'command': '${SFM_BIN}',
            'args': [],
            'env': {
                'SLACK_BOT_TOKEN': '${SLACK_BOT_TOKEN}'
            }
        }
    }
}
with open('${MCP_JSON}', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write('\n')
"
  ok "mcp.json を作成しました"
fi

# ============================================
# Step 6: エージェント・スキルの配置確認
# ============================================
echo ""
info "Step 6: エージェント・スキルの配置確認..."

AGENT_FILE="${AGENTS_DIR}/cursor-times-agent.md"
SKILL_FILE="${SKILLS_DIR}/cursor-times-agent/SKILL.md"

if [[ -f "$AGENT_FILE" ]]; then
  ok "エージェント: ${AGENT_FILE}"
else
  warn "エージェント未配置: ${AGENT_FILE}"
  echo "  cursor-agents-skills から同期してください:"
  echo "  rsync -av /path/to/cursor-agents-skills/agents/ ~/.cursor/agents/"
fi

if [[ -f "$SKILL_FILE" ]]; then
  ok "スキル: ${SKILL_FILE}"
else
  warn "スキル未配置: ${SKILL_FILE}"
  echo "  cursor-agents-skills から同期してください:"
  echo "  rsync -av /path/to/cursor-agents-skills/skills/ ~/.cursor/skills/"
fi

# ============================================
# Step 7: 投稿テスト
# ============================================
echo ""
info "Step 7: 投稿テスト..."

if [[ -n "$CHANNEL_ID" ]]; then
  read -rp "  テスト投稿を送信しますか？ (y/N): " DO_TEST
  if [[ "$DO_TEST" =~ ^[Yy]$ ]]; then
    TEST_MSG=":cat: cursor-times-agent セットアップ完了テスト :paw_prints:"
    TEST_RESULT=$(curl -s -X POST "https://slack.com/api/chat.postMessage" \
      -H "Authorization: Bearer ${SLACK_BOT_TOKEN}" \
      -H "Content-Type: application/json; charset=utf-8" \
      -d "{\"channel\": \"${CHANNEL_ID}\", \"text\": \"${TEST_MSG}\"}")

    TEST_OK=$(echo "$TEST_RESULT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('ok', False))" 2>/dev/null)
    if [[ "$TEST_OK" == "True" ]]; then
      ok "テスト投稿成功！Slackを確認してください"
    else
      TEST_ERR=$(echo "$TEST_RESULT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('error', 'unknown'))" 2>/dev/null)
      err "テスト投稿失敗: ${TEST_ERR}"
    fi
  else
    info "テスト投稿をスキップしました"
  fi
else
  warn "チャンネルIDが未設定のためテスト投稿をスキップ"
fi

# ============================================
# サマリー
# ============================================
echo ""
echo "========================================"
echo "  セットアップ結果"
echo "========================================"
echo ""
echo "  バイナリ:     ${SFM_BIN}"
echo "  トークン:     ${SLACK_BOT_TOKEN:0:10}..."
echo "  チャンネル:   ${CHANNEL_ID:-未設定}"
echo "  mcp.json:     ${MCP_JSON}"
echo "  エージェント: $([ -f "$AGENT_FILE" ] && echo "配置済み" || echo "未配置")"
echo "  スキル:       $([ -f "$SKILL_FILE" ] && echo "配置済み" || echo "未配置")"
echo ""

if [[ -f "$AGENT_FILE" && -f "$SKILL_FILE" && -n "$CHANNEL_ID" ]]; then
  ok "セットアップ完了！Cursorでタスクを完了すると自動投稿されます"
else
  warn "一部の設定が不完全です。上記の警告を確認してください"
fi
echo ""
