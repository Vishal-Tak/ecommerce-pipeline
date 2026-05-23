with orders as (
    select * from {{ ref('silver_orders') }}
),
payments as (
    select * from {{ ref('silver_payments') }}
),
daily as (
    select
        date(o.purchased_at)            as order_date,
        o.order_status,

        count(distinct o.order_id)      as total_orders,
        sum(p.payment_value)            as total_revenue,
        avg(p.payment_value)            as avg_order_value,

        -- running total (great for dashboard trend lines)
        sum(sum(p.payment_value)) over (
            order by date(o.purchased_at)
        )                               as cumulative_revenue,

        countif(o.is_delivered = true)  as delivered_orders,
        avg(o.days_to_deliver)          as avg_delivery_days

    from orders o
    left join payments p using (order_id)
    where o.purchased_at is not null
    group by 1, 2
)
select * from daily
order by order_date