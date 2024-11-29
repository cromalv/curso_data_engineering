{% snapshot src_products_snap %}

{{
    config(
      target_schema='snapshots',
      unique_key='product_id',
      strategy='timestamp',
      updated_at='_fivetran_synced',
      invalidate_hard_deletes=True,
    )
}}
--check_cols=['price','inventory'],

select * from {{ source('src_sql_server_dbo', 'products') }}

{% endsnapshot %}