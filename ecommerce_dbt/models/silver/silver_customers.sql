with raw as (
    select * from {{ source('ecommerce_raw', 'olist_customers_dataset') }}
),
cleaned as (
    select
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix  as zip_code,
        customer_city             as city,
        customer_state            as state,
        _ingested_at
    from raw
    where customer_id is not null
)
select * from cleaned