-- Mart model: one row per order, enriched with payment totals.
-- The ref() calls below are how dbt builds its dependency graph,
-- so it knows to build the staging models before this one.

with orders as (

    select * from {{ ref('stg_orders') }}

),

payments as (

    select * from {{ ref('stg_payments') }}

),

order_payments as (

    select
        order_id,
        sum(amount) as total_amount

    from payments
    group by order_id

),

final as (

    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.status,
        coalesce(order_payments.total_amount, 0) as amount

    from orders
    left join order_payments
        on orders.order_id = order_payments.order_id

)

select * from final
