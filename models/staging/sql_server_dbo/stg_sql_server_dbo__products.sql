with products as(

    select * 
    from {{ ref('src_products_snap') }}
),
no_product_row as(
select * from (values ('no_product','no_product',0,1,'2140-01-01' ))
),

stg_sql_server_dbo__products as(
    select
        product_id::varchar(50) as product_id,
        name::varchar(50) as product_name,
        price::decimal(24,2) as msrp_price_usd,   --MSRP (Manufacturer's Suggested Retail Price) 
        inventory::int as inventory,
        dbt_updated_at::timestamp as updated_at

    from products
    where dbt_valid_to is null
)

select *  from stg_sql_server_dbo__products
union all 
select * from no_product_row