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
raw_lakehouse.dbo.customers -> source('bronze', 'customers') -> stg_customers -> dim_customers --+
                                                                                                  +-> fct_orders
raw_lakehouse.dbo.orders    -> source('bronze', 'orders')    -> stg_orders ------------------------+
```

Seed、ステージングモデル、マートモデルには、それぞれ `raw`、`staging`、`marts` をカスタムスキーマ名として指定しています。実際に作成されるスキーマ名は、Fabric 側のアダプター／プロファイル設定と dbt のスキーマ命名規則によって決まります。

## セットアップ

1. Python 環境に利用する Fabric 対応 dbt アダプターをインストールします。
2. `dbt/profiles.yml.example` を `~/.dbt/profiles.yml` にコピーします。
3. 接続先 Warehouse と個人用スキーマを環境変数に設定し、Azure CLI でログインします。
4. 接続とプロジェクトを検証します。

```bash
mkdir -p ~/.dbt
cp dbt/profiles.yml.example ~/.dbt/profiles.yml
export DBT_FABRIC_SERVER="<workspace-endpoint>.datawarehouse.fabric.microsoft.com"
export DBT_FABRIC_DATABASE="<development-warehouse-name>"
export DBT_SCHEMA="dbt_<developer-name>"
az login
dbt debug
dbt deps
dbt seed
dbt build
```

`dbt deps` はルートの `packages.yml` に定義した `dbt_utils` をインストールします。`dbt seed` は動作確認用のサンプル CSV を保持・ロードするために残していますが、ステージングモデルは `raw_lakehouse.dbo` のSourceテーブルを参照します。`dbt build` の前に `raw_lakehouse.dbo.customers` と `raw_lakehouse.dbo.orders` を用意してください。Seed を入れ直す場合は `dbt seed --full-refresh` を使用してください。

Fabric 上でステージングモデルからマートモデルまでを簡単に確認する場合は、ルートの `selectors.yml` に定義したセレクターを使用します。

```bash
dbt build --selector fabric_smoke_test
```

この実行では `dbt_utils.expression_is_true` による売上金額の非負チェックも行われるため、パッケージの読み込みとセレクターの認識をまとめて確認できます。

`dbt/profiles.yml.example` は、ローカルまたは外部の dbt CLI から接続するときのサンプルです。Fabric の DataBuildToolJob 上で実行する場合、接続先 Warehouse とスキーマは Fabric アイテム側のプロファイル設定が使用され、このファイルは使用されません。また、Git 参照の DataBuildToolJob にある `folderPath` は、CLI の `--project-dir` と同じ意味ではなく、今回のリポジトリ側のファイル配置には影響しません。

個人開発では、まず共有の開発用 Warehouse を参照し、`DBT_SCHEMA=dbt_<developer-name>` のように開発者ごとのベーススキーマを分ける運用を推奨します。現在の `+schema` 設定と dbt の標準的な命名規則では、たとえば `DBT_SCHEMA=dbt_taro` の場合、Seed、ステージング、マートは `dbt_taro_raw`、`dbt_taro_staging`、`dbt_taro_marts` に分離されます。負荷分離や強い権限分離が必要な場合だけ、開発者専用 Warehouse を用意して `DBT_FABRIC_SERVER` と `DBT_FABRIC_DATABASE` を切り替えます。

環境変数はシェルや秘密情報ストアで管理し、認証情報を含む `profiles.yml` はコミットしないでください。`DBT_SCHEMA` には小文字の英数字とアンダースコアだけを使い、衝突を避ける一意な名前を設定してください。実際のスキーマ名は Fabric アダプターの命名処理によって異なる場合があります。
