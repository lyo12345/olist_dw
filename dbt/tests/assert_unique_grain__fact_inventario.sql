-- Grano esperado: fact_inventario -> inventory_id
select inventory_id
from {{ ref('fact_inventario') }}
group by inventory_id
having count(*) > 1
