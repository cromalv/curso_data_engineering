
{{ config(
    materialized='incremental',
    unique_key = 'event_id',
    on_schema_change='fail',
    tags = ["incremental_events"],
    ) 
    }}


with snap_events as(

    select * 
    from {{ ref('src_events_snap') }}

    where dbt_valid_to is null

    {% if is_incremental() %}
        AND _fivetran_synced > (select max(date_load) from {{ this }}) 
    {% endif %}
),

stg_sql_server_dbo__events as(
select
    event_id::varchar(50) as event_id,
    session_id::varchar(50) as session_id,
    user_id::varchar(50) as user_id,
    event_type::varchar(50) as event_type,
    decode(product_id,'','no_product',null,'no_product',product_id)::varchar(50) as product_id,
    decode(order_id,'','no_order',null,'no_order',order_id)::varchar(50) as order_id,
    created_at::timestamp as created_at_utc,     
    page_url::varchar(256) as page_url,
    _FIVETRAN_SYNCED as date_load,

    '{{invocation_id}}' as batch_id

from snap_events
order by 7 asc
)

select *  from stg_sql_server_dbo__events