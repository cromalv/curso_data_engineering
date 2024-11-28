with stg_date as (
{{ dbt_date.get_date_dimension("2020-01-01", "2025-01-01") }}

),
stg_date_1900 as (
{{ dbt_date.get_date_dimension("1900-01-01", "1900-01-02") }}
),
stg_date_2140 as (
{{ dbt_date.get_date_dimension("2140-01-01", "2140-01-02") }}
)
select * from stg_date_2140
union all
select * from stg_date_1900
union all
select * from stg_date
