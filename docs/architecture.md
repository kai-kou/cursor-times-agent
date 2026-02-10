# Cursor Times Agent - アーキテクチャ設計

**作成日**: 2026-02-10
**最終更新**: 2026-02-10

## 概要

Cursor Times Agentは、Cursor AI Agentのエコシステム（Skill + Rule）を活用した自動分報投稿エージェントです。

## コンポーネント構成

```
[Cursor IDE]
    │
    ├── .cursor/rules/cursor-times-agent.mdc   ← ワークスペースグローバルルール
    │   └── 自動投稿トリガー条件の定義
    │
    ├── ~/.cursor/skills/cursor-times-agent/SKILL.md  ← Agent Skill
    │   └── 振り返り生成・投稿実行ロジック
    │
    └── .cursor/mcp.json
        └── slack-fast-mcp MCPサーバー設定
            │
            ├── slack_post_message  ← メッセージ投稿
            ├── slack_get_history   ← 履歴取得
            └── slack_post_thread   ← スレッド返信

[プロジェクトファイル]
    │
    └── 01_active/cursor-times-agent/
        ├── persona/default.md     ← 人格設定
        ├── docs/setup-guide.md    ← セットアップ手順
        └── docs/architecture.md   ← 本ドキュメント
```

## 処理フロー

### タスク完了時の自動投稿フロー

```
1. ユーザーがCursorでタスク作業を実施
   │
2. 作業完了 → AI Agentが完了報告を準備
   │
3. グローバルルール（cursor-times-agent.mdc）がトリガー
   │
4. Skill（SKILL.md）のワークフローを実行
   │
   ├── 4a. persona/default.md を読み込む
   │   └── approved: true を確認（未承認なら承認フロー）
   │
   ├── 4b. セッション履歴を分析
   │   └── 実施タスク、成果、学び、所感を抽出
   │
   ├── 4c. [任意] WebSearchで最新情報キャッチアップ
   │
   └── 4d. 人格設定に基づいて投稿文を生成
       │
5. slack-fast-mcp の slack_post_message で投稿
   │
6. 投稿結果を確認 → 通常の完了報告とともに報告
```

### 途中投稿のランダムトリガーフロー

```
1. 長いタスク作業中
   │
2. トリガー条件を評価
   ├── ファイル変更数 ≥ 5?
   ├── 大きなマイルストーン達成?
   ├── 難問解決?
   └── 前回投稿から十分な間隔?
   │
3. 投稿判定（約60%の確率で投稿）
   │
   ├── YES → Skill実行 → 投稿
   └── NO  → スキップ（サイレント）
```

## 設計判断

### なぜSkill + Ruleの組み合わせか

| 方式 | メリット | デメリット |
|------|---------|-----------|
| **Skill + Rule（採用）** | ルールで自動トリガー、Skillで複雑なロジック | 2ファイル管理が必要 |
| Skillのみ | 1ファイルで完結 | 自動トリガーが困難 |
| Ruleのみ | 1ファイルで完結 | 複雑なロジックの記述が困難 |
| SubAgent | 独立した処理が可能 | 設定が複雑、オーバーヘッド |

### なぜslack-fast-mcpか

- Go製シングルバイナリで起動が高速（~10ms）
- MCPプロトコルネイティブ対応でCursorからシームレスに利用可能
- プロジェクトローカルで開発中、すぐに利用可能
- 将来的にGitHub公開予定で、チームメンバーにも展開可能

### 人格設定を外部ファイルにした理由

- ルールやスキルに直接埋め込むと変更時にコア機能に影響する
- ファイル分離により、人格のみの変更・承認フローが実現可能
- 将来的に複数人格の切り替え（仕事用/プライベート用等）にも対応可能
