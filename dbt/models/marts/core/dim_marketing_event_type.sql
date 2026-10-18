{{ config(materialized='table') }}
select md5(event_type) marketing_event_type_key, event_type tipo, 
       case when upper(event_type) in ('CLICK','IMPRESSION','VIEW') then 'interaccion'
            when upper(event_type) in ('LEAD','CONVERSION') then 'conversion' else 'otro' end etapa
from (select distinct event_type from {{ ref('stg_marketing_campaigns__campaign_events') }})
