-- Grano esperado: fact_eventos_pasarela -> gateway_event_id
select gateway_event_id
from {{ ref('fact_eventos_pasarela') }}
group by gateway_event_id
having count(*) > 1
