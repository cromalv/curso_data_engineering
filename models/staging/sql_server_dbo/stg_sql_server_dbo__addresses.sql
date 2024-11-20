{{
  config(
    materialized='view'
  )
}}


with source as (

    select * from {{ source('sql_server_dbo', 'addresses') }}

),

renamed as (

    select
        ADDRESS_ID,
        LPAD(ZIPCODE, 5, '0') AS ZIPCODE,
        UPPER(COUNTRY) AS COUNTRY,
        INITCAP(ADDRESS) AS ADDRESS,
        UPPER(STATE) AS STATE,
        _FIVETRAN_DELETED,
        _FIVETRAN_SYNCED

    from source

)

select * from renamed
