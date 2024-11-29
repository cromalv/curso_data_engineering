{% snapshot src_shipping_agreements_snap %}

{{
    config(
      target_schema='snapshots',
      unique_key='md5(concat(shipping_service, price_usd_per_lbs, begin_eff_date))',
      strategy='check',
      check_cols=['price_usd_per_lbs','begin_eff_date','end_eff_date'],
      invalidate_hard_deletes=True,
    )
}}


select 
    md5(concat(shipping_service, price_usd_per_lbs, begin_eff_date)) as id,
    *
from {{ ref('shipping_agreements') }}

{% endsnapshot %}