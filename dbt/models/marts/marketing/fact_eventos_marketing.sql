{{ config(materialized='table') }}
select e.event_id, md5(e.campaign_id) campaign_key, md5(e.customer_id) customer_key,
       to_number(to_char(e.event_timestamp,'YYYYMMDD')) date_key,
       md5(upper(trim(e.channel))) channel_key, md5(e.event_type) marketing_event_type_key,
       e.event_timestamp fecha_evento, e.device_type dispositivo, e.region region,
       1 cantidad_evento, iff(e.conversion_flag,1,0) indicador_conversion
from {{ ref('stg_marketing_campaigns__campaign_events') }} e
