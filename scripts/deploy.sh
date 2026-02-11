#!/usr/bin/env bash
# cursor-times-agent デプロイスクリプト
# リポジトリから ~/.cursor/ へエージェント・スキル・ルールを一括デプロイ
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
CURSOR_DIR="${HOME}/.cursor"
AGENTS_DIR="${CURSOR_DIR}/agents"
SKILLS_DIR="${CURSOR_DIR}/skills/cursor-times-agent"
RULES_DIR="${CURSOR_DIR}/rules"
BACKUP_DIR="${CURSOR_DIR}/.backup/cursor-times-agent/$(date +%Y%m%d_%H%M%S)"

# --- オプション解析 ---
DRY_RUN=false
SKIP_CONFIRM=false
DEPLOY_RULE=false
RULE_TARGET=""

usage() {
  echo "Usage: $(basename "$0") [OPTIONS]"
  echo ""
  echo "cursor-times-agent をリポジトリから ~/.cursor/ にデプロイします。"
  echo ""
  echo "Options:"
  echo "  --dry-run       実際にコピーせず、何が行われるかのみ表示"
  echo "  --yes, -y       確認プロンプトをスキップ"
  echo "  --with-rule     ルールファイルもデプロイ（グローバル: ~/.cursor/rules/）"
  echo "  --help, -h      このヘルプを表示"
  echo ""
  echo "デプロイされるファイル:"
  echo "  agent/cursor-times-agent.md    → ~/.cursor/agents/"
  echo "  skill/SKILL.md                 → ~/.cursor/skills/cursor-times-agent/"
  echo "  skill/references/*             → ~/.cursor/skills/cursor-times-agent/references/"
  echo "  persona/default.md             → ~/.cursor/skills/cursor-times-agent/templates/"
  echo "  rule/cursor-times-agent.mdc    → ~/.cursor/rules/ (--with-rule 指定時)"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)    DRY_RUN=true; shift ;;
    --yes|-y)     SKIP_CONFIRM=true; shift ;;
    --with-rule)  DEPLOY_RULE=true; shift ;;
    --help|-h)    usage; exit 0 ;;
    *) err "不明なオプション: $1"; usage; exit 1 ;;
  esac
done

echo ""
echo "========================================"
echo "  cursor-times-agent デプロイ"
echo "========================================"
echo ""

# ============================================
# Step 1: リポジトリの検証
# ============================================
info "Step 1: リポジトリの検証..."

REQUIRED_FILES=(
  "agent/cursor-times-agent.md"
  "skill/SKILL.md"
  "skill/references/ERROR_HANDLING.md"
  "skill/references/PERSONA_FORMAT.md"
  "skill/references/POSTING_FORMAT.md"
  "persona/default.md"
)

MISSING=false
for file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "${REPO_ROOT}/${file}" ]]; then
    err "必須ファイルが見つかりません: ${file}"
    MISSING=true
  fi
done

if [[ "$MISSING" == "true" ]]; then
  err "リポジトリが不完全です。セットアップを中断します。"
  exit 1
fi

ok "リポジトリ: ${REPO_ROOT}"
ok "必須ファイル: すべて存在"

# ============================================
# Step 2: デプロイ内容の表示
# ============================================
echo ""
info "Step 2: デプロイ内容..."
echo ""
echo "  📂 ソース: ${REPO_ROOT}"
echo "  📂 デプロイ先: ${CURSOR_DIR}"
echo ""
echo "  ファイルマッピング:"
echo "    agent/cursor-times-agent.md"
echo "      → ${AGENTS_DIR}/cursor-times-agent.md"
echo ""
echo "    skill/SKILL.md"
echo "      → ${SKILLS_DIR}/SKILL.md"
echo ""
echo "    skill/references/"
echo "      → ${SKILLS_DIR}/references/"
echo "        ├── ERROR_HANDLING.md"
echo "        ├── PERSONA_FORMAT.md"
echo "        └── POSTING_FORMAT.md"
echo ""
echo "    persona/default.md"
echo "      → ${SKILLS_DIR}/templates/persona-default.md"

if [[ "$DEPLOY_RULE" == "true" ]]; then
  echo ""
  echo "    rule/cursor-times-agent.mdc"
  echo "      → ${RULES_DIR}/cursor-times-agent.mdc"
fi

# ============================================
# Step 3: 既存ファイルの確認・バックアップ
# ============================================
echo ""
info "Step 3: 既存ファイルの確認..."

EXISTING_FILES=()
DEPLOY_TARGETS=(
  "${AGENTS_DIR}/cursor-times-agent.md"
  "${SKILLS_DIR}/SKILL.md"
  "${SKILLS_DIR}/references/ERROR_HANDLING.md"
  "${SKILLS_DIR}/references/PERSONA_FORMAT.md"
  "${SKILLS_DIR}/references/POSTING_FORMAT.md"
  "${SKILLS_DIR}/templates/persona-default.md"
)

if [[ "$DEPLOY_RULE" == "true" ]]; then
  DEPLOY_TARGETS+=("${RULES_DIR}/cursor-times-agent.mdc")
fi

for target in "${DEPLOY_TARGETS[@]}"; do
  if [[ -f "$target" ]]; then
    EXISTING_FILES+=("$target")
  fi
done

if [[ ${#EXISTING_FILES[@]} -gt 0 ]]; then
  warn "上書きされるファイル (${#EXISTING_FILES[@]}件):"
  for f in "${EXISTING_FILES[@]}"; do
    echo "    - ${f}"
  done
  echo ""
  info "バックアップ先: ${BACKUP_DIR}"
else
  ok "既存ファイルなし（新規デプロイ）"
fi

# ============================================
# Step 4: 確認プロンプト
# ============================================
if [[ "$DRY_RUN" == "true" ]]; then
  dry "ドライランモード: 実際のコピーは行いません"
elif [[ "$SKIP_CONFIRM" != "true" ]]; then
  echo ""
  read -rp "  デプロイを実行しますか？ (y/N): " CONFIRM
  if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    info "デプロイをキャンセルしました。"
    exit 0
  fi
fi

# ============================================
# Step 5: バックアップ
# ============================================
if [[ "$DRY_RUN" != "true" && ${#EXISTING_FILES[@]} -gt 0 ]]; then
  echo ""
  info "Step 5: バックアップ作成..."
  mkdir -p "$BACKUP_DIR"
  for f in "${EXISTING_FILES[@]}"; do
    rel="${f#${CURSOR_DIR}/}"
    backup_path="${BACKUP_DIR}/${rel}"
    mkdir -p "$(dirname "$backup_path")"
    cp "$f" "$backup_path"
  done
  ok "バックアップ: ${BACKUP_DIR}"
fi

# ============================================
# Step 6: デプロイ実行
# ============================================
echo ""
info "Step 6: デプロイ実行..."

deploy_file() {
  local src="$1"
  local dst="$2"
  local label="$3"

  if [[ "$DRY_RUN" == "true" ]]; then
    dry "コピー: ${label}"
    dry "  ${src} → ${dst}"
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    ok "デプロイ: ${label}"
  fi
}

# Agent定義
deploy_file \
  "${REPO_ROOT}/agent/cursor-times-agent.md" \
  "${AGENTS_DIR}/cursor-times-agent.md" \
  "agent/cursor-times-agent.md"

# Skill定義
deploy_file \
  "${REPO_ROOT}/skill/SKILL.md" \
  "${SKILLS_DIR}/SKILL.md" \
  "skill/SKILL.md"

# References
for ref_file in ERROR_HANDLING.md PERSONA_FORMAT.md POSTING_FORMAT.md; do
  deploy_file \
    "${REPO_ROOT}/skill/references/${ref_file}" \
    "${SKILLS_DIR}/references/${ref_file}" \
    "skill/references/${ref_file}"
done

# Persona テンプレート
deploy_file \
  "${REPO_ROOT}/persona/default.md" \
  "${SKILLS_DIR}/templates/persona-default.md" \
  "persona/default.md → templates/persona-default.md"

# Rule（オプション）
if [[ "$DEPLOY_RULE" == "true" ]]; then
  deploy_file \
    "${REPO_ROOT}/rule/cursor-times-agent.mdc" \
    "${RULES_DIR}/cursor-times-agent.mdc" \
    "rule/cursor-times-agent.mdc (グローバル)"
fi

# ============================================
# Step 7: デプロイ後の検証
# ============================================
echo ""
info "Step 7: デプロイ後の検証..."

if [[ "$DRY_RUN" == "true" ]]; then
  dry "検証スキップ（ドライランモード）"
else
  VERIFY_OK=true
  for target in "${DEPLOY_TARGETS[@]}"; do
    if [[ -f "$target" ]]; then
      ok "存在確認: $(basename "$target")"
    else
      err "見つかりません: ${target}"
      VERIFY_OK=false
    fi
  done

  if [[ "$VERIFY_OK" == "true" ]]; then
    ok "すべてのファイルがデプロイされました"
  else
    err "一部のファイルがデプロイに失敗しています"
  fi
fi

# ============================================
# サマリー
# ============================================
echo ""
echo "========================================"
echo "  デプロイ結果"
echo "========================================"
echo ""

if [[ "$DRY_RUN" == "true" ]]; then
  echo "  モード:       ドライラン（変更なし）"
else
  echo "  モード:       デプロイ完了"
fi
echo "  ソース:       ${REPO_ROOT}"
echo "  エージェント: ${AGENTS_DIR}/cursor-times-agent.md"
echo "  スキル:       ${SKILLS_DIR}/SKILL.md"
echo "  リファレンス: ${SKILLS_DIR}/references/ (3ファイル)"
echo "  テンプレート: ${SKILLS_DIR}/templates/persona-default.md"
if [[ "$DEPLOY_RULE" == "true" ]]; then
  echo "  ルール:       ${RULES_DIR}/cursor-times-agent.mdc"
else
  echo "  ルール:       未デプロイ（--with-rule で有効化）"
fi
if [[ ${#EXISTING_FILES[@]} -gt 0 && "$DRY_RUN" != "true" ]]; then
  echo "  バックアップ: ${BACKUP_DIR}"
fi
echo ""

if [[ "$DRY_RUN" != "true" ]]; then
  ok "デプロイ完了！Cursorを再起動すると反映されます"
  echo ""
  echo "  次のステップ:"
  echo "    1. Slack連携がまだの場合: bash scripts/setup.sh"
  echo "    2. Cursorを再起動してエージェント・スキルを有効化"
  echo "    3. タスク完了時に自動投稿が開始されます"
fi
echo ""
