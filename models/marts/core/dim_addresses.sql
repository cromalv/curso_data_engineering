
with stg_addresses as(

    select * from {{ ref('stg_sql_server_dbo__addresses') }}
),

dim_addresses as(
  
    select
        {{dbt_utils.generate_surrogate_key(['address_id','address'])}} as address_sk,
        address_id,
        country,
        state,
        zipcode,
        address
    from stg_addresses
)

select * from dim_addresses