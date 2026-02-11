# slack-fast-mcp 連携ガイド

## 概要

cursor-times-agent は [slack-fast-mcp](https://github.com/kai-kou/slack-fast-mcp) を利用してSlackへの投稿を行います。
このドキュメントでは連携仕様、対応バージョン、利用可能なツールを管理します。

## 対応バージョン

| 項目 | 値 |
|------|-----|
| slack-fast-mcp | v0.1.0 |
| 最終確認日 | 2026-02-11 |
| リポジトリ | https://github.com/kai-kou/slack-fast-mcp |
| バイナリパス | `$(command -v slack-fast-mcp)` or `/usr/local/bin/slack-fast-mcp` |

## 利用可能なMCPツール

### 1. slack_post_message（メッセージ投稿）

cursor-times-agentのメイン投稿に使用。

| パラメータ | 必須 | 説明 |
|-----------|------|------|
| `channel` | No | チャンネル名 or チャンネルID。省略時はデフォルトチャンネル |
| `message` | Yes | メッセージ本文（Slack mrkdwn対応） |
| `display_name` | No | 送信者の表示名。指定時にメッセージ末尾に `#display_name` を自動付与 |

**レスポンス**: `ok`, `channel`, `channel_name`, `ts`, `message`, `permalink`

**cursor-times-agentでの使い方**:
- `channel`: 人格設定の `default_channel`（チャンネルID推奨）
- `message`: 生成した投稿文
- `display_name`: `member_name`（AI Agent人格識別用）

### 2. slack_get_history（履歴取得）

投稿前の重複チェックや、スレッド返信のための親メッセージ `ts` 取得に活用可能。

| パラメータ | 必須 | 説明 |
|-----------|------|------|
| `channel` | No | チャンネル名 or チャンネルID |
| `limit` | No | 取得件数（1-100、デフォルト10） |
| `oldest` | No | 開始タイムスタンプ（Unix） |
| `latest` | No | 終了タイムスタンプ（Unix） |

**レスポンス**: `ok`, `channel`, `channel_name`, `messages`, `has_more`, `count`

**cursor-times-agentでの活用案**:
- 投稿前に直近の投稿を確認し、同一内容の重複投稿を防止
- 今日の投稿一覧を取得し、投稿頻度を制御

### 3. slack_post_thread（スレッド返信）

関連する複数の投稿をスレッドにまとめる場合に使用。

| パラメータ | 必須 | 説明 |
|-----------|------|------|
| `channel` | No | チャンネル名 or チャンネルID |
| `thread_ts` | Yes | 親メッセージのタイムスタンプ |
| `message` | Yes | 返信メッセージ本文 |
| `display_name` | No | 送信者の表示名 |

**レスポンス**: `ok`, `channel`, `channel_name`, `ts`, `thread_ts`, `message`, `permalink`

**cursor-times-agentでの活用案**:
- タスク進捗→完了を同一スレッドにまとめる
- 最新情報キャッチアップを元の作業投稿のスレッドに追加

## 投稿方法の優先順位

Skill経由・Subagent経由のいずれでもMCPツールが利用可能（2026-02-11検証済み）。

1. **MCP（推奨）**: `slack_post_message` MCPツールで投稿
   - `display_name` パラメータで `member_name` を渡すと、自動で末尾に `#member_name` が付与される
   - Skill経由・Subagent経由の両方で利用可能
2. **curlフォールバック**: MCPツールが検出できない環境でのみ使用
   - `display_name` は自前でメッセージ末尾に `#member_name` を追加する必要あり

### MCP投稿（推奨）

```
slack_post_message:
  channel: C0AE6RT9NG4  (チャンネルID)
  message: "投稿文\n#cursor #dev"
  display_name: kuro  (自動で #kuro が付与される)
```

### curlフォールバック（MCPが使えない場合のみ）

```bash
curl -s -X POST "https://slack.com/api/chat.postMessage" \
  -H "Authorization: Bearer ${SLACK_BOT_TOKEN}" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d '{"channel": "C0AE6RT9NG4", "text": "投稿文\n#cursor #dev #kuro"}'
```

## display_name ハッシュタグ付与ルール

### MCP利用時（自動）

`display_name` パラメータを指定すると、slack-fast-mcp が `appendDisplayNameTag` で自動的にメッセージ末尾に `#member_name` を付与する。手動での付与は不要。

### curlフォールバック時（手動）

slack-fast-mcp の `appendDisplayNameTag` と同じロジックを手動で適用：

1. 投稿文の末尾行がハッシュタグ行（`#` で始まる）の場合 → 同じ行に `#member_name` を追記
2. ハッシュタグ行がない場合 → 改行して `#member_name` を追加

**例**:
```
入力: "作業が終わったにゃ\n#cursor #dev"
出力: "作業が終わったにゃ\n#cursor #dev #kuro"

入力: "作業が終わったにゃ"
出力: "作業が終わったにゃ\n#kuro"
```

## MCP設定

`~/.cursor/mcp.json` での設定:

```json
{
  "mcpServers": {
    "slack-fast-mcp": {
      "command": "/usr/local/bin/slack-fast-mcp",
      "args": [],
      "env": {
        "SLACK_BOT_TOKEN": "xoxb-xxxxxx（直接記載、${ENV_VAR}形式は非対応）"
      }
    }
  }
}
```

## 環境変数

| 変数名 | 必須 | 説明 |
|--------|------|------|
| `SLACK_BOT_TOKEN` | Yes | Slack Bot Token（`xoxb-` プレフィックス） |
| `SLACK_DEFAULT_CHANNEL` | No | デフォルト投稿先チャンネル |
| `SLACK_DISPLAY_NAME` | No | デフォルトの表示名 |

## アップデート追従

slack-fast-mcp の新バージョンがリリースされた場合、以下を確認・更新：

1. **リリースノート確認**: `gh release list --repo kai-kou/slack-fast-mcp`
2. **新ツール/パラメータ**: このドキュメントの「利用可能なMCPツール」を更新
3. **エージェント定義更新**: `agent/cursor-times-agent.md` および `skill/SKILL.md` を更新
4. **バイナリ更新**: 必要に応じてバイナリを差し替え
5. **対応バージョン更新**: このドキュメント冒頭の対応バージョンを更新
