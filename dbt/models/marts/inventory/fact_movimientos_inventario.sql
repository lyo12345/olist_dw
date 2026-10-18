{{ config(materialized='table') }}
select movement_id, md5(product_id) product_key, md5(warehouse_id) warehouse_key,
       to_number(to_char(movement_date,'YYYYMMDD')) date_key,
       quantity cantidad_movimiento, unit_cost costo_unitario, total_cost costo_total,
       movement_type tipo_movimiento, reference_type tipo_referencia, reference_id referencia_id,
       reason motivo, created_by creado_por, movement_date fecha_movimiento
from {{ ref('stg_erp_inventory__inventory_movements') }}
