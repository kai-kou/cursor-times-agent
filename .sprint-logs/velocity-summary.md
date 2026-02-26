---
velocity_summary:
  last_updated: "2026-02-26"
  sprint_count: 3
  sprints:
    - id: "SPRINT-001"
      date: ""
      planned_sp: 0
      completed_sp: 0
      sp_completion_rate: 0
    - id: "SPRINT-002"
      date: ""
      planned_sp: 0
      completed_sp: 0
      sp_completion_rate: 0
    - id: "SPRINT-003"
      date: "2026-02-11"
      planned_sp: 6
      completed_sp: 6
      sp_completion_rate: 100
  aggregated:
    avg_planned_sp: 2
    avg_completed_sp: 2
    avg_completion_rate: 33
    velocity_trend: "insufficient_data"
  po_efficiency:
    - id: "SPRINT-001"
      po_wait_time_minutes: 0
      autonomous_rate: 0
      session_effective_rate: 0
    - id: "SPRINT-002"
      po_wait_time_minutes: 0
      autonomous_rate: 0
      session_effective_rate: 0
    - id: "SPRINT-003"
      po_wait_time_minutes: 1
      autonomous_rate: 100
      session_effective_rate: 85
---

# ベロシティサマリー

> sprint-retro完了時に自動更新される、直近3スプリントのベロシティ集約ファイル。
> sprint-plannerがプランニング時にこのファイルを参照し、直近3スプリントログ全文(~21KB)の読み込みを不要にする。
> **自動更新**: sprint-retro Step 8.10 で更新される。手動編集は不要。

## 直近3スプリント

| # | スプリント | 日付 | 計画SP | 完了SP | 消化率 |
|---|-----------|------|--------|--------|--------|
| 1 | SPRINT-001 | - | - | - | - |
| 2 | SPRINT-002 | - | - | - | - |
| 3 | SPRINT-003 | 2026-02-11 | 6 | 6 | 100% |

## 集計

| 指標 | 値 |
|------|-----|
| 平均計画SP | 2 |
| 平均完了SP | 2 |
| 平均消化率 | 33% |
| ベロシティトレンド | insufficient_data |

## PO効率指標トレンド

| # | スプリント | PO待ち時間(分) | 自律実行率 | セッション有効率 |
|---|-----------|---------------|-----------|----------------|
| 1 | SPRINT-001 | - | - | - |
| 2 | SPRINT-002 | - | - | - |
| 3 | SPRINT-003 | 1 | 100% | 85% |

## ベロシティ判定ガイド

- **消化率 90%以上が続いている**: 推奨上限（13SP）まで積める
- **消化率 70〜90%**: 推奨範囲内（5〜13SP）で保守的に
- **消化率 70%未満**: 前回完了SPを上限の目安とする
- **データ不足（3スプリント未満）**: 推奨範囲の中央値（8〜10SP）を目安とする
