{{ config(
    materialized='incremental',
    unique_key = ['order_sk'],
    on_schema_change='fail',
    tags = ["incremental_orders"],
)
    }}



with int_orders as(    
    select * from {{ ref('int_orders') }}

    {% if is_incremental() %}
	  where orders_load > (select max(orders_load) from {{ this }}) 
    {% endif %}

),


dim_date as (
    select* from {{ ref('dim_date') }}
),

dim_users as (
    select* from {{ ref('dim_users') }}
),

dim_addresses as (
    select* from {{ ref('dim_addresses') }}
),

dim_products as (
    select * from {{ ref('dim_products') }}
),

dim_promos as (
    select * from {{ ref('dim_promos') }}
),
dim_shipping_service as(
    select * from {{ ref('dim_shipping_service') }}
),

fact_orders as(

    select
    --keys
        b.date_key,
        {{dbt_utils.generate_surrogate_key(['a.order_id' ,'a.product_id'])}} as order_sk,
        a.order_id,
        c.user_sk,  
        d.address_sk,
        e.shipping_service_sk,
        g.promo_sk,
        f.product_sk,              

    -- shipping_related
        a.status,

    -- measures (money related)

        a.quantity_sold,         
        a.unit_price_usd,
        a.gross_line_sales_usd,
        a.discount_line_amount_usd,
        a.shipping_line_revenue_usd,
        a.shipping_line_cost_usd,
        --net_line_sales_usd,
        round(a.gross_line_sales_usd + a.shipping_line_revenue_usd - a.discount_line_amount_usd - a.shipping_line_cost_usd , 2) as net_line_sales_usd,

        a.product_line_cost_usd,         
        a.diluded_operative_cost_usd,
        a.weight_line_lbs,

    -- measures (delivery/shipping related)
        {{ dbt.datediff("a.created_at_utc", "a.delivered_at_utc", "day") }} as days_to_deliver,
        {{ dbt.datediff("a.estimated_delivery_at_utc", "a.delivered_at_utc", "day") }} as deliver_precision_days,  
        
    -- just in case you need
        a.created_at_utc,              
        a.created_at_date,
        to_char(date_trunc('hour', a.created_at_utc), 'HH24MI') as time_key,
        a.orders_load,

        '{{invocation_id}}' as batch_id         
 
    from int_orders a

    left join dim_date b on b.date_day = a.created_at_date
    left join dim_users c on c.user_id = a.user_id
    left join dim_addresses d on d.address_id = a.address_id
    left join dim_shipping_service e on e.shipping_service = a.shipping_service
    left join dim_products f on f.product_id = a.product_id
    left join dim_promos g on g.promo_id = a.promo_id

    

)

select * from fact_orders order by 22