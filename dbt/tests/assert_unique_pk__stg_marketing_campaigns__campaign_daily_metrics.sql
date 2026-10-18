-- Verifica que la PK compuesta (campaign_id, metric_date) de stg_marketing_campaigns__campaign_daily_metrics sea unica.
-- El test PASA si esta consulta no devuelve filas.
select campaign_id, metric_date, count(*) as n
from {{ ref('stg_marketing_campaigns__campaign_daily_metrics') }}
group by campaign_id, metric_date
having count(*) > 1
