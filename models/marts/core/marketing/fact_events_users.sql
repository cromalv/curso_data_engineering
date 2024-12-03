
with fact_events as (
    select * from {{ ref('fact_events') }}
),

dim_users as(
    select * from {{ ref('dim_users') }}
),

event_type as(
    select
        session_id,
        user_sk,
        sum(case when event_type = 'checkout' then 1 else 0 end) as checkout,
        sum(case when event_type = 'package_shipped' then 1 else 0 end) as package_shipped,
        sum(case when event_type = 'add_to_cart' then 1 else 0 end) as add_to_cart,
        sum(case when event_type = 'page_view' then 1 else 0 end) as page_view
    from fact_events
    group by 1,2
),


session_lenght as(
    select
        user_sk,
        first_event_time_utc,
        last_event_time_utc,
        {{ dbt.datediff("first_event_time_utc", "last_event_time_utc", "minute") }} as session_lenght_minutes
    from (
            select
                user_sk,
                min(created_at_utc) as first_event_time_utc,
                max(created_at_utc) as last_event_time_utc
            from fact_events
            group by 1)
),

--select * from session_lenght

fact_events_users as(
    select
        a.session_id,
        b.user_id,
        b.full_name,
        b.email,
        c.first_event_time_utc,
        c.last_event_time_utc,
        c.session_lenght_minutes,
        d.page_view,
        d.add_to_cart,
        d.checkout,
        d.package_shipped   
        
    from fact_events a

    left join dim_users b on b.user_sk = a.user_sk
    left join session_lenght c on c.user_sk = a.user_sk
    left join event_type d on d.session_id = a.session_id
    group by 1,2,3,4,5,6,7,8,9,10,11
    order by 8 desc
)

select * from fact_events_users order by 7 desc, 8 desc