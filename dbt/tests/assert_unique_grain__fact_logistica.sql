-- Grano esperado: fact_logistica -> shipment_id
select shipment_id
from {{ ref('fact_logistica') }}
group by shipment_id
having count(*) > 1
