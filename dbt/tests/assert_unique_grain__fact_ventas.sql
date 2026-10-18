-- Grano esperado: fact_ventas -> order_id, order_item_id
select order_id, order_item_id
from {{ ref('fact_ventas') }}
group by order_id, order_item_id
having count(*) > 1
