with raw as (
    select * from {{ source('ecommerce_raw', 'olist_order_items_dataset') }}
),
cleaned as (
    select
        order_id,
        order_item_id,
        product_id,
        seller_id,
        cast(shipping_limit_date as timestamp)  as shipping_limit_at,
        cast(price as numeric)                  as price,
        cast(freight_value as numeric)          as freight_value,
        cast(price as numeric) +
            cast(freight_value as numeric)      as total_item_value,
        _ingested_at
    from raw
    where order_id is not null
)
select * from cleaned