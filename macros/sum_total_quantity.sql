{% macro sum_quantity_sold() %}
    SELECT
        SUM(quantity_sold)
    FROM {{ ref('stg_sql_server_dbo__order_items') }}
{% endmacro %}