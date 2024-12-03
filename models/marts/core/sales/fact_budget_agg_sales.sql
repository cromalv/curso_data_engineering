with int_orders as(
    select
        product_id,
        date_trunc('month', created_at_utc) as month,
        sum(quantity_sold) as sum_quantity_sold

    from {{ ref('int_orders') }}
    group by 1,2
),
stg_budget as (
    select
        product_id,
        date_trunc('month', month_budget) as month_budget,
        target_quantity

    from {{ ref('stg_google_sheets__budget') }}
),
dim_products as (

    select
        product_sk,
        product_id
    from {{ ref('dim_products') }}
),
dim_date as (
    select
        date_key,
        date_day
    from {{ ref('dim_date') }}
),

join_tables as(
    select
        c.date_key,
        b.product_id as product_id,    
        b.month_budget as month_budget,
        b.target_quantity as target_quantity,
        a.sum_quantity_sold as quantity_sold,
        case when a.sum_quantity_sold >= b.target_quantity then 1
             else 0 end as flag_goal,
        (round(a.sum_quantity_sold / b.target_quantity ,0 ) *100 )-1 as goal_target_diff_percentage

    from int_orders a
    right join stg_budget b on b.product_id = a.product_id AND b.month_budget = a.month
    left join dim_date c on c.date_day = a.month
    left join dim_products d on d.product_id = a.product_id
    order by 1 asc
)

select * from join_tables order by 1
