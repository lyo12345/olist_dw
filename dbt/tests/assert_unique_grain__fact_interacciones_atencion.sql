-- Grano esperado: fact_interacciones_atencion -> interaction_id
select interaction_id
from {{ ref('fact_interacciones_atencion') }}
group by interaction_id
having count(*) > 1
