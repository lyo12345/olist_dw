{{ config(materialized='table') }}
select e.carrier_event_id, e.shipment_id, md5(concat('EXTERNAL|',e.carrier_id)) carrier_key,
       to_number(to_char(e.event_timestamp,'YYYYMMDD')) date_key,
       md5(e.event_type) carrier_event_type_key,
       1 cantidad_evento,
       -- minutos_retraso siempre NULL: la fuente External Carrier (carrier_events) no reporta
       -- este dato directamente. Ver descripción en _marts__models.yml para el detalle.
       cast(null as float) minutos_retraso,
       e.event_timestamp fecha_evento,
       e.event_status estado_evento, e.location ubicacion, e.hub_id
from {{ ref('stg_external_carrier__carrier_events') }} e
