# Jaffle Shop on Snowflake

A minimal, beginner-friendly [dbt](https://www.getdbt.com/) project that runs on
Snowflake. It loads a tiny e-commerce dataset (customers, orders, payments) from
CSV seeds and transforms it into analytics-ready tables.

## What's inside

```
jaffle-shop-snowflake/
├── dbt_project.yml          # project config
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
        ├── orders.sql       # one row per order, with amount paid
        ├── customers.sql    # one row per customer, with lifetime stats
        └── _marts__models.yml     # docs + tests
```

The dependency graph dbt builds from the `{{ ref() }}` calls:

```
raw_customers ──> stg_customers ──────────────┐
raw_orders    ──> stg_orders    ──> orders ──> customers
raw_payments  ──> stg_payments ──┘
```

## Prerequisites

- A Snowflake account
- dbt (this project was built with dbt Fusion 2.0)

## Setup

1. Clone the repo.
2. Add a profile named `jaffle_shop_snowflake` to `~/.dbt/profiles.yml`
   (credentials never live in the repo):

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

3. Verify the connection:

   ```sh
   dbt debug
   ```

## Usage

```sh
dbt build        # seeds + models + tests, in dependency order
```

Or step by step:

```sh
dbt seed         # load the CSVs into Snowflake
dbt run          # build the models (views + tables)
dbt test         # run the data quality tests
```

## Data quality

Tests are declared in the `_*__models.yml` files and cover:

- **unique / not_null** on every primary key
- **accepted_values** on order status and payment method
- **relationships** (referential integrity) between orders and customers
