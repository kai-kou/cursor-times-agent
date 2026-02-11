---
sprint:
  id: "SPRINT-002"
  project: "cursor-times-agent"
  date: "2026-02-11"
  status: "completed"
backlog:
  total_tasks: 6
  total_sp: 13
  completed_tasks: 0
  completed_sp: 0
  sp_completion_rate: 0
---

# スプリントバックログ

**スプリント**: SPRINT-002
**プロジェクト**: cursor-times-agent
**日付**: 2026-02-11
**ステータス**: completed

---

## スプリント目標

> cursor-times-agentを「git clone → deploy → 即利用可能」な単体完結パッケージに再構成し、チームメンバーへの手軽な展開を実現する。cursor-agents-skillsへの同期デプロイもオプションとして提供する。

---

## バックログ

| # | タスクID | タスク名 | SP | 優先度 | 担当 | ステータス | 備考 |
|---|---------|---------|-----|--------|------|-----------|------|
| 1 | T401 | Subagent定義・references/ をリポジトリに追加 | 2 | P0 | sprint-coder | ✅ | agent/ 新設 + skill/references/ 追加（TRY-014対応） |
| 2 | T402 | ハードコードパスのポータブル化 | 3 | P0 | sprint-coder | ✅ | 全ファイルのハードコードパスを ~/.cursor/... / GitHub URL に統一 |
| 3 | T403 | デプロイスクリプト作成 (scripts/deploy.sh) | 3 | P0 | sprint-coder | ✅ | リポジトリ → ~/.cursor/ 一括デプロイ自動化 |
| 4 | T404 | cursor-agents-skills同期スクリプト作成 | 2 | P1 | sprint-coder | ✅ | オプション: cursor-agents-skillsリポジトリへの同期・diff確認付き |
| 5 | T405 | README.md / docs 更新 | 2 | P1 | sprint-documenter | ✅ | 単体セットアップ手順・アーキテクチャ図更新 |
| 6 | T406 | tasks.md / milestones.md 更新 | 1 | P1 | sprint-documenter | ✅ | Phase 5・M5追加、集計値再計算 |

### SP集計

| 項目 | 値 |
|------|-----|
| 計画SP合計 | 13 |
| 完了SP合計 | 13 |
| SP消化率 | 100% |
| タスク数 | 6 / 6 |

### 粒度チェック

- [x] SP合計 ≤ 21（推奨: 5〜13）→ 13 SP
- [x] タスク数 ≤ 10（推奨: 3〜7）→ 6件
- [x] 推定所要時間 ≤ 4時間（推奨: 15分〜2時間）→ 1.5〜2時間

---

## 入力元

- **milestones.md**: M1-M4完了、M5新設予定
- **tasks.md**: T001-T305完了（20タスク）、Phase 5タスク追加予定
- **前回Try**: TRY-014（references/ 一元化）→ T401で対応

---

## スコープ変更記録

> スプリント実行中にPOがスコープを変更した場合の記録。変更がなければ「なし」。

| 時刻 | 変更内容 | 変更前SP | 変更後SP | 理由 |
|------|---------|---------|---------|------|

---

## POの承認

- [x] PO承認済み（2026-02-11）
