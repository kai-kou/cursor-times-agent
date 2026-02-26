---
team:
  total_members: 7
  last_updated: "2026-02-26"
---

# チームロスター

**プロジェクト**: cursor-times-agent
**最終更新**: 2026-02-26

> AI Scrum Frameworkのスクラムチームメンバー一覧。
> 各メンバーのロール、責務、稼働状況を管理する。

---

## メンバー一覧

| # | メンバー名 | 種別 | ロール | 状態 |
|---|-----------|------|--------|------|
| 1 | sprint-master | Agent | スクラムマスター（オーケストレーター） | Active |
| 2 | sprint-coder | Skill | コーディング担当 | Active |
| 3 | sprint-documenter | Skill | ドキュメンテーション担当 | Active |
| 4 | po-assistant | Skill | PO補佐 | Active |
| 5 | sp-estimator | Skill | SP見積もり | Active |
| 6 | sprint-researcher | Skill | リサーチ担当（Flower Phase 1） | Active |
| 7 | sprint-mentor | Skill | メンター / アーキテクト（Flower Phase 3） | Active |

---

## メンバー詳細

### sprint-master（スクラムマスター）

- **種別**: Agent（Subagent）
- **定義**: `~/.claude/agents/sprint-master.md`
- **責務**: スプリントのライフサイクル管理、フェーズ遷移判断、ログ記録
- **サブエージェント**: sprint-planner, sprint-review-runner, sprint-retro

### sprint-coder（コーダー）

- **種別**: Skill
- **定義**: `~/.claude/skills/sprint-coder/SKILL.md`
- **責務**: コード実装、ファイル作成、リファクタリング、セルフレビュー

### sprint-documenter（ドキュメンター）

- **種別**: Skill
- **定義**: `~/.claude/skills/sprint-documenter/SKILL.md`
- **責務**: テンプレート作成、Skill/Agent定義書、README、ドキュメント整備

### po-assistant（PO補佐）

- **種別**: Skill
- **定義**: `~/.claude/skills/po-assistant/SKILL.md`
- **責務**: タスク候補抽出、優先度提案、スコープ変更影響分析

### sp-estimator（SP見積もり）

- **種別**: Skill
- **定義**: `~/.claude/skills/sp-estimator/SKILL.md`
- **責務**: 4軸評価に基づくSP見積もり、パターンマッチング、粒度チェック

### sprint-researcher（リサーチャー）

- **種別**: Skill
- **定義**: `~/.claude/skills/sprint-researcher/SKILL.md`
- **責務**: Flower Phase 1（Research）担当。技術調査、ベストプラクティス調査、幻覚防止
- **起動条件**: SP 3以上のタスク

### sprint-mentor（メンター）

- **種別**: Skill
- **定義**: `~/.claude/skills/sprint-mentor/SKILL.md`
- **責務**: Flower Phase 3（Plan）担当。実装計画立案、自己批判、受け入れ基準定義
- **起動条件**: SP 3以上のタスク

---

## スプリント別稼働履歴

> スプリント完了時にsprint-retroが自動更新する。

| スプリント | 日付 | 稼働メンバー | 計画SP | 完了SP | 消化率 |
|-----------|------|------------|--------|--------|-------|
| SPRINT-001 | 2026-02 | sprint-master, sprint-coder, sprint-documenter | - | - | - |
| SPRINT-002 | 2026-02 | sprint-master, sprint-coder, sprint-documenter | - | - | - |
| SPRINT-003 | 2026-02-11 | sprint-master, sprint-coder, sprint-documenter | 6 | 6 | 100% |

---

## 集計サマリー

| 指標 | 値 |
|------|-----|
| 総スプリント数 | 3 |
| 平均チーム規模 | 3 |
| 最頻メンバー | sprint-master, sprint-coder, sprint-documenter |
