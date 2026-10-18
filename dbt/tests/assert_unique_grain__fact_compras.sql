-- Grano esperado: fact_compras -> purchase_order_item_id
select purchase_order_item_id
from {{ ref('fact_compras') }}
group by purchase_order_item_id
having count(*) > 1
