with promos as (
    select *
    from {{ ref('src_promos_snap') }}
    where dbt_valid_to is null 
),

no_promo_row as(
    select * from (values('no_promo',0,'inactive','1900-01-01'))
),

stg_sql_server_dbo__promos as (
select
    promo_id::varchar(50) as promo_id,
    decode(discount,null,0,discount)::float as promo_discount_percent,
    decode(status,'','inactive',null,'inactive',status)::varchar(50) as promo_status,
    _fivetran_synced as date_load
from promos
)

select * from stg_sql_server_dbo__promos
union all
select * from no_promo_row