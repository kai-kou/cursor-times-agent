---
name: cursor-times-agent
description: タスク完了時にセッション振り返り・所感をSlack分報に自動投稿するエージェント。「タスク完了」「作業完了」「振り返り投稿」「分報投稿」「timesに投稿」と言われたら使用。slack-fast-mcp MCPサーバーを利用してSlack投稿する。プロジェクトごとの仮想スクラムチームメンバー（AI Agent）の人格に基づいて投稿可能。
---

# Cursor Times Agent - AI自動分報投稿エージェント

タスク完了時やセッション中にセッション履歴を振り返り、ユーザーに代わってSlackの分報（Times）チャンネルにカジュアルな所感を投稿します。

プロジェクトごとの仮想スクラムチームに所属するメンバー（AI Agent）の人格に基づき、各メンバーとして投稿できます。

## 前提条件

- slack-fast-mcp MCPサーバーが設定済みであること
- `~/.cursor/mcp.json` の env に `SLACK_BOT_TOKEN` の値が**直接記載**されていること
- 投稿先チャンネルにBotが招待済みであること

## 入力パラメータ

本Skillは呼び出し側から以下のパラメータを受け取ります：

| パラメータ | 必須 | 説明 |
|-----------|------|------|
| `project_path` | Yes | プロジェクトのルートパス（人格ファイルの探索に使用） |
| `member_name` | Yes | メンバー（AI Agent）の名前 |
| `channel` | No | 投稿先チャンネルID（省略時は人格ファイルの `default_channel`） |

## ワークフロー

### Step 0: 人格設定の読み込み（自動生成対応）

受け取った `project_path` と `member_name` から人格設定ファイルを探索・読み込みます。

**探索順序:**

1. `{project_path}/persona/{member_name}.md` を探す
2. 見つかった場合 → `approved: true` を確認して使用
3. **見つからない場合 → 自動生成する:**
   a. テンプレート元 `~/.cursor/skills/cursor-times-agent/templates/persona-default.md` を読み込む
   b. テンプレートも見つからない場合 → 投稿をスキップし、ユーザーに通知
   c. `{project_path}/persona/` ディレクトリを作成（なければ）
   d. テンプレートの内容をベースに以下を調整して `{project_path}/persona/{member_name}.md` として書き出す:
      - `hashtags` にプロジェクト名（project_pathの末尾ディレクトリ名）を `#project-name` として追加
      - `created` / `updated` を当日日付に更新
      - `approved: true` のまま（即投稿可能）
      - それ以外の人格設定（名前・口調・スタイル等）はテンプレートのまま
   e. 自動生成した人格ファイルを使用して投稿を継続
   f. Step 5 の完了報告に自動生成の通知を追記

**承認チェック:**
- 人格設定ファイル内の `approved` が `true` であることを確認
- `approved: false` の場合、人格設定の内容をユーザーに提示し、承認を得る
- 承認後、`approved: true` に更新する

### Step 1: セッション分析

現在のセッション（会話履歴）を分析し、以下を抽出：

1. **実施タスクの特定**
   - 何をやっていたか（タスク名、対象プロジェクト）
   - どのような変更を行ったか（コード変更、ドキュメント作成等）
   - 苦労したポイント、工夫したポイント

2. **成果の整理**
   - 完了した内容のサマリー
   - 学んだこと、発見したこと
   - 次にやるべきこと

3. **感情・所感の推測**
   - タスクの難易度から感情を推測
   - 達成感、苦労、面白さなどを表現

### Step 2: 最新情報キャッチアップ（オプション）

タスク内容に関連する最新情報がある場合、WebSearchツールで調査：

1. タスクで使用した技術・ツールの最新動向
2. 関連するOSSのアップデート情報
3. 業界のトレンドニュース

**注意**: 必ずしも毎回実行しない。関連性が高く、投稿として価値がある場合のみ。

### Step 3: 投稿文の生成

Step 0 で読み込んだ人格設定に基づいて投稿文を生成：

#### 投稿の種類

| 種類 | タイミング | 頻度 |
|------|-----------|------|
| タスク完了振り返り | タスク完了時 | 毎回 |
| 最新情報共有 | キャッチアップ成果がある時 | 任意 |
| 進捗つぶやき | 長いタスク中 | ランダム（投稿しない場合もあり） |
| 息抜きつぶやき | 長いタスク中 | ランダム（投稿しない場合もあり） |

#### 投稿フォーマット（Slack mrkdwn）

**タスク完了振り返り**:
```
[人格に基づく一言]

*[タスク名/プロジェクト名]* の作業が完了〜
[やったことの簡潔なサマリー]

[苦労したポイントや工夫したポイント]
[学んだことや発見]

[人格に基づく締めの一言]
#cursor #[プロジェクト名]
```

**最新情報共有**:
```
[人格に基づく導入]

:newspaper: *[技術/ツール名]* の最新情報をキャッチアップしたよ
[最新情報のサマリー（2-3行）]

[所感・コメント]
#tech #[関連タグ]
```

**進捗つぶやき**:
```
[人格に基づくカジュアルなつぶやき]
[今やっていることの一言サマリー]
[感想や独り言]
```

#### 投稿の文字数目安
- タスク完了振り返り: 100〜300文字
- 最新情報共有: 100〜200文字
- 進捗つぶやき: 30〜100文字
- 息抜きつぶやき: 20〜80文字

### Step 4: Slack投稿

slack-fast-mcp MCPサーバーの `slack_post_message` ツールを使用して投稿：

```
slack_post_message を使用:
- channel: 入力パラメータの channel、または人格設定ファイルの default_channel（チャンネルIDを使用すること）
- message: Step 3 で生成した投稿文
- username: member_name（※ slack-fast-mcp が username パラメータに対応次第）
```

**重要: チャンネル指定はチャンネルID（例: C0AE6RT9NG4）を使用すること。**
チャンネル名（例: kai-cursor-times）ではslack-fast-mcp経由で `channel_not_found` エラーが発生する。

**投稿後の確認**:
- 投稿が成功したことを確認（`ok: true` を確認）
- エラーの場合はユーザーに通知（セットアップガイドを案内）

### Step 5: 完了報告

```
📝 分報投稿完了
👤 メンバー: [member_name]
📌 チャンネル: #[チャンネル名]
💬 投稿内容: [投稿文の先頭30文字]...
```

人格ファイルを自動生成した場合は以下も追記:
```
📋 人格ファイルを自動生成しました: {project_path}/persona/{member_name}.md
   カスタマイズする場合は上記ファイルを編集してください。
```

## 進捗・息抜き投稿のランダム性ルール

長いタスク（推定30分以上の作業）の場合、以下のルールで途中投稿を判断：

1. **投稿判定**: 以下の条件をランダムに評価
   - 作業開始から15分以上経過
   - 大きな進展があった（ファイル変更が多い等）
   - 難しい問題を解決した瞬間
   - 投稿しない確率: 約40%（毎回投稿すると不自然）

2. **間隔制御**: 前回の途中投稿から最低10分は空ける

3. **内容**: 進捗報告か息抜きかをランダムに選択
   - 進捗報告: 60%
   - 息抜きつぶやき: 40%

## エラーハンドリング

| エラー | 対処 |
|--------|------|
| slack-fast-mcp未設定 | セットアップガイド（https://github.com/kai-kou/cursor-times-agent/blob/main/docs/setup-guide.md）を案内 |
| invalid_auth | `~/.cursor/mcp.json` の env で SLACK_BOT_TOKEN にトークン値が直接設定されているか確認。`${ENV_VAR}` 形式の環境変数展開はCursorのMCP設定では非対応 |
| channel_not_found | チャンネル名ではなくチャンネルIDを使用する。Slack APIの `conversations.list` で正しいIDを取得すること |
| 人格ファイル未発見 | default.mdをテンプレートとして `{project_path}/persona/{member_name}.md` を自動生成。テンプレートも無い場合は投稿スキップ |
| チャンネル未設定 | 人格設定ファイルの `default_channel` にチャンネルIDを設定、または呼び出し時に `channel` パラメータを指定 |
| 投稿失敗 | エラー内容を表示し、トラブルシューティングを案内 |
| 人格未承認 | 人格設定の承認フローを実行 |

## 使用例

**例1: プロジェクトのメンバーとしてタスク完了投稿**
```
呼び出し側:
  project_path: {your-workspace}/my-project
  member_name: kuro
→ {your-workspace}/my-project/persona/kuro.md を読み込み
→ セッション分析 → 投稿文生成 → Slack投稿
```

**例2: 別プロジェクトの別メンバーとして投稿**
```
呼び出し側:
  project_path: {your-workspace}/another-project
  member_name: shiro
  channel: C0XXXXXXXXX
→ {your-workspace}/another-project/persona/shiro.md を読み込み
→ セッション分析 → 投稿文生成 → 指定チャンネルに投稿
```

**例3: 明示的な振り返り依頼**
```
ユーザー: 今の作業を振り返ってtimesに投稿して
→ 呼び出し側からproject_path, member_nameを受け取り
→ セッション分析 → 投稿文生成 → Slack投稿
```

**例4: 最新情報キャッチアップ**
```
ユーザー: 今使った技術の最新情報もtimesに共有して
→ WebSearch → 情報整理 → 投稿文生成 → Slack投稿
```

**例5: 人格ファイルが無い新規プロジェクトで自動生成**
```
呼び出し側:
  project_path: {your-workspace}/new-project  (persona/ が存在しない)
  member_name: kuro
→ persona/kuro.md が無い → default.md をテンプレートとして自動生成
→ {your-workspace}/new-project/persona/kuro.md を作成
→ セッション分析 → 投稿文生成 → Slack投稿
→ 完了報告に「📋 人格ファイルを自動生成しました」を追記
```

## 人格設定ファイルのフォーマット

各プロジェクトの `persona/{member_name}.md` は以下のフォーマットに準拠すること：

```markdown
# [Agent名] - 人格設定

## メタ情報
- approved: true/false
- version: x.x.x
- created: YYYY-MM-DD
- updated: YYYY-MM-DD

## 投稿先設定
- default_channel: "チャンネルID"  # チャンネル名コメント
- hashtags: ["#tag1", "#tag2"]

## 人格プロフィール
### 名前
### 一人称
### ベースキャラクター
### 性格・トーン
### 口調の特徴
### 投稿スタイルサンプル
### 投稿で避けること
```

リファレンス実装: `~/.cursor/skills/cursor-times-agent/templates/persona-default.md`
