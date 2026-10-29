# Jaffle Shop on Snowflake

A minimal [dbt](https://www.getdbt.com/) project on Snowflake. It loads a small
e-commerce dataset (customers, orders, payments) from CSV seeds, cleans it in
staging views and builds two mart tables, with schema tests on the keys and
categorical columns.

## At a glance

| | |
|---|---|
| Stack | dbt with the Snowflake adapter, SQL only, no packages or macros |
| Warehouse | Snowflake |
| Data | Three CSV seeds: 15 customers, 20 orders, 23 payments |
| What it shows | The standard dbt layout: seeds, staging views, mart tables, `ref()` lineage, and `unique`, `not_null`, `accepted_values` and `relationships` tests declared in YAML |
| Status | Portfolio project, complete. Last verified 2026-07 from the repo contents. |

## Project structure

```
jaffle-shop-snowflake/
├── dbt_project.yml          # project config: profile name and materializations
├── requirements.txt         # pinned dbt-core and dbt-snowflake
├── seeds/                   # raw data as CSVs, loaded by `dbt seed`
│   ├── raw_customers.csv
│   ├── raw_orders.csv
│   └── raw_payments.csv
└── models/
    ├── staging/             # 1-to-1 cleanup views over the raw data
    │   ├── stg_customers.sql
    │   ├── stg_orders.sql
    │   ├── stg_payments.sql
    │   └── _staging__models.yml   # docs + tests
    └── marts/               # business-facing tables
        ├── orders.sql
        ├── customers.sql
        └── _marts__models.yml     # docs + tests
```

Lineage, as dbt derives it from the `{{ ref() }}` calls:

```
raw_customers ──> stg_customers ──────────────┐
raw_orders    ──> stg_orders    ──> orders ──> customers
raw_payments  ──> stg_payments ──┘
```

## Run it

You need a Snowflake account with a role, warehouse and database you can write to.

1. Clone the repo and install dbt into a virtual environment:

   ```sh
   git clone https://github.com/nathanmars7/jaffle-shop-snowflake.git
   cd jaffle-shop-snowflake
   python -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
   ```

   The project was written with dbt Fusion 2.0. The test definitions use the
   `arguments:` key, which needs dbt Core 1.10 or later, so `requirements.txt`
   pins dbt Core 1.10 and the matching Snowflake adapter.

2. `dbt_project.yml` points at a profile named `jaffle_shop_snowflake`. Add it to
   `~/.dbt/profiles.yml` (credentials never live in the repo):

   ```yaml
   jaffle_shop_snowflake:
     target: dev
     outputs:
       dev:
         type: snowflake
         account: <YOUR_ACCOUNT_IDENTIFIER>   # e.g. MYORG-MYACCOUNT
         user: <YOUR_USER>
         role: <YOUR_ROLE>
         warehouse: <YOUR_WAREHOUSE>
         database: <YOUR_DATABASE>
         schema: JAFFLE_SHOP
         private_key_path: <PATH_TO_YOUR_KEY>.p8   # or use password auth
         threads: 4
   ```

3. Check the connection, then build everything:

   ```sh
   dbt debug
   dbt seed         # load the three CSVs into Snowflake
   dbt build        # models + tests, in dependency order
   ```

   `dbt build` also runs the seeds, so the separate `dbt seed` is optional.
   To do it step by step instead, use `dbt run` then `dbt test`.

4. Optionally generate and browse the docs site:

   ```sh
   dbt docs generate
   dbt docs serve
   ```

## Models

Staging models are materialized as views and marts as tables, set per folder in
`dbt_project.yml`.

| Model | Materialization | Description |
|---|---|---|
| `stg_customers` | view | One row per customer, lightly cleaned from the raw seed |
| `stg_orders` | view | One row per order |
| `stg_payments` | view | One row per payment; an order can have multiple payments |
| `orders` | table | One row per order, enriched with the total amount paid |
| `customers` | table | One row per customer, with first and most recent order date, order count and lifetime value |

## Data quality

Tests are declared in the `_*__models.yml` files:

- `unique` and `not_null` on every primary key
- `accepted_values` on `stg_orders.status` and `stg_payments.payment_method`
- `not_null` on `orders.customer_id` and `orders.amount`
- `relationships` from `orders.customer_id` to `customers.customer_id`

## Portfolio

Part of a set of data engineering portfolio projects:

- [dbt-analytics-engineering](https://github.com/nathanmars7/dbt-analytics-engineering): dbt on DuckDB and Snowflake from one codebase
- [jaffle-shop-snowflake](https://github.com/nathanmars7/jaffle-shop-snowflake) (this repo): minimal dbt starter on Snowflake
- [dbt-nyc-citibike](https://github.com/nathanmars7/dbt-nyc-citibike): dbt on BigQuery, Citibike ridership vs weather
- [dbt-crypto-bitcoin](https://github.com/nathanmars7/dbt-crypto-bitcoin): dbt on BigQuery with snapshots, Bitcoin transactions
- [dbt-learning](https://github.com/nathanmars7/dbt-learning): dbt on BigQuery, Chicago taxi trips, incremental models
- [pyspark-fraud-pipeline](https://github.com/nathanmars7/pyspark-fraud-pipeline): PySpark and Delta Lake medallion pipeline on Databricks
