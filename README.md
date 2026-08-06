# Fabric dbt demo

Microsoft Fabric Warehouse 上で、CSV の Seed からステージングビューと分析用テーブルを作る最小構成の dbt プロジェクトです。

## データフロー

```text
seeds/customers.csv -> stg_customers -> dim_customers --+
                                                        +-> fct_orders
seeds/orders.csv    -> stg_orders ----------------------+
```

既定では Seed は `raw`、ステージングモデルは `staging`、マートモデルは `marts` スキーマに作成されます。

## セットアップ

1. Python 環境に利用する Fabric 対応 dbt アダプターをインストールします。
2. `profiles.yml.example` を `~/.dbt/profiles.yml` にコピーします。
3. `server` と `database` を対象の Fabric Warehouse に合わせて変更し、Azure CLI でログインします。
4. 接続とプロジェクトを検証します。

```bash
dbt debug
dbt seed
dbt build
```

`dbt seed` はサンプル CSV をロードし、`dbt build` は依存順にモデルとテストを実行します。Seed を入れ直す場合は `dbt seed --full-refresh` を使用してください。
