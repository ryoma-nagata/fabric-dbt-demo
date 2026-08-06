# Fabric dbt demo

Microsoft Fabric Warehouse 上で、CSV の Seed からステージングビューと分析用テーブルを作る最小構成の dbt プロジェクトです。

Fabric からリポジトリのルートを dbt プロジェクトとして認識できるように、`dbt_project.yml` はルートへ配置しています。モデル、Seed、テストなどのdbt資材は、Fabric Workspace の Git 連携で同期されるアイテムと混在しないように `src/` 配下へまとめています。

## データフロー

```text
src/seeds/customers.csv -> stg_customers -> dim_customers --+
                                                            +-> fct_orders
src/seeds/orders.csv    -> stg_orders ----------------------+
```

Seed、ステージングモデル、マートモデルには、それぞれ `raw`、`staging`、`marts` をカスタムスキーマ名として指定しています。実際に作成されるスキーマ名は、Fabric側のアダプター／プロファイル設定とdbtのスキーマ命名規則によって決まります。

## 実行

Fabric側でアダプターと接続プロファイルを設定したうえで、リポジトリのルートから実行します。

```bash
dbt debug
dbt seed
dbt build
```

`dbt seed` はサンプル CSV をロードし、`dbt build` は依存順にモデルとテストを実行します。Seed を入れ直す場合は `dbt seed --full-refresh` を使用してください。

## ローカル開発

ローカルでの開発とテスト用に、Fabric接続プロファイルのひな型を `src/profiles.yml.example` に用意しています。これをdbtのプロファイルディレクトリへコピーし、接続先を変更してください。

```bash
mkdir -p ~/.dbt
cp src/profiles.yml.example ~/.dbt/profiles.yml
az login
dbt debug
dbt build
```

実際の認証方法や接続値は利用環境に合わせて設定し、認証情報を含む `profiles.yml` はコミットしないでください。プロファイル内の `target`、`schema`、またはFabricアダプターの命名処理によって、`+schema` に付加される接頭辞が変わる場合があります。
