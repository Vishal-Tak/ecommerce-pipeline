with orders as (
    select * from {{ ref('silver_orders') }}
),
payments as (
    select * from {{ ref('silver_payments') }}
),
daily as (
    select
        date(o.purchased_at)            as order_date,

        count(distinct o.order_id)      as total_orders,
        sum(p.payment_value)            as total_revenue,
        avg(p.payment_value)            as avg_order_value,
        countif(o.is_delivered = true)  as delivered_orders,
        avg(o.days_to_deliver)          as avg_delivery_days

    from orders o
    left join payments p using (order_id)
    where o.purchased_at is not null
    group by 1
),
with_cumulative as (
    select
        *,
        sum(total_revenue) over (
            order by order_date
        ) as cumulative_revenue

    from daily
)
select * from with_cumulative
order by order_date