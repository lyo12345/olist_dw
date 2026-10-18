-- Grano esperado: fact_leads -> mql_id
select mql_id
from {{ ref('fact_leads') }}
group by mql_id
having count(*) > 1
