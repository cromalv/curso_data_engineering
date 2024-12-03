with stg_users as (
    select * 
    from {{ ref('stg_sql_server_dbo__users') }}
    ),
dim_addresses as (
    select * from {{ ref('dim_addresses') }}
),
dim_date as (
    select * from {{ ref('dim_date') }}
),

dim_users as (
    select
        b.date_key,
        {{dbt_utils.generate_surrogate_key(['a.user_id','a.first_name','a.last_name'])}} as user_sk,
        a.user_id,
        c.address_sk,
        a.first_name || ' ' || a.last_name as full_name,
        a.email,
        a.phone_number,
        a.created_at_utc,
        a.updated_at_utc
        
    from stg_users a
    left join dim_date b on b.date_day=a.created_at_utc
    left join dim_addresses c on c.address_id = a.address_id
    )

select * from dim_users