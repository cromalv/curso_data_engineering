
{{ config(
    materialized='incremental',
    unique_key = 'event_id',
    on_schema_change='append_new_columns',
    tags = ["incremental_events"],
    ) 
    }}


with stg_events as(
    select 
        event_id,
        session_id,
        user_id,
        event_type,
        product_id,
        order_id,
        created_at_utc as created_at_utc,
        created_at_utc::date as created_at_utc_date,
        page_url,
        date_load

    from {{ ref('stg_sql_server_dbo__events') }}

    {% if is_incremental() %}
	  where date_load > (select max(date_load) from {{ this }}) 
    {% endif %}
),

dim_users as (
    select * from {{ ref('dim_users') }}
),
dim_products as(
    select * from {{ ref('dim_products') }}
),
dim_date as(
    select * from {{ ref('dim_date') }}
),

fact_events as(
    select
        a.event_id,
        a.session_id,
        b.user_sk,
        a.event_type,
        d.product_sk,
        a.order_id,
        f.date_key,
        to_char(date_trunc('hour', a.created_at_utc), 'HH24MI') as time_key,
        a.created_at_utc,
        a.created_at_utc::time as time,
        --a.page_url
        date_load,

        '{{invocation_id}}' as batch_id

    from stg_events a 
    left join dim_users b on b.user_id = a.user_id
    left join dim_products d on d.product_id = a.product_id
    left join dim_date f on f.date_day = a.created_at_utc_date
    
    order by 2,9
)

select * from fact_events order by 7

