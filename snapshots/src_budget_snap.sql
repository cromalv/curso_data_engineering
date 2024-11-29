{% snapshot src_budget_snap %}

{{
    config(
      target_schema='snapshots',
      unique_key='_row',
      strategy='timestamp',
      updated_at='_fivetran_synced',
      invalidate_hard_deletes=True,
    )
}}
--check_cols=['quantity','product_id'],

select * from {{ source('src_google_sheets', 'budget') }}

{% endsnapshot %}