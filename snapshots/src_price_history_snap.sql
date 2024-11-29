{% snapshot src_price_history_snap %}

{{
    config(
      target_schema='snapshots',
      unique_key='md5(concat(product_id, price, begin_eff_date))',
      strategy='check',
      check_cols=['price','begin_eff_date','end_eff_date'],
      invalidate_hard_deletes=True,
    )
}}


select 
    md5(concat(product_id, price, begin_eff_date)) as id,
    *
from {{ ref('price_history') }}

{% endsnapshot %}