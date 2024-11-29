{% test positive_values(model, column_name) %}
    -- comprueba si el valor es positivo
    
   select *
   from {{ model }}
   where {{ column_name }} < 0


{% endtest %}