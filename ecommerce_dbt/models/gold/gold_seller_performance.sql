with orders as (
    select * from {{ ref('silver_orders') }}
),
items as (
    select * from {{ ref('silver_order_items') }}
),
payments as (
    select * from {{ ref('silver_payments') }}
),
sellers as (
    select * from {{ ref('silver_sellers') }}
),
seller_metrics as (
    select
        s.seller_id,
        s.city                              as seller_city,
        s.state                             as seller_state,
        concat('BR-', s.state)              as geo_state,
        count(distinct o.order_id)          as total_orders,
        count(distinct i.product_id)        as unique_products,
        sum(p.payment_value)                as total_revenue,
        avg(p.payment_value)                as avg_order_value,
        avg(o.days_to_deliver)              as avg_delivery_days,

        -- delivery performance
        countif(o.is_delivered = true)      as delivered_orders,
        countif(o.order_status = 'canceled') as canceled_orders,

        round(
            countif(o.is_delivered = true) * 100.0
            / nullif(count(distinct o.order_id), 0)
        , 2)                                as delivery_rate_pct

    from sellers s
    left join items i     using (seller_id)
    left join orders o    using (order_id)
    left join payments p  using (order_id)
    group by 1, 2, 3
)
select * from seller_metrics
order by total_revenue desc