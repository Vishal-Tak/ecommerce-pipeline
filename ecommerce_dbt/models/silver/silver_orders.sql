with raw as (
    select * from {{ source('ecommerce_raw', 'olist_orders_dataset') }}
),
cleaned as (
    select
        order_id,
        customer_id,
        order_status,
        cast(order_purchase_timestamp as timestamp)        as purchased_at,
        cast(order_approved_at as timestamp)               as approved_at,
        cast(order_delivered_carrier_date as timestamp)    as shipped_at,
        cast(order_delivered_customer_date as timestamp)   as delivered_at,
        cast(order_estimated_delivery_date as timestamp)   as estimated_delivery_at,

        date_diff(
            cast(order_delivered_customer_date as timestamp),
            cast(order_purchase_timestamp as timestamp),
            day
        ) as days_to_deliver,

        case
            when order_status = 'delivered' then true
            else false
        end as is_delivered,

        _ingested_at
    from raw
    where order_id is not null
)
select * from cleaned