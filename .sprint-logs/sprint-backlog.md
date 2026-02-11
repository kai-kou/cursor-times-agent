---
sprint:
  name: "人格ファイル自動生成"
  status: completed
  started: "2026-02-11"
  completed: "2026-02-11"
  goal: "persona未発見時にdefault.mdをテンプレートとして自動生成し、ユーザーの設定忘れを防止する"
  tasks_total: 5
  tasks_completed: 5
---

# Sprint: 人格ファイル自動生成

**開始日**: 2026-02-11
**ゴール**: persona未発見時にdefault.mdをテンプレートとして自動コピー・自動生成し、ユーザーの設定忘れを防止する

---

## スプリントバックログ

| ID | タスク | 優先度 | ステータス | 担当 |
|----|--------|--------|-----------|------|
| T301 | Subagent定義に人格ファイル自動生成ロジック追加 | P0 | ✅ | AI |
| T302 | Skill定義（SKILL.md）に人格ファイル自動生成ロジック追加 | P0 | ✅ | AI |
| T303 | ERROR_HANDLING.md / PERSONA_FORMAT.md ドキュメント更新 | P1 | ✅ | AI |
| T304 | tasks.md / milestones.md に Phase 4 追加・管理ドキュメント同期 | P1 | ✅ | AI |
| T305 | ~/.cursor/ への同期デプロイ | P0 | ✅ | AI |

---

## 設計方針

### 自動生成ロジック

1. `{project_path}/persona/{member_name}.md` が存在しない場合
2. テンプレート元: `/Users/kai.ko/dev/01_active/cursor-times-agent/persona/default.md` を読み込み
3. プロジェクト固有の値を反映してコピー作成:
   - hashtags にプロジェクト名を追加
   - approved: true で即投稿可能
4. 自動生成したことをユーザーに通知（完了報告に含める）
5. フォールバック元（default.md）も無い場合は投稿中止（従来通り）

### 変更ファイル

- `~/.cursor/agents/cursor-times-agent.md` (Subagent)
- `skill/SKILL.md` → `~/.cursor/skills/cursor-times-agent/SKILL.md` (Skill)
- `references/ERROR_HANDLING.md`
- `references/PERSONA_FORMAT.md`
- `tasks.md` / `milestones.md`
