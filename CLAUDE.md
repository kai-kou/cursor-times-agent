# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

タスク完了時にSlack分報（Times）チャンネルに自動投稿するCursor Subagent。
slack-fast-mcp MCPサーバー経由で、メンバーの人格設定（persona）に基づいたカジュアルな所感を生成・投稿する。

## アーカイブルール（重要）

- このリポジトリは**Cursor用のソースオブトゥルース**として維持
- Claude Code環境では `~/.claude/skills/times-agent/` に移行済み
- 新規機能追加・修正は移行先で実施すること
- 既存コードの参照・調査はOK

## アーキテクチャ

**Agent + Skill + Rule パターン**で構成。3つのコンポーネントが連携して動作する：

1. **Rule** (`rule/cursor-times-agent.mdc`): `alwaysApply: true` のグローバルルール。タスク完了を検知してSubagentをバックグラウンド起動するトリガー
2. **Agent** (`agent/cursor-times-agent.md`): Subagent定義。`model: fast`, `is_background: true`。入力パラメータ（project_path, member_name, session_summary, post_type）を受けて投稿処理を実行
3. **Skill** (`skill/SKILL.md`): 投稿ワークフローの詳細ロジック。セッション分析→人格読み込み→投稿文生成→Slack投稿の一連を制御

**処理フロー**: タスク完了 → Rule がトリガー → Agent をバックグラウンド起動 → Skill のワークフロー実行 → persona読み込み → 投稿文生成 → slack-fast-mcp の `slack_post_message` で投稿

**人格設定（persona）**: `{project_path}/persona/{member_name}.md` に配置。未発見時はデフォルトテンプレート（`persona/default.md`）から自動生成。`approved: true` で即投稿可能。

## デプロイ・セットアップ

```bash
# Slack App + slack-fast-mcp の対話式セットアップ
bash scripts/setup.sh

# ~/.cursor/ へのデプロイ（dry-run で確認）
bash scripts/deploy.sh --dry-run
bash scripts/deploy.sh

# cursor-agents-skills リポジトリへの同期（メンテナー向け）
bash scripts/sync-to-agents-skills.sh --dry-run
bash scripts/sync-to-agents-skills.sh --commit

# チャンネルID検索
bash scripts/find-channel-id.sh

# Slack接続テスト
bash scripts/test-connection.sh
```

### デプロイマッピング

| ソース | デプロイ先 |
|--------|-----------|
| `agent/cursor-times-agent.md` | `~/.cursor/agents/cursor-times-agent.md` |
| `skill/SKILL.md` | `~/.cursor/skills/cursor-times-agent/SKILL.md` |
| `skill/references/*` | `~/.cursor/skills/cursor-times-agent/references/*` |
| `persona/default.md` | `~/.cursor/skills/cursor-times-agent/templates/persona-default.md` |
| `rule/cursor-times-agent.mdc` | `~/.cursor/rules/cursor-times-agent.mdc`（`--with-rule` 指定時） |

## 人格設定（persona）

- `persona/{member_name}.md` に各メンバーの人格を定義
- 必須フィールド: approved, default_channel（チャンネルID）, hashtags, 投稿スタイルサンプル（3つ以上）
- `persona/*.md` は `.gitignore` で除外（`persona/default.md` のみ追跡対象）
- チャンネル指定は必ず**チャンネルID**（例: `C0AE6RT9NG4`）を使用。チャンネル名では `channel_not_found` エラーになる

## Slack投稿ルール

- 文字数: 投稿タイプにより20〜300文字（タスク完了: 100〜300, 進捗: 30〜100, 息抜き: 20〜80）
- 形式: Slack mrkdwn記法（`*太字*`, `_斜体_`, `:emoji:`）
- 末尾にpersona内の `hashtags` を付与
- `display_name` パラメータでslack-fast-mcpが `#member_name` を自動付与（curl利用時は手動付与が必要）

## MCP連携

- MCPサーバー: slack-fast-mcp（Go製シングルバイナリ、起動~10ms）
- 主要ツール: `slack_post_message`（channel, message, display_name）
- 設定: `~/.cursor/mcp.json` の env に `SLACK_BOT_TOKEN` を**値を直接記載**（`${ENV_VAR}` 形式は非対応）
- フォールバック: MCP不可時のみ curl で Slack API 直接呼び出し

## よくあるエラー

| エラー | 原因 | 対処 |
|--------|------|------|
| `invalid_auth` | SLACK_BOT_TOKEN無効 | mcp.jsonにトークン値を直接記載しているか確認 |
| `channel_not_found` | チャンネル名で指定 | チャンネルIDを使用する |
| MCP Tool Not Found | MCPサーバー未起動 | Cursor再起動。再起動後もダメならcurlフォールバック |
| display_nameタグ未付与 | バイナリが古い | slack-fast-mcp v0.1.0-12 以降に更新しCursor再起動 |
