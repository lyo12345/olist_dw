{{ config(materialized='table') }}
select e.gateway_event_id, e.gateway_transaction_id, md5(g.gateway_id) gateway_key,
       to_number(to_char(e.event_timestamp,'YYYYMMDD')) date_key,
       md5(e.event_type) gateway_event_type_key,
       1 cantidad_evento, e.processing_time_ms duracion_evento,
       iff(e.event_status in ('FAILED','ERROR','REJECTED'),1,0) indicador_fallo,
       e.event_timestamp fecha_evento, e.event_status estado_evento
from {{ ref('stg_payment_gateway__gateway_events') }} e
left join {{ ref('stg_payment_gateway__gateway_transactions') }} g
 on e.gateway_transaction_id=g.gateway_transaction_id
