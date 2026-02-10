# Cursor Times Agent セットアップガイド

**作成日**: 2026-02-10
**最終更新**: 2026-02-10

## 概要

Cursor Times Agentを利用するためのセットアップ手順です。
slack-fast-mcp MCPサーバーを経由してSlack分報に自動投稿します。

---

## 前提条件

- Cursor IDEがインストール済み
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

# デフォルト投稿先チャンネル（あなたの分報チャンネル名）
export SLACK_DEFAULT_CHANNEL="times-your-name"
```

設定を反映：

```bash
source ~/.zshrc
```

### Step 4: Botをチャンネルに招待

Slackで分報チャンネルを開き、以下のコマンドを実行：

```
/invite @slack-fast-mcp
```

### Step 5: slack-fast-mcp MCPサーバーの設定

Cursorの MCP設定ファイルに slack-fast-mcp を追加します。

**方法A: ワークスペース設定（推奨）**

`/Users/kai.ko/dev/.cursor/mcp.json` を作成/編集：

```json
{
  "mcpServers": {
    "slack-fast-mcp": {
      "command": "/Users/kai.ko/dev/01_active/slack-fast-mcp/slack-fast-mcp",
      "args": [],
      "env": {
        "SLACK_BOT_TOKEN": "${SLACK_BOT_TOKEN}"
      }
    }
  }
}
```

**方法B: グローバル設定**

`~/.cursor/mcp.json` を作成/編集：

```json
{
  "mcpServers": {
    "slack-fast-mcp": {
      "command": "/Users/kai.ko/dev/01_active/slack-fast-mcp/slack-fast-mcp",
      "args": [],
      "env": {
        "SLACK_BOT_TOKEN": "${SLACK_BOT_TOKEN}"
      }
    }
  }
}
```

### Step 6: 人格設定の承認

初回投稿時にCursorが人格設定を提示して承認を求めます。
人格設定ファイル: `/Users/kai.ko/dev/01_active/cursor-times-agent/persona/default.md`

---

## 動作確認

Cursorで何かタスクを完了した際に、自動的にSlack分報に投稿されることを確認してください。

手動で確認する場合：

```
Cursorチャット: 今の作業を振り返ってtimesに投稿して
```

---

## トラブルシューティング

### 投稿されない場合

1. **MCPサーバー設定を確認**: `.cursor/mcp.json` にslack-fast-mcpが設定されているか
2. **環境変数を確認**: `echo $SLACK_BOT_TOKEN` でトークンが表示されるか
3. **Botの招待を確認**: 分報チャンネルにBotが参加しているか
4. **人格承認を確認**: `persona/default.md` の `approved` が `true` になっているか

### `invalid_auth` エラー

- トークンが無効または期限切れです
- Slack API サイトでトークンを再生成してください

### `not_in_channel` エラー

- Botがチャンネルに招待されていません
- `/invite @slack-fast-mcp` を実行してください

### `channel_not_found` エラー

- チャンネル名が正しいか確認してください
- `#` プレフィックスは不要です

---

## 人格のカスタマイズ

投稿の口調やスタイルを変更したい場合：

1. `/Users/kai.ko/dev/01_active/cursor-times-agent/persona/default.md` を編集
2. `approved` を `false` に変更
3. 次回投稿時にCursorが再承認を求めます
