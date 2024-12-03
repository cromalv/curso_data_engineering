{{ config(
    materialized='incremental',
    unique_key = ['order_id','product_id'],
    on_schema_change='fail',
    tags = ["incremental_orders"],
)
    }}


with stg_order_items as (
    select * from {{ ref('stg_sql_server_dbo__order_items') }}
    
    {% if is_incremental() %}
	  where date_load > (select max(order_items_load) from {{ this }}) 
    {% endif %}
),

stg_orders as (
    select * from {{ ref('stg_sql_server_dbo__orders') }}
    
    {% if is_incremental() %}
	  where date_load > (select max(orders_load) from {{ this }}) 
{% endif %}

),

-- an 'intermediate model' to join stg_orders and stg_order_items

sub_int_orders as (
    select

        a.order_id,
        b.user_id,
        b.address_id,
        a.product_id,
        a.quantity_sold,                                   --5
        b.promo_id,
        b.status,
        b.shipping_service,
        b.tracking_id,
        b.created_at_utc,                                  
        b.estimated_delivery_at_utc,                       --10
        b.delivered_at_utc,
        a.date_load as order_items_load,
        b.date_load as orders_load

    from stg_order_items as a
    full outer join stg_orders as b on b.order_id = a.order_id
    order by 1
),

-- the next 3 queries allows ut to have a monthly table with "quantity_sold" and "operative_costs" per month, 
-- the Goal? to join the operative costs per month inside the intermediate model and have a value per line of order_product.
-- this way we ensure operative cost/per product "is monthly dynamic", meaning, 
-- relates a sale and the operative costs for a certain month.

int_summary_orders as(
    select
        date_trunc('month', created_at_utc) as month,
        sum(quantity_sold) as monthly_quantity_sold
    from sub_int_orders
    group by 1
),

oper_accounting as(
    select 
        date_trunc('month', invoice_date) as month,
        sum(total_invoice) as monthly_operative_usd
    from {{ ref('stg_sql_server_dbo__accounting') }}
    where scope = 'operative'
    group by 1
),

int_operative_costs as(
    select
        a.month,
        a.monthly_operative_usd,
        b.monthly_quantity_sold
    from oper_accounting a
    join int_summary_orders b on b.month=a.month
),

--this query brings the correct discount

stg_promos as(
    select * from {{ ref('stg_sql_server_dbo__promos') }}
),

--this query brings the correct historical price

stg_price_history as(
    select * from {{ ref('stg_sql_server_dbo__price_history') }}
),

--this query brings the correct product_cost
stg_product_features as(
    select * from {{ ref('stg_sql_server_dbo__product_features') }}
),

--this query brings the correct shipping_agreement
stg_shipping_agreements as(
    select * from {{ ref('stg_sql_server_dbo__shipping_agreements') }}
),

--this query brings the total products per order
int_count_orders_quantity as( 

    select
        order_id,
        case when sum(quantity_sold) <=0 then 1 
        else sum(quantity_sold) end as total_quantity_sold
    from {{ ref('stg_sql_server_dbo__order_items') }}
    group by 1
    order by 1
),


int_orders as(
    select
    --keys
        a.order_id,
        a.user_id,
        a.address_id,
        a.product_id,
        a.promo_id,   

    -- measures
        a.quantity_sold,
        c.price_usd as unit_price_usd,
        -- gross_sales_usd
        (a.quantity_sold * c.price_usd) as gross_line_sales_usd,   

        -- discount_amount_usd_per_line 
        ((f.promo_discount_percent/100) * (a.quantity_sold*c.price_usd))::decimal(24,2) as discount_line_amount_usd,

        -- total_products_cost_per_line
        (d.product_cost_usd * a.quantity_sold) as product_line_cost_usd,
        
        -- shipping_revenue (known as "shipping_cost" on the source)
        round(g.shipping_cost_usd*(a.quantity_sold/h.total_quantity_sold) ,2) as shipping_line_revenue_usd,

        -- total_shipping_cost_agreement (this is the real 'shipping_cost')
        round((a.quantity_sold * d.product_weight_lbs * e.price_usd_per_lbs ), 2) as shipping_line_cost_usd, 

        -- diluded_operative_cost_per_line
        round((a.quantity_sold * b.monthly_operative_usd / b.monthly_quantity_sold) , 2)::decimal(24,4) as diluded_operative_cost_usd,
    
    --shipping_related
        a.status,
        a.shipping_service,                 
        --a.tracking_id,                     --just-in-case
        (d.product_weight_lbs * a.quantity_sold) as weight_line_lbs,    

    --dates related
        a.created_at_utc as created_at_utc,                                  
        a.estimated_delivery_at_utc as estimated_delivery_at_utc,
        a.delivered_at_utc as delivered_at_utc,
        a.created_at_utc::date as created_at_date,                    
        a.order_items_load,
        a.orders_load,

        '{{invocation_id}}' as batch_id
          
    from sub_int_orders a
    
    left join int_operative_costs b on b.month = date_trunc('month', a.created_at_utc)
    left join stg_price_history c on c.product_id = a.product_id AND a.created_at_utc between c.begin_eff_date and c.end_eff_date
    left join stg_product_features d on d.product_id = a.product_id AND a.created_at_utc between d.begin_eff_date and d.end_eff_date
    left join stg_shipping_agreements e on e.shipping_service = a.shipping_service AND a.created_at_utc between e.begin_eff_date and e.end_eff_date
    left join stg_promos f on f.promo_id = a.promo_id
    left join stg_orders g on g.order_id = a.order_id
    left join int_count_orders_quantity h on h.order_id = a.order_id
)

select * from int_orders order by 17
