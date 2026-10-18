{{ config(materialized='table') }}
select md5(warehouse_id) warehouse_key, warehouse_id, warehouse_name nombre_almacen, city ciudad,
       state estado, capacity_units capacidad_unidades, warehouse_type tipo_almacen, status estado_almacen
from {{ ref('stg_erp_inventory__warehouses') }}
