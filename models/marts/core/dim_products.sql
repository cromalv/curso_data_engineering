with stg_products as(
    select * from {{ ref('stg_sql_server_dbo__products') }}
),
stg_product_features as(
    select * from {{ ref('stg_sql_server_dbo__product_features') }}
),

dim_products as (

    select
        {{dbt_utils.generate_surrogate_key(['a.product_id','a.product_name'])}} as product_sk,
        a.product_id,
        a.product_name,
        a.msrp_price_usd,
        decode(b.product_weight_lbs,null,0,b.product_weight_lbs) as product_weight_lbs,
        a.updated_at
    from stg_products a
    left join stg_product_features b on b.product_id=a.product_id 
    AND a.updated_at >= b.begin_eff_date
    AND a.updated_at <= b.end_eff_date
)

select * from dim_products order by 2