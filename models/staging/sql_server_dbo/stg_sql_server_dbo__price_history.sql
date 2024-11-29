with stg_sql_server_dbo__price_history as(
    select
        product_id::varchar as product_id,
        price::decimal(12,2) as price_usd,
        name::varchar(50) as product_name,
        begin_eff_date::timestamp as begin_eff_date,
        end_eff_date::timestamp as end_eff_date
    from {{ ref("src_price_history_snap") }}
    where dbt_valid_to is null
)
select * from stg_sql_server_dbo__price_history order by 3