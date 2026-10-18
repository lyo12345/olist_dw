-- Grano esperado: fact_conciliaciones -> reconciliation_id
select reconciliation_id
from {{ ref('fact_conciliaciones') }}
group by reconciliation_id
having count(*) > 1
