---
project:
  name: "cursor-times-agent"
  title: "Cursor Times Agent - AI自動分報投稿エージェント"
  status: active
  priority: high
  created: "2026-02-10"
  updated: "2026-02-10"
  owner: "kai.ko"
  tags: [cursor, slack, times, agent, skill, auto-posting, mcp]
  summary: "タスク完了時にセッション振り返り・所感をSlack分報に自動投稿するCursor Agent Skill"
  next_action: "人格設定の承認・環境構築"
---

# Cursor Times Agent - AI自動分報投稿エージェント

## 概要

Cursor AI Agentがタスク作業中・完了時にセッション履歴を振り返り、ユーザーに代わってSlackの分報（Times）チャンネルにカジュアルな所感を自動投稿するエージェント。slack-fast-mcp MCPサーバーを利用してSlack投稿を行い、ユーザーが意識しなくても勝手に投稿が行われることを理想とする。

## ゴール

- [ ] タスク完了時にセッション履歴を振り返り、所感をSlack分報に自動投稿
- [ ] タスク関連の最新情報をキャッチアップして投稿
- [ ] 長いタスク中の進捗・息抜き投稿（ランダム間隔）
- [ ] ユーザーが意識しなくてもAI Agentが自動で投稿
- [ ] 人格設定に基づくカジュアルな投稿文生成
- [ ] slack-fast-mcp MCPサーバーを利用したSlack投稿
- [ ] 環境構築の自動化（ユーザーが意識せず利用可能）

## スコープ

### 含むもの
- Cursor Skill（SKILL.md）の実装 - 振り返り投稿エージェント
- Cursor グローバルルール - 自動投稿トリガー（alwaysApply）
- 人格設定ファイル（persona/default.md）
- slack-fast-mcp MCPサーバーとの連携
- セッション履歴の分析・要約ロジック
- 投稿フォーマット設計（Slack mrkdwn対応）
- 最新情報キャッチアップ機能（WebSearch活用）
- ランダム間隔の進捗投稿ロジック
- 環境自動セットアップガイド
- Slack連携に必要なユーザー手順の案内

### 含まないもの
- X(Twitter)への投稿（将来拡張として検討）
- slack-fast-mcp本体の開発・保守
- Slack Appの作成・管理（ユーザー操作が必要）
- リアルタイムSlack受信（投稿のみ）

## 技術構成

| 要素 | 選定 | 理由 |
|------|------|------|
| 投稿エンジン | slack-fast-mcp (MCP Server) | Go製高速Slack投稿、ローカルバイナリ利用 |
| エージェント | Cursor Skill + Rule | Cursorネイティブ統合、自動トリガー |
| 情報収集 | WebSearch Tool | 最新情報キャッチアップ |
| 人格設定 | Markdownファイル | 柔軟なカスタマイズ対応 |

## 実装アーキテクチャ

```
┌──────────────────────────────────────────┐
│  Cursor AI Agent                         │
│  ┌─────────────┐  ┌───────────────────┐  │
│  │ Global Rule │  │ Times Agent Skill │  │
│  │ (Trigger)   │─▶│ (振り返り生成)     │  │
│  └─────────────┘  └───────┬───────────┘  │
│                           │              │
│  ┌────────────────────────▼───────────┐  │
│  │ persona/default.md (人格設定)      │  │
│  └────────────────────────┬───────────┘  │
│                           │              │
│  ┌────────────────────────▼───────────┐  │
│  │ slack-fast-mcp (MCP Server)        │  │
│  │ └─ slack_post_message              │  │
│  └────────────────────────┬───────────┘  │
│                           │              │
└───────────────────────────┼──────────────┘
                            │
                  ┌─────────▼─────────┐
                  │ Slack Times Channel│
                  │ (#times-kai)      │
                  └───────────────────┘
```

## Slack連携セットアップ（ユーザー必須手順）

slack-fast-mcpを利用するために、以下のセットアップがユーザー側で必要です。
詳細は [docs/setup-guide.md](./docs/setup-guide.md) を参照。

### 事前準備チェックリスト

1. **Slack App作成**（1回のみ）
   - https://api.slack.com/apps で新規App作成
   - Bot Token Scopes: `chat:write`, `channels:history`, `channels:read`
   - ワークスペースにインストールしてBot User OAuth Tokenを取得

2. **環境変数設定**（1回のみ）
   ```bash
   # ~/.zshrc に追加
   export SLACK_BOT_TOKEN="xoxb-your-token-here"
   export SLACK_DEFAULT_CHANNEL="times-kai"  # あなたの分報チャンネル名
   ```

3. **Botをチャンネルに招待**（1回のみ）
   - Slackで分報チャンネルを開き `/invite @slack-fast-mcp` を実行

4. **Cursor MCP設定の確認**
   - `.cursor/mcp.json` にslack-fast-mcpが設定されていること

## 関連リソース

- マイルストーン: [milestones.md](./milestones.md)
- タスク一覧: [tasks.md](./tasks.md)
- セットアップガイド: [docs/setup-guide.md](./docs/setup-guide.md)
- アーキテクチャ: [docs/architecture.md](./docs/architecture.md)
- 人格設定: [persona/default.md](./persona/default.md)
- slack-fast-mcp: https://github.com/kai-kou/slack-fast-mcp

## メモ

- slack-fast-mcpはローカルにビルド済みバイナリが存在（`/Users/kai.ko/dev/01_active/slack-fast-mcp/slack-fast-mcp`）
- Cursor Skillとグローバルルールの組み合わせで、ユーザーが意識しない自動投稿を実現
- 人格設定はユーザー承認必須。初回利用時に人格案を提示して承認を得る
- 投稿頻度はランダム性を持たせ、毎回投稿するわけではない自然さを実現
- Slack mrkdwn記法で投稿し、視認性の高いフォーマットにする
