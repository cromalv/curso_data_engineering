{% snapshot src_users_snap %}

{{
    config(
      target_schema='snapshots',
      unique_key='user_id',
      strategy='timestamp',
      updated_at='updated_at',
      invalidate_hard_deletes=True,
    )
}}

select * from {{ source('src_sql_server_dbo', 'users') }}

{% endsnapshot %}