---
milestones:
  total: 7
  completed: 7
  in_progress: 0
  overall_progress: 100
---

# マイルストーン管理

**プロジェクト**: cursor-times-agent
**最終更新**: 2026-02-11 20:10

---

## 全体スケジュール

```
【Phase 1: 基盤構築】       2026-02-10 〜 2026-02-14  ✅ 前倒し完了(02/10)
【Phase 2: コア機能】       2026-02-12 〜 2026-02-17  ✅ 前倒し完了(02/10)
【Phase 3: 拡張・改善】     2026-02-17 〜 2026-02-21  ✅ 前倒し完了(02/10)
【Phase 4: UX改善】         2026-02-11                ✅ 完了(02/11)
【Phase 5: 単体パッケージ化】2026-02-11                ✅ 完了(02/11)
【Phase 6: MCP-first化】    2026-02-11                ✅ 完了(02/11)
【Phase 7: メンバー識別改善】2026-02-11                ✅ 完了(02/11)
```

---

## 進捗サマリー

| マイルストーン | 期限 | ステータス | 進捗率 |
|--------------|------|-----------|--------|
| M1: 基盤構築 - Skill/Rule配置・人格承認 | 2026-02-14 | ✅ 完了 | 100% |
| M2: コア機能 - 自動投稿動作確認 | 2026-02-17 | ✅ 完了 | 100% |
| M3: 拡張・改善 - 全機能完成・ドキュメント整備 | 2026-02-21 | ✅ 完了 | 100% |
| M4: UX改善 - 人格ファイル自動生成 | 2026-02-11 | ✅ 完了 | 100% |
| M5: 単体パッケージ化 - git clone→即利用可能 | 2026-02-11 | ✅ 完了 | 100% |
| M6: MCP-first化 - Subagent投稿のMCP統一 | 2026-02-11 | ✅ 完了 | 100% |
| M7: メンバー識別改善 - display_nameハッシュタグ有効化 | 2026-02-11 | ✅ 完了 | 100% |

**全体進捗**: 100% 🎉

---

## M1: 基盤構築 - Skill/Rule配置・人格承認

**期限**: 2026-02-14
**ステータス**: ✅ 完了（2026-02-10 前倒し完了）

### 完了条件
- [x] 人格設定がユーザー承認済み（くろ/Kuro、ねこ口調）
- [x] slack-fast-mcp MCPサーバーが利用可能（MCP設定修正済み）
- [x] Cursor Skill（SKILL.md）が配置され動作確認済み
- [x] グローバルルール（自動トリガー）が配置済み（dev/.cursor/rules/）
- [x] 投稿フォーマットが設計済み（SKILL.md Step3 + personaサンプル）
- [x] マルチ人格対応（project_path + member_name インターフェース）
- [x] ルール最小化 + Subagent化（92行→15行、cursor-agents-skills連携）

### 成果物
- [x] `~/.cursor/agents/cursor-times-agent.md`（サブエージェント定義）
- [x] `~/.cursor/skills/cursor-times-agent/SKILL.md` + `references/`
- [x] `dev/.cursor/rules/cursor-times-agent.mdc`（alwaysApply、15行）
- [x] `persona/default.md`（人格設定ファイル、承認済み）

---

## M2: コア機能 - 自動投稿動作確認

**期限**: 2026-02-17
**ステータス**: ✅ 完了（2026-02-10 前倒し完了）

### 完了条件
- [x] タスク完了時に振り返り所感がSlackに自動投稿される
- [x] セッション履歴の分析・要約が適切に行われる
- [x] 人格設定に基づくカジュアルな文体で投稿される（改善前後テスト比較で品質確認）
- [x] 最新情報キャッチアップ投稿が動作する（post_type=catchup）
- [x] slack-fast-mcp v0.1.0 display_name 対応

### 成果物
- [x] サブエージェントE2Eテスト成功（curl経由Slack投稿確認）
- [x] 投稿文生成プロンプト改善（口調バリエーション・カジュアルさ強化）
- [x] post_type対応（task_complete/catchup/progress/break）
- [x] `docs/slack-fast-mcp-integration.md`（連携ガイド）

---

## M3: 拡張・改善 - 全機能完成・ドキュメント整備

**期限**: 2026-02-21
**ステータス**: ✅ 完了（2026-02-10 前倒し完了）

### 完了条件
- [x] ランダム間隔の進捗投稿が動作する（post_type=progress/break）
- [x] 環境自動セットアップが機能する（scripts/setup.sh）
- [x] セットアップガイドが完成している（docs/setup-guide.md 全面改訂）
- [x] X(Twitter)連携の調査・設計が完了（調査のみ、実装は将来要望時）

### 成果物
- [x] `scripts/setup.sh`（対話式7ステップセットアップ）
- [x] `scripts/find-channel-id.sh`（チャンネルID検索ヘルパー）
- [x] `scripts/test-connection.sh`（接続・投稿テスト）
- [x] `docs/setup-guide.md`（全面改訂版）
- [x] X連携調査結果（API料金体系、x-twitter-mcp-server、リスク評価）

---

## M4: UX改善 - 人格ファイル自動生成

**期限**: 2026-02-11
**ステータス**: ✅ 完了（2026-02-11）

### 完了条件
- [x] persona未発見時にdefault.mdをテンプレートとして自動生成される
- [x] Subagent定義（Step 1）に自動生成ロジックが組み込まれている
- [x] Skill定義（Step 0）に自動生成ロジックが組み込まれている
- [x] エラーハンドリングドキュメントが「自動生成」に更新されている
- [x] PERSONA_FORMAT.mdにテンプレート用途が明記されている
- [x] ~/.cursor/ への同期デプロイが完了している

### 成果物
- [x] `~/.cursor/agents/cursor-times-agent.md`（Step 1 自動生成対応）
- [x] `skill/SKILL.md` + `~/.cursor/skills/cursor-times-agent/SKILL.md`（Step 0 自動生成対応）
- [x] `references/ERROR_HANDLING.md`（自動生成手順追記）
- [x] `references/PERSONA_FORMAT.md`（テンプレート用途・調整内容追記）

---

## M5: 単体パッケージ化 - git clone→即利用可能

**期限**: 2026-02-11
**ステータス**: ✅ 完了（2026-02-11）

### 完了条件
- [x] Subagent定義・references/ がリポジトリに含まれている（ソースオブトゥルース化）
- [x] ハードコードパスが除去され、ポータブルなパス参照になっている
- [x] deploy.sh でリポジトリから ~/.cursor/ への一括デプロイが可能
- [x] sync-to-agents-skills.sh でcursor-agents-skillsへの同期が可能
- [x] README.md に Quick Start（git clone → deploy → 即利用）が記載されている
- [x] 管理ドキュメント（tasks.md / milestones.md）が更新されている

### 成果物
- [x] `agent/cursor-times-agent.md`（Subagent定義、リポジトリに追加）
- [x] `skill/references/`（ERROR_HANDLING.md, PERSONA_FORMAT.md, POSTING_FORMAT.md）
- [x] `scripts/deploy.sh`（dry-run・バックアップ・対話式デプロイ）
- [x] `scripts/sync-to-agents-skills.sh`（diff表示・自動コミット対応）
- [x] `README.md`（Quick Start中心に全面改訂）

---

## M6: MCP-first化 - Subagent投稿のMCP統一

**期限**: 2026-02-11
**ステータス**: ✅ 完了（2026-02-11）

### 完了条件
- [x] SubagentからMCPツール（slack_post_message）で投稿可能であることを検証済み
- [x] Subagent定義（agent/cursor-times-agent.md）がMCP-first + curlフォールバック構成になっている
- [x] SKILL.mdのdisplay_nameパラメータが正しく記載されている（username→display_name修正）
- [x] 連携ドキュメント（slack-fast-mcp-integration.md）がMCP-first前提に改訂されている
- [x] ERROR_HANDLING.mdのMCP未検出フローが改善されている
- [x] 管理ドキュメント（tasks.md / milestones.md）が更新されている

### 成果物
- [x] `agent/cursor-times-agent.md`（Step 3: MCP推奨 + curlフォールバック）
- [x] `skill/SKILL.md`（Step 4: display_nameパラメータ修正）
- [x] `docs/slack-fast-mcp-integration.md`（投稿方法の優先順位をMCP-firstに改訂）
- [x] `skill/references/ERROR_HANDLING.md`（MCP未検出フロー改善）

### 背景・判断
- 初期開発時「サブエージェントからMCPツールは利用不可」と想定していたが、2026-02-11の検証で利用可能と判明
- generalPurposeサブエージェントから `mcp_slack-fast-mcp_slack_post_message` で投稿成功を確認
- curlフォールバックはMCPが検出できない環境向けに残存

---

## M7: メンバー識別改善 - display_nameハッシュタグ有効化

**期限**: 2026-02-11
**ステータス**: ✅ 完了（2026-02-11）

### 完了条件
- [x] slack-fast-mcpバイナリがdisplay_nameパラメータ対応版に更新されている
- [x] display_nameパラメータでの投稿テストが成功し、#member_nameハッシュタグが付与されている
- [x] バイナリバージョン要件がドキュメントに明記されている
- [x] display_nameが効かない場合のトラブルシュートがERROR_HANDLING.mdに追加されている
- [x] 管理ドキュメント（tasks.md / milestones.md）が更新されている

### 成果物
- [x] slack-fast-mcp バイナリ更新（v0.1.0-12-gbea5df3）
- [x] `docs/slack-fast-mcp-integration.md`（バージョン要件セクション追加）
- [x] `skill/references/ERROR_HANDLING.md`（display_nameトラブルシュート追加）

### 背景・判断
- POから「誰が投稿したのかわからない」との報告
- slack-fast-mcpソースにはdisplay_name機能が実装済みだったが、MCPで使用中のバイナリがdisplay_name追加前のビルド（02/10 20:05）だったことが原因
- バイナリ再ビルド（02/11 20:07）によりdisplay_nameパラメータが有効化
- CLI経由テストで `#sprint-coder` ハッシュタグの自動付与を確認済み
- MCP経由での利用にはCursor再起動が必要（MCPサーバーがバイナリを再読み込みするため）

---

## ステータス凡例

- ⬜ 未着手
- 🔄 進行中
- ✅ 完了
- ⏸️ 保留
- ⚠️ 遅延
