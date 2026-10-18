-- Grano esperado: fact_eventos_transportista -> carrier_event_id
select carrier_event_id
from {{ ref('fact_eventos_transportista') }}
group by carrier_event_id
having count(*) > 1
