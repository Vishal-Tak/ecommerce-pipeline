with raw as (
    select * from {{ source('ecommerce_raw', 'olist_sellers_dataset') }}
),
cleaned as (
    select
        seller_id,
        seller_zip_code_prefix  as zip_code,
        seller_city             as city,
        seller_state            as state,
        _ingested_at
    from raw
    where seller_id is not null
)
select * from cleaned