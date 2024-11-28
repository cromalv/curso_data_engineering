with src_budget_products as(

    select *
    from {{ source('src_google_sheets', 'budget') }}
),

budget as (
    select
        {{dbt_utils.generate_surrogate_key( ['_row'])}} as budget_sk,
        product_id,
        quantity as target_quantity,
        month as month_budget,
        _fivetran_synced AS date_load
    from src_budget_products
    order by 4 asc
    )

select * from budget