#!/usr/bin/env bash
# cursor-times-agent → cursor-agents-skills 同期スクリプト
# リポジトリの変更をcursor-agents-skillsリポジトリに同期する（メンテナー向け）
set -euo pipefail

# --- 色定義 ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()   { echo -e "${RED}[ERROR]${NC} $*"; }
dry()   { echo -e "${CYAN}[DRY-RUN]${NC} $*"; }

# --- 定数 ---
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEFAULT_CAS_PATH="${HOME}/dev/01_active/cursor-agents-skills"

# --- オプション解析 ---
DRY_RUN=false
CAS_PATH=""
DO_COMMIT=false

usage() {
  echo "Usage: $(basename "$0") [OPTIONS] [CURSOR_AGENTS_SKILLS_PATH]"
  echo ""
  echo "cursor-times-agent のソースを cursor-agents-skills リポジトリに同期します。"
  echo ""
  echo "Arguments:"
  echo "  CURSOR_AGENTS_SKILLS_PATH   cursor-agents-skills のパス"
  echo "                              (デフォルト: ${DEFAULT_CAS_PATH})"
  echo ""
  echo "Options:"
  echo "  --dry-run       実際にコピーせず、差分のみ表示"
  echo "  --commit        同期後に自動コミット（pushはしない）"
  echo "  --help, -h      このヘルプを表示"
  echo ""
  echo "同期マッピング:"
  echo "  agent/cursor-times-agent.md    → agents/cursor-times-agent.md"
  echo "  skill/SKILL.md                 → skills/cursor-times-agent/SKILL.md"
  echo "  skill/references/*             → skills/cursor-times-agent/references/*"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)  DRY_RUN=true; shift ;;
    --commit)   DO_COMMIT=true; shift ;;
    --help|-h)  usage; exit 0 ;;
    -*)         err "不明なオプション: $1"; usage; exit 1 ;;
    *)          CAS_PATH="$1"; shift ;;
  esac
done

# cursor-agents-skills パスの決定
if [[ -z "$CAS_PATH" ]]; then
  CAS_PATH="$DEFAULT_CAS_PATH"
fi

echo ""
echo "========================================"
echo "  cursor-agents-skills 同期"
echo "========================================"
echo ""

# ============================================
# Step 1: リポジトリの検証
# ============================================
info "Step 1: リポジトリの検証..."

if [[ ! -d "$CAS_PATH" ]]; then
  err "cursor-agents-skills が見つかりません: ${CAS_PATH}"
  echo ""
  echo "  使用方法:"
  echo "    $(basename "$0") /path/to/cursor-agents-skills"
  exit 1
fi

if [[ ! -d "${CAS_PATH}/.git" ]]; then
  err "Git リポジトリではありません: ${CAS_PATH}"
  exit 1
fi

ok "ソース: ${REPO_ROOT}"
ok "同期先: ${CAS_PATH}"

# ============================================
# Step 2: 同期マッピングの定義
# ============================================
info "Step 2: 同期マッピング..."

# 配列: "ソース|デプロイ先" のペア
SYNC_MAP=(
  "agent/cursor-times-agent.md|agents/cursor-times-agent.md"
  "skill/SKILL.md|skills/cursor-times-agent/SKILL.md"
  "skill/references/ERROR_HANDLING.md|skills/cursor-times-agent/references/ERROR_HANDLING.md"
  "skill/references/PERSONA_FORMAT.md|skills/cursor-times-agent/references/PERSONA_FORMAT.md"
  "skill/references/POSTING_FORMAT.md|skills/cursor-times-agent/references/POSTING_FORMAT.md"
)

echo ""
for pair in "${SYNC_MAP[@]}"; do
  src="${pair%%|*}"
  dst="${pair##*|}"
  echo "  ${src}"
  echo "    → ${dst}"
  echo ""
done

# ============================================
# Step 3: 差分の表示
# ============================================
echo ""
info "Step 3: 差分の確認..."

HAS_DIFF=false
for pair in "${SYNC_MAP[@]}"; do
  src="${REPO_ROOT}/${pair%%|*}"
  dst="${CAS_PATH}/${pair##*|}"

  if [[ ! -f "$src" ]]; then
    err "ソースが存在しません: ${pair%%|*}"
    continue
  fi

  if [[ ! -f "$dst" ]]; then
    warn "新規ファイル: ${pair##*|}"
    HAS_DIFF=true
  elif ! diff -q "$src" "$dst" > /dev/null 2>&1; then
    warn "変更あり: ${pair##*|}"
    echo ""
    diff --color=auto -u "$dst" "$src" || true
    echo ""
    HAS_DIFF=true
  else
    ok "差分なし: ${pair##*|}"
  fi
done

if [[ "$HAS_DIFF" == "false" ]]; then
  ok "すべてのファイルが同期済みです。変更はありません。"
  exit 0
fi

# ============================================
# Step 4: 同期実行
# ============================================
if [[ "$DRY_RUN" == "true" ]]; then
  echo ""
  dry "ドライランモード: 実際のコピーは行いません"
  exit 0
fi

echo ""
read -rp "  同期を実行しますか？ (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  info "同期をキャンセルしました。"
  exit 0
fi

echo ""
info "Step 4: 同期実行..."

for pair in "${SYNC_MAP[@]}"; do
  src="${REPO_ROOT}/${pair%%|*}"
  dst="${CAS_PATH}/${pair##*|}"

  if [[ ! -f "$src" ]]; then
    continue
  fi

  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  ok "同期: ${pair%%|*} → ${pair##*|}"
done

# ============================================
# Step 5: オプション - 自動コミット
# ============================================
if [[ "$DO_COMMIT" == "true" ]]; then
  echo ""
  info "Step 5: 自動コミット..."

  cd "$CAS_PATH"
  git add agents/cursor-times-agent.md skills/cursor-times-agent/

  # 変更がステージングされているか確認
  if git diff --cached --quiet; then
    info "ステージング済みの変更がありません。コミットをスキップします。"
  else
    COMMIT_MSG="sync: cursor-times-agent のソースを同期

cursor-times-agent リポジトリからの同期デプロイ

Co-authored-by: cursor <cursor@aainc.co.jp>"

    git commit -m "$COMMIT_MSG"
    ok "コミット完了（pushは手動で実行してください）"
  fi
else
  echo ""
  info "自動コミットはスキップ（--commit で有効化）"
  echo "  手動でコミットする場合:"
  echo "    cd ${CAS_PATH}"
  echo "    git add agents/cursor-times-agent.md skills/cursor-times-agent/"
  echo "    git commit -m 'sync: cursor-times-agent のソースを同期'"
fi

# ============================================
# サマリー
# ============================================
echo ""
echo "========================================"
echo "  同期結果"
echo "========================================"
echo ""
echo "  ソース:       ${REPO_ROOT}"
echo "  同期先:       ${CAS_PATH}"
echo "  ファイル数:   ${#SYNC_MAP[@]}件"
if [[ "$DO_COMMIT" == "true" ]]; then
  echo "  コミット:     済み（要push）"
else
  echo "  コミット:     未実施"
fi
echo ""
ok "同期完了！"
echo ""
