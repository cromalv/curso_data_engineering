with addresses as(

    select * 
    from {{ source('src_sql_server_dbo', 'addresses') }}
),
no_address_row as(
     select * from (values('no_address','unknown','unknown','unknown','unknown','1900-01-01'))
),

stg_addresses as(
select
    address_id::varchar(50) as address_id,
    country::varchar(50) as country,
    state::varchar(50) as state,
    zipcode::varchar(50) as zipcode,
    address::varchar(100) as address,
    _FIVETRAN_SYNCED as date_load
from addresses
)

select *  from stg_addresses
union all
select * from no_address_row