
{{ config(
    materialized='incremental',
    unique_key = 'order_id',
    on_schema_change='fail',
    tags = ["incremental_orders"],
    ) 
    }}

with orders as(

    select * from {{ ref('src_orders_snap') }}

    where dbt_valid_to is null
    
    {% if is_incremental() %}
        AND _fivetran_synced > (select max(date_load) from {{ this }}) 
    {% endif %}
),

stg_sql_server_dbo__orders as(
    select
    -- keys
        order_id::varchar(50) as order_id,
        user_id::varchar(50) as user_id,
        address_id::varchar(50) as address_id,
        decode(promo_id,null,'no_promo','','no_promo',promo_id)::varchar(50) as promo_id,
       
    --  delivery/shipping related
        decode(status,null,'no_status','','no_status',status)::varchar(50) as status,
        decode(tracking_id,null,'not_assigned','','not_assigned',tracking_id)::varchar(50) as tracking_id,
        decode(shipping_service,null,'not_assigned','','not_assigned',shipping_service)::varchar(50) as shipping_service,

    -- dates
        created_at::timestamp as created_at_utc,
        estimated_delivery_at::timestamp as estimated_delivery_at_utc,
        delivered_at::timestamp as delivered_at_utc,

    -- potential measures:
        order_cost::decimal(24,2) as order_cost_usd,
        shipping_cost::decimal(24,2) as shipping_cost_usd,
        order_total::decimal(24,2) as order_total_usd,
        
        _fivetran_synced as date_load,
        '{{invocation_id}}' as batch_id
        
    from orders
)

select *  from stg_sql_server_dbo__orders
