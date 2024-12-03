with accounting as (
    select 
        scope,
        category,
        date_trunc('month', invoice_date) as month,
        sum(total_invoice) as total_usd
    from {{ ref('stg_sql_server_dbo__accounting') }}
    group by 1,2,3
),

wages as (
    select
        'structural' as scope,     
        'wages' as category,
        date_trunc('month', wage_month) as month,
        sum(monthly_wage) as total_usd
    from {{ ref('stg_sql_server_dbo__wages') }}
    group by 1,2,3
)

select * from accounting
union all
select * from wages