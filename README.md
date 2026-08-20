# Fabric dbt demo

Microsoft Fabric Warehouse 上で、CSV の Seed からステージングビューと分析用テーブルを作る最小構成の dbt プロジェクトです。

Fabric からリポジトリのルートを dbt プロジェクトとして認識できるように、`dbt_project.yml` はルートへ配置しています。モデル、Seed、テストなどの dbt 資材は `dbt/`、補助ツールは `tools/`、Fabric Workspace の Git 連携で同期されるアイテムは `workspace/` へ分離しています。

## ディレクトリ構成

```text
.
├── dbt_project.yml
├── packages.yml
├── selectors.yml
├── dbt/                     # dbt のモデル、マクロ、Seed、Snapshot、テスト
├── tools/                   # dbt を補助するツール
├── workspace/               # Fabric Workspace の同期対象
├── scripts/fabric_cicd/     # Fabric のデプロイ／検証スクリプト
├── tests/                   # 補助ツールとスクリプトのテスト
├── docs/                    # プロジェクトドキュメント
└── .github/                 # GitHub の設定とワークフロー
```

## データフロー

```text
dbt/seeds/customers.csv -> stg_customers -> dim_customers --+
                                                            +-> fct_orders
dbt/seeds/orders.csv    -> stg_orders ----------------------+
```

Seed、ステージングモデル、マートモデルには、それぞれ `raw`、`staging`、`marts` をカスタムスキーマ名として指定しています。実際に作成されるスキーマ名は、Fabric 側のアダプター／プロファイル設定と dbt のスキーマ命名規則によって決まります。

## セットアップ

1. Python 環境に利用する Fabric 対応 dbt アダプターをインストールします。
2. `dbt/profiles.yml.example` を `~/.dbt/profiles.yml` にコピーします。
3. `server` と `database` を対象の Fabric Warehouse に合わせて変更し、Azure CLI でログインします。
4. 接続とプロジェクトを検証します。

```bash
mkdir -p ~/.dbt
cp dbt/profiles.yml.example ~/.dbt/profiles.yml
az login
dbt debug
dbt deps
dbt seed
dbt build
```

`dbt deps` はルートの `packages.yml` に定義した `dbt_utils` をインストールします。`dbt seed` はサンプル CSV をロードし、`dbt build` は依存順にモデルとテストを実行します。Seed を入れ直す場合は `dbt seed --full-refresh` を使用してください。

Fabric 上でステージングモデルからマートモデルまでを簡単に確認する場合は、ルートの `selectors.yml` に定義したセレクターを使用します。

```bash
dbt build --selector fabric_smoke_test
```

この実行では `dbt_utils.expression_is_true` による売上金額の非負チェックも行われるため、パッケージの読み込みとセレクターの認識をまとめて確認できます。

実際の認証方法や接続値は利用環境に合わせて設定し、認証情報を含む `profiles.yml` はコミットしないでください。プロファイル内の `target`、`schema`、または Fabric アダプターの命名処理によって、`+schema` に付加される接頭辞が変わる場合があります。
