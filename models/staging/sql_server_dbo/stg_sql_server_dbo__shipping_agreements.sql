
with stg_sql_server_dbo__shipping_agreements as(
    select
        shipping_service::varchar(50) as shipping_service,
        price_usd_per_lbs::decimal(12,2) as price_usd_per_lbs,
        begin_eff_date::timestamp as begin_eff_date,
        end_eff_date::timestamp as end_eff_date
    from {{ ref('src_shipping_agreements_snap') }}
    where dbt_valid_to is null
)
select * from stg_sql_server_dbo__shipping_agreements
union all
select * from ( values (
            'not_assigned',
            '0',
            '1900-01-01',
            '2140-01-01')
        )