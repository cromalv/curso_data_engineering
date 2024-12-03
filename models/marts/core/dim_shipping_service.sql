with stg_shipping_agreements as(
    select * from {{ ref('stg_sql_server_dbo__shipping_agreements') }}
),
dim_shipping_service as (
    select
        {{dbt_utils.generate_surrogate_key(['shipping_service'])}} as shipping_service_sk,
        shipping_service
    from stg_shipping_agreements
)

select * from dim_shipping_service