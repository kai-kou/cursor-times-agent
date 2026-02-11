---
project:
  name: "cursor-times-agent"
  title: "Cursor Times Agent - AI自動分報投稿エージェント"
  status: active
  priority: high
  created: "2026-02-10"
  updated: "2026-02-11"
  owner: "kai.ko"
  tags: [cursor, slack, times, agent, subagent, skill, auto-posting, mcp]
  summary: "タスク完了時にセッション振り返り・所感をSlack分報に自動投稿するCursor Subagent"
---

# Cursor Times Agent - AI自動分報投稿エージェント

Cursor AI Agentがタスク完了時にセッション履歴を振り返り、Slackの分報（Times）チャンネルにカジュアルな所感を自動投稿するエージェント。

## Quick Start

### 1. リポジトリをクローン

```bash
git clone https://github.com/kai-kou/cursor-times-agent.git
cd cursor-times-agent
```

### 2. Slack Appを準備（初回のみ）

1. https://api.slack.com/apps で新規App作成
2. Bot Token Scopes: `chat:write`, `channels:history`, `channels:read`
3. ワークスペースにインストール → Bot User OAuth Token を取得
4. 分報チャンネルでBotを招待: `/invite @your-bot-name`

### 3. slack-fast-mcp をインストール

```bash
# GitHub Releases からダウンロード（macOS arm64の例）
curl -LO https://github.com/kai-kou/slack-fast-mcp/releases/latest/download/slack-fast-mcp_darwin_arm64.tar.gz
tar xzf slack-fast-mcp_darwin_arm64.tar.gz
sudo mv slack-fast-mcp /usr/local/bin/
```

### 4. Slack連携セットアップ

```bash
# 対話式セットアップ（トークン設定・接続テスト・MCP設定を一括実行）
bash scripts/setup.sh
```

### 5. Cursorにデプロイ

```bash
# dry-run で確認
bash scripts/deploy.sh --dry-run

# 実行（バックアップ自動作成）
bash scripts/deploy.sh
```

### 6. Cursorを再起動

エージェント・スキル・ルールが有効化され、タスク完了時に自動投稿が開始されます。

## 機能

- **タスク完了振り返り投稿**: タスク完了時にセッション履歴を分析し、カジュアルな所感を自動投稿
- **最新情報キャッチアップ**: 作業で使った技術の最新情報をWebSearchで調査して共有
- **進捗・息抜きつぶやき**: 長いタスク中にランダム間隔で進捗報告や一息投稿
- **人格ベースの投稿**: プロジェクトごとのAI Agent人格に基づくカジュアルな文体
- **人格ファイル自動生成**: 未設定のプロジェクトでもテンプレートから即座に自動生成

## リポジトリ構成

```
cursor-times-agent/
├── agent/
│   └── cursor-times-agent.md       # Subagent定義（ソースオブトゥルース）
├── skill/
│   ├── SKILL.md                     # Skill定義
│   └── references/                  # リファレンスドキュメント
│       ├── ERROR_HANDLING.md
│       ├── PERSONA_FORMAT.md
│       └── POSTING_FORMAT.md
├── rule/
│   └── cursor-times-agent.mdc      # 自動トリガールール（alwaysApply）
├── persona/
│   └── default.md                   # デフォルト人格（くろ/Kuro）
├── scripts/
│   ├── deploy.sh                    # ~/.cursor/ へのデプロイ
│   ├── sync-to-agents-skills.sh    # cursor-agents-skills への同期（メンテナー向け）
│   ├── setup.sh                     # Slack/MCP セットアップ
│   ├── find-channel-id.sh          # チャンネルID検索ヘルパー
│   └── test-connection.sh          # 接続テスト
├── docs/
│   ├── setup-guide.md               # 詳細セットアップガイド
│   ├── architecture.md              # アーキテクチャ設計
│   └── slack-fast-mcp-integration.md
└── README.md
```

## デプロイマッピング

`scripts/deploy.sh` で以下のファイルが `~/.cursor/` にデプロイされます：

| ソース（リポジトリ） | デプロイ先 |
|---------------------|-----------|
| `agent/cursor-times-agent.md` | `~/.cursor/agents/cursor-times-agent.md` |
| `skill/SKILL.md` | `~/.cursor/skills/cursor-times-agent/SKILL.md` |
| `skill/references/*` | `~/.cursor/skills/cursor-times-agent/references/*` |
| `persona/default.md` | `~/.cursor/skills/cursor-times-agent/templates/persona-default.md` |
| `rule/cursor-times-agent.mdc` | `~/.cursor/rules/cursor-times-agent.mdc`（`--with-rule` 指定時） |

## アーキテクチャ

```
┌─────────────────────────────────────────────────┐
│  Cursor AI Agent（親）                          │
│  ┌──────────────────┐                           │
│  │ Global Rule      │  タスク完了検知            │
│  │ (alwaysApply)    │  → セッション要約生成      │
│  └────────┬─────────┘                           │
│           │ バックグラウンド起動                  │
│  ┌────────▼─────────┐                           │
│  │ cursor-times-    │  人格読み込み → 投稿生成   │
│  │ agent (Subagent) │  → Slack投稿              │
│  │ model: fast      │                           │
│  └────────┬─────────┘                           │
│           │                                     │
│  ┌────────▼─────────┐  ┌─────────────────────┐  │
│  │ persona/*.md     │  │ Slack API           │  │
│  │ (人格設定)       │  │ chat.postMessage    │  │
│  └──────────────────┘  └──────────┬──────────┘  │
└───────────────────────────────────┼──────────────┘
                                    │
                          ┌─────────▼─────────┐
                          │ Slack Times Channel│
                          └───────────────────┘
```

## 人格設定のカスタマイズ

デフォルト人格「くろ（Kuro）」が `persona/default.md` に定義されています。

プロジェクト固有の人格を作成する場合は、プロジェクトルートに `persona/{member_name}.md` を配置してください。人格ファイルが無い場合はデフォルトテンプレートから自動生成されます。

詳細フォーマット: [skill/references/PERSONA_FORMAT.md](./skill/references/PERSONA_FORMAT.md)

## cursor-agents-skills との連携（メンテナー向け）

このリポジトリがソースオブトゥルースです。変更後に [cursor-agents-skills](https://github.com/kai-kou/cursor-agents-skills) への同期が必要な場合：

```bash
# 差分確認
bash scripts/sync-to-agents-skills.sh --dry-run

# 同期実行
bash scripts/sync-to-agents-skills.sh

# 同期 + 自動コミット
bash scripts/sync-to-agents-skills.sh --commit
```

## 関連リソース

- [セットアップガイド](./docs/setup-guide.md)
- [slack-fast-mcp連携ガイド](./docs/slack-fast-mcp-integration.md)
- [slack-fast-mcp](https://github.com/kai-kou/slack-fast-mcp)
- [cursor-agents-skills](https://github.com/kai-kou/cursor-agents-skills)

## 開発管理

- [マイルストーン](./milestones.md)
- [タスク一覧](./tasks.md)
