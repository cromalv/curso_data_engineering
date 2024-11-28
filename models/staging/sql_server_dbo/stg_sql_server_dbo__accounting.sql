
with stg_accounting as(
    select
        scope::varchar(50) as scope,
        type::varchar(50) as type,
        vendor::varchar(50) as vendor,
        category::varchar(50) as category,
        description::varchar(100) as description,
        invoice_date::date as invoice_date,
        total::decimal(12,2) as total_invoice
    
    from {{ ref("src_accounting_snap") }}
    where dbt_valid_to is null
)
select * from stg_accounting