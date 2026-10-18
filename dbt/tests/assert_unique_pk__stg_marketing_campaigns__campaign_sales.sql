-- Verifica que la PK compuesta (campaign_id, order_id, order_item_id) de stg_marketing_campaigns__campaign_sales sea unica.
-- El test PASA si esta consulta no devuelve filas.
select campaign_id, order_id, order_item_id, count(*) as n
from {{ ref('stg_marketing_campaigns__campaign_sales') }}
group by campaign_id, order_id, order_item_id
having count(*) > 1
