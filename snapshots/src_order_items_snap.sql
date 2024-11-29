{% snapshot src_order_items_snap %}

{{
    config(
      target_schema='snapshots',
      unique_key="order_id||'-'||product_id",
      strategy='check',
      check_cols=['quantity','product_id'],   
    )
}}


select 
    order_id||'-'||product_id as id,
    * 
from {{ source('src_sql_server_dbo', 'order_items') }}

{% endsnapshot %}