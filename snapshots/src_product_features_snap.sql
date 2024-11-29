{% snapshot src_product_features_snap %}

{{
    config(
      target_schema='snapshots',
      unique_key='md5(concat(product_id, begin_eff_date))',
      strategy='check',
      check_cols=['product_cost','begin_eff_date','end_eff_date'],
      invalidate_hard_deletes=True,
    )
}}


select 
    md5(concat(product_id, begin_eff_date)) as id,
    *
from {{ ref('product_features') }}

{% endsnapshot %}