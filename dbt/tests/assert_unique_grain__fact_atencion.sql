-- Grano esperado: fact_atencion -> ticket_id
select ticket_id
from {{ ref('fact_atencion') }}
group by ticket_id
having count(*) > 1
