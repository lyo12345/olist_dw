-- Grano esperado: fact_campanas -> campaign_id, date_key
select campaign_id, date_key
from {{ ref('fact_campanas') }}
group by campaign_id, date_key
having count(*) > 1
