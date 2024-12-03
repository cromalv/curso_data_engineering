with stg_state as(
    select distinct state 
    from {{ ref('stg_sql_server_dbo__addresses') }}
    order by 1 asc
),
dim_state as(
    select
        {{dbt_utils.generate_surrogate_key(['state'])}} as state_sk,
        *
from stg_state
)
select * from dim_state