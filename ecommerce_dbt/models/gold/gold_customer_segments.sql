with orders as (
    select * from {{ ref('silver_orders') }}
),
payments as (
    select * from {{ ref('silver_payments') }}
),
customers as (
    select * from {{ ref('silver_customers') }}
),
customer_metrics as (
    select
        c.customer_unique_id,
        c.city,
        c.state,

        count(distinct o.order_id)      as total_orders,
        sum(p.payment_value)            as total_spent,
        avg(p.payment_value)            as avg_order_value,
        min(date(o.purchased_at))       as first_order_date,
        max(date(o.purchased_at))       as last_order_date,

        date_diff(
            max(date(o.purchased_at)),
            min(date(o.purchased_at)),
            day
        )                               as customer_lifetime_days

    from customers c
    left join orders o   using (customer_id)
    left join payments p using (order_id)
    group by 1, 2, 3
),
segmented as (
    select
        *,
        case
            when total_orders >= 3 and total_spent >= 500  then 'Champion'
            when total_orders >= 2 and total_spent >= 200  then 'Loyal'
            when total_orders = 1 and total_spent >= 300   then 'High Value New'
            when total_orders = 1                          then 'New Customer'
            else 'At Risk'
        end as customer_segment

    from customer_metrics
)
select * from segmented
order by total_spent desc