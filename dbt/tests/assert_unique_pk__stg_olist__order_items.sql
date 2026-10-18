-- Verifica que la PK compuesta (order_id, order_item_id) de stg_olist__order_items sea unica.
-- El test PASA si esta consulta no devuelve filas.
select order_id, order_item_id, count(*) as n
from {{ ref('stg_olist__order_items') }}
group by order_id, order_item_id
having count(*) > 1
