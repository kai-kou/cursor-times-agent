# Cursor Times Agent セットアップガイド

**作成日**: 2026-02-10
**最終更新**: 2026-02-11

## 概要

Cursor Times Agentを利用するためのセットアップ手順です。
slack-fast-mcp MCPサーバー（v0.1.0+）を経由してSlack分報に自動投稿します。

---

## 前提条件

- Cursor IDE（v2.4+）がインストール済み
- Slackワークスペースへのアクセス権限
- Slack App作成権限（ワークスペース管理者またはApp作成許可）

---

## セットアップ手順

### Step 1: Slack App作成（初回のみ）

> **既にslack-fast-mcp用のSlack Appを作成済みの場合はスキップ**

1. [https://api.slack.com/apps](https://api.slack.com/apps) にアクセス
2. **「Create New App」** → **「From scratch」** を選択
3. App Name: `slack-fast-mcp`（任意の名前）
4. 利用するワークスペースを選択 → **「Create App」**

### Step 2: Bot Token Scopesの設定（初回のみ）

1. 左サイドバーの **「OAuth & Permissions」** をクリック
2. **「Bot Token Scopes」** で以下を追加：

| スコープ | 用途 | 必須 |
|---------|------|------|
| `chat:write` | メッセージ投稿 | ✅ |
| `channels:history` | チャンネル履歴取得 | ✅ |
| `channels:read` | チャンネル名→ID変換 | ✅ |
| `groups:history` | プライベートチャンネル履歴取得 | 任意 |
| `groups:read` | プライベートチャンネル名→ID変換 | 任意 |
| `users:read` | ユーザー名解決 | 任意 |

3. **「Install to Workspace」** → **「許可する」**
4. 表示された **Bot User OAuth Token**（`xoxb-`で始まる）を安全にコピー

### Step 3: 環境変数の設定

`~/.zshrc` に以下を追加：

```bash
# Slack Bot Token（Step 2で取得したトークン）
export SLACK_BOT_TOKEN="xoxb-your-token-here"

# デフォルト投稿先チャンネル（任意）
export SLACK_DEFAULT_CHANNEL="times-your-name"
```

設定を反映：

```bash
source ~/.zshrc
```

### Step 4: チャンネルIDの確認

**重要**: cursor-times-agentは**チャンネルID**（例: `C0AE6RT9NG4`）を使用します。チャンネル名では `channel_not_found` エラーになる場合があります。

チャンネルIDの確認方法：

**方法A: Slackアプリから確認**
1. 対象チャンネルを開く
2. チャンネル名をクリック → チャンネル詳細
3. 一番下に「チャンネルID」が表示される

**方法B: APIから確認**
```bash
curl -s "https://slack.com/api/conversations.list?types=public_channel,private_channel&limit=200" \
  -H "Authorization: Bearer ${SLACK_BOT_TOKEN}" | \
  python3 -c "import sys,json; [print(f'{c[\"id\"]} {c[\"name\"]}') for c in json.load(sys.stdin)['channels']]" | \
  grep "your-channel-name"
```

### Step 5: Botをチャンネルに招待

Slackで分報チャンネルを開き、以下のコマンドを実行：

```
/invite @slack-fast-mcp
```

> Botが見つからない場合は、Step 1-2のApp名を確認してください。

### Step 6: Cursor MCP設定

`~/.cursor/mcp.json` を作成/編集：

```json
{
  "mcpServers": {
    "slack-fast-mcp": {
      "command": "/path/to/slack-fast-mcp",
      "args": [],
      "env": {
        "SLACK_BOT_TOKEN": "xoxb-your-actual-token-here"
      }
    }
  }
}
```

> **注意**: `"${SLACK_BOT_TOKEN}"` のような環境変数参照は **Cursor MCP設定では展開されません**。トークン値を直接記載してください。

slack-fast-mcpバイナリの入手方法：
- [GitHub Releases](https://github.com/kai-kou/slack-fast-mcp/releases) からダウンロード
- またはソースからビルド: `go build -o slack-fast-mcp ./cmd/slack-fast-mcp`

### Step 7: 人格設定ファイルの配置

プロジェクトに人格設定ファイルを配置します。

**方法A: デフォルト人格を使用**

デフォルト人格「くろ（Kuro）」がすでに用意されています：
リポジトリの `persona/default.md`（デプロイ後は `~/.cursor/skills/cursor-times-agent/templates/persona-default.md`）

**方法B: プロジェクト固有の人格を作成**

プロジェクトのルートに `persona/{member_name}.md` を作成：

```markdown
# [Agent名] - 人格設定

## メタ情報
- approved: true
- version: 1.0.0
- created: YYYY-MM-DD
- updated: YYYY-MM-DD

## 投稿先設定
- default_channel: "チャンネルID"  # チャンネル名
- hashtags: ["#cursor", "#project-name"]

## 人格プロフィール
### 名前
[Agent名]

### 一人称
[ぼく/わたし等]

### ベースキャラクター
[キャラクター設定]

### 性格・トーン
- [性格特性]

### 口調の特徴
- 語尾: [パターン]
- 感嘆: [パターン]

### 投稿スタイルサンプル
[各投稿タイプのサンプル]

### 投稿で避けること
- [NG項目]
```

> `approved: true` に設定しないと投稿されません。

### Step 8: エージェントの配置確認

cursor-times-agentが以下のパスに配置されていることを確認：

```
~/.cursor/agents/cursor-times-agent.md    # サブエージェント定義
~/.cursor/skills/cursor-times-agent/      # Skill定義
  SKILL.md
  references/
    ERROR_HANDLING.md
    PERSONA_FORMAT.md
    POSTING_FORMAT.md
```

cursor-agents-skillsリポジトリから同期する場合：

```bash
rsync -av /path/to/cursor-agents-skills/agents/ ~/.cursor/agents/
rsync -av /path/to/cursor-agents-skills/skills/ ~/.cursor/skills/
```

---

## 動作確認

### 自動投稿の確認

Cursorで何かタスクを完了し、完了報告が行われた際に自動でSlack分報に投稿されることを確認。

### 手動投稿の確認

```
Cursorチャット: 今の作業を振り返ってtimesに投稿して
```

### curlで直接テスト

```bash
curl -s -X POST "https://slack.com/api/chat.postMessage" \
  -H "Authorization: Bearer ${SLACK_BOT_TOKEN}" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d '{"channel": "YOUR_CHANNEL_ID", "text": "テスト投稿 :cat:"}' | \
  python3 -c "import sys,json; d=json.load(sys.stdin); print('OK' if d['ok'] else f'Error: {d[\"error\"]}')"
```

---

## トラブルシューティング

### 投稿されない場合

| チェック項目 | 確認方法 |
|-------------|---------|
| MCP設定 | `~/.cursor/mcp.json` にslack-fast-mcpが設定されているか |
| トークン | mcp.json の env に値が**直接記載**されているか（`${ENV_VAR}` 形式は非対応） |
| Bot招待 | 分報チャンネルにBotが参加しているか |
| 人格承認 | persona ファイルの `approved` が `true` か |
| エージェント配置 | `~/.cursor/agents/cursor-times-agent.md` が存在するか |

### `invalid_auth` エラー

**原因**: SLACK_BOT_TOKEN が無効

**対処**:
1. `~/.cursor/mcp.json` でトークンが**直接記載**されているか確認
2. `${SLACK_BOT_TOKEN}` のような環境変数参照は**展開されない**
3. トークンの有効性を確認:
```bash
curl -s -X POST "https://slack.com/api/auth.test" \
  -H "Authorization: Bearer ${SLACK_BOT_TOKEN}" | python3 -m json.tool
```

### `channel_not_found` エラー

**原因**: チャンネル名で指定している

**対処**: チャンネルID（例: `C0AE6RT9NG4`）を使用する。Step 4でIDを確認。

### `not_in_channel` エラー

**原因**: Botがチャンネルに招待されていない

**対処**: `/invite @slack-fast-mcp` を実行

### MCPツールが見つからない

**原因**: slack-fast-mcpが起動していない

**対処**:
1. Cursorを再起動
2. mcp.json の `command` パスが正しいか確認
3. curlフォールバックで投稿可能（サブエージェントはcurl経由で投稿）

---

## アーキテクチャ

```
┌─────────────────────────────────────────────────┐
│  Cursor AI Agent（親）                          │
│  ┌──────────────────┐                           │
│  │ Global Rule      │  タスク完了検知            │
│  │ (15行トリガー)   │  → セッション要約生成      │
│  └────────┬─────────┘                           │
│           │ バックグラウンド起動                  │
│  ┌────────▼─────────┐                           │
│  │ cursor-times-    │  人格読み込み → 投稿生成   │
│  │ agent (Subagent) │  → curl投稿               │
│  │ model: fast      │                           │
│  └────────┬─────────┘                           │
│           │                                     │
│  ┌────────▼─────────┐  ┌─────────────────────┐  │
│  │ persona/*.md     │  │ Slack API (curl)    │  │
│  │ (人格設定)       │  │ chat.postMessage    │  │
│  └──────────────────┘  └──────────┬──────────┘  │
└───────────────────────────────────┼──────────────┘
                                    │
                          ┌─────────▼─────────┐
                          │ Slack Times Channel│
                          └───────────────────┘
```

## 関連ドキュメント

- [slack-fast-mcp連携ガイド](./slack-fast-mcp-integration.md) - ツール仕様・display_name対応
- [slack-fast-mcp README](https://github.com/kai-kou/slack-fast-mcp) - MCPサーバー本体
