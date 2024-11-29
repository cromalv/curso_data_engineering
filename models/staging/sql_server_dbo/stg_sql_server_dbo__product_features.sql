with stg_sql_server_dbo__product_features as(
    select
        product_id::varchar as product_id,
        product_cost::decimal(12,2) as product_cost_usd,
        product_weight::decimal(12,2) as product_weight_lbs,
        begin_eff_date::timestamp as begin_eff_date,
        end_eff_date::timestamp as end_eff_date
    from {{ ref('src_product_features_snap') }}
    where dbt_valid_to is null
)
select * from stg_sql_server_dbo__product_features order by product_id