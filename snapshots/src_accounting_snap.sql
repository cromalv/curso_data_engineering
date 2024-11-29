{% snapshot src_accounting_snap %}

{{
    config(
      target_schema='snapshots',
      unique_key='md5(concat(scope, type, vendor, category, description, invoice_date, total))',
      strategy='check',
      check_cols=['scope','vendor','category','invoice_date','total'],
      invalidate_hard_deletes=True,
    )
}}


select 
    md5(concat(scope, type, vendor, category, description, invoice_date, total)) as id,
    *
from {{ ref('accounting') }}

{% endsnapshot %}