{{ config(materialized='table') }}
select i.incident_id, i.shipment_id, md5(concat('EXTERNAL|',i.carrier_id)) carrier_key,
       to_number(to_char(i.incident_timestamp,'YYYYMMDD')) date_key,
       md5(concat_ws('|',i.incident_type,i.severity)) incident_type_key,
       1 cantidad_incidencia,
       datediff(minute,i.incident_timestamp,i.resolution_timestamp) minutos_resolucion,
       iff(upper(i.severity) in ('HIGH','CRITICAL','SEVERE'),1,0) indicador_incidencia_grave,
       i.incident_timestamp fecha_incidencia, i.resolution_status estado_resolucion
from {{ ref('stg_external_carrier__carrier_incidents') }} i
