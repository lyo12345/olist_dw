-- Grano esperado: fact_liquidaciones -> settlement_id
select settlement_id
from {{ ref('fact_liquidaciones') }}
group by settlement_id
having count(*) > 1
