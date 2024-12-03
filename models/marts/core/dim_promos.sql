with stg_promos as (
    select * from {{ ref('stg_sql_server_dbo__promos') }}
),

dim_promos as(
    select
        {{dbt_utils.generate_surrogate_key(['promo_id','promo_discount_percent'])}} as promo_sk,
        promo_id,
        promo_discount_percent,
        decode(promo_discount_percent,null,0,promo_discount_percent/100) as discount_unit,
        promo_status

    from stg_promos
    )

select * from dim_promos