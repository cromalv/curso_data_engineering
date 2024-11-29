with personas as (
    select * from {{ ref('personas') }}
),

wages as(
    select * from {{ ref('wages') }}
),

stg_sql_server_dbo__wages as(
    select
        b.emp_id::int as emp_id,
        (b.first_name || ' ' || b.last_name)::varchar(100) as full_name,
        b.department::varchar(50) as department,
        a.wage_month::date as wage_month,
        round(b.gross_income_year/12 , 2)::decimal(24,2) as monthly_wage 
    from wages a
    left join personas b on b.emp_id = a.emp_id
)

select * from stg_sql_server_dbo__wages