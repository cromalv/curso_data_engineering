with stg_date as(
    select * from {{ ref('stg_sql_server_dbo__date') }}
),

dim_date as(

    select
        to_char(date_day, 'YYYYMMDD') AS date_key,
        date_day,
        day_of_week as day_of_week_number,
        day_of_week_name,
        day_of_week_name_short,
        day_of_month as day_of_month_number,
        month_of_year,
        month_name,
        month_name_short,
        day_of_year as day_of_year_number,
        week_of_year as week_of_year_number,
        quarter_of_year as quarter_of_year_number,
        year_number
    from stg_date

)
select * from dim_date order by date_day