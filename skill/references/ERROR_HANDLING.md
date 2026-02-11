# エラーハンドリング詳細

## エラー一覧と対処

### 1. invalid_auth（認証エラー）

**原因**: `SLACK_BOT_TOKEN` が無効
**対処**:
1. `~/.cursor/mcp.json` の `slack-fast-mcp` → `env` → `SLACK_BOT_TOKEN` にトークン値が**直接記載**されているか確認
2. `${ENV_VAR}` 形式では展開されない（Cursor MCP仕様）
3. トークンの有効性を確認:
```bash
curl -s -X POST "https://slack.com/api/auth.test" \
  -H "Authorization: Bearer ${SLACK_BOT_TOKEN}"
```

### 2. channel_not_found（チャンネル未検出）

**原因**: チャンネル名で指定している
**対処**: チャンネルIDを使用する（例: `C0AE6RT9NG4`）
**ID確認方法**:
```bash
curl -s "https://slack.com/api/conversations.list?types=public_channel,private_channel" \
  -H "Authorization: Bearer ${SLACK_BOT_TOKEN}" | jq '.channels[] | select(.name=="チャンネル名") | .id'
```

### 3. MCP Tool Not Found

**原因**: slack-fast-mcp MCPサーバーが起動していない、またはCursor再起動が必要
**対処**:
1. Cursorを再起動してMCPサーバーを再接続
2. `~/.cursor/mcp.json` にslack-fast-mcpの設定があるか確認
3. 再起動後もMCPが使えない場合、curlフォールバックを使用:
```bash
curl -s -X POST "https://slack.com/api/chat.postMessage" \
  -H "Authorization: Bearer ${SLACK_BOT_TOKEN}" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d '{"channel": "チャンネルID", "text": "投稿文"}'
```
4. レスポンスの `ok` フィールドで成功確認

**補足**: Skill経由・Subagent経由のいずれでもMCPツールは利用可能（2026-02-11検証済み）。MCPが使えない場合は環境設定の問題である可能性が高い。

### 4. 人格ファイル未発見

**原因**: `{project_path}/persona/{member_name}.md` が存在しない
**対処**: テンプレート `~/.cursor/skills/cursor-times-agent/templates/persona-default.md` をベースに自動生成。テンプレートも無い場合は投稿を中止。

### 5. 人格未承認

**原因**: 人格ファイルの `approved` が `false` または未設定
**対処**: 投稿を中止し、ユーザーに人格承認を依頼。

## セットアップガイド

初回セットアップや問題解決の詳細は以下を参照：
- リポジトリ: `docs/setup-guide.md`
- GitHub: https://github.com/kai-kou/cursor-times-agent
