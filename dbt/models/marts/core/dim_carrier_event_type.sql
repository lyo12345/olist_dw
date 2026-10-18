{{ config(materialized='table') }}
select md5(event_type) carrier_event_type_key, event_type tipo,
       case when upper(event_type) in ('DELIVERED','DELIVERY') then 'entrega'
            when upper(event_type) in ('PICKUP','PICKED_UP') then 'recogida'
            when upper(event_type) in ('DELAY','DELAYED') then 'retraso'
            else 'transito' end etapa
from (select distinct event_type from {{ ref('stg_external_carrier__carrier_events') }})
