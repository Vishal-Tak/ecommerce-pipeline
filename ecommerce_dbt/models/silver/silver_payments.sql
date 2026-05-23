with raw as (
    select * from {{ source('ecommerce_raw', 'olist_order_payments_dataset') }}
),
cleaned as (
    select
        order_id,
        payment_sequential,
        payment_type,
        payment_installments,
        cast(payment_value as numeric)  as payment_value,
        _ingested_at
    from raw
    where order_id is not null
)
select * from cleaned