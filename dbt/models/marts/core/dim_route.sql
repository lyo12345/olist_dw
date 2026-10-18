{{ config(materialized='table') }}
select md5(route_id) route_key, route_id, origin_state estado_origen, origin_city ciudad_origen,
       destination_state estado_destino, destination_city ciudad_destino, distance_km distancia_km,
       estimated_transit_days dias_transito_estimados, route_type tipo_ruta
from {{ ref('stg_logistics_tms__routes') }}
