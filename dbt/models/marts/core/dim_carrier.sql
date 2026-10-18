{{ config(materialized='table') }}
select md5(concat('TMS|',carrier_id)) carrier_key, carrier_id, 'TMS' source_system,
       carrier_name nombre_transportista, carrier_type tipo_transportista, region, service_level nivel_servicio,
       status estado
from {{ ref('stg_logistics_tms__carriers') }}
union all
select md5(concat('EXTERNAL|',carrier_id)) carrier_key, carrier_id, 'EXTERNAL' source_system,
       carrier_name, carrier_type, region, service_level, iff(active_flag=1,'ACTIVO','INACTIVO') estado
from {{ ref('stg_external_carrier__carriers') }}
