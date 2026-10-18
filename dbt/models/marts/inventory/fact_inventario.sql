{{ config(materialized='table') }}
select
 i.inventory_id, md5(i.product_id) product_key, md5(i.warehouse_id) warehouse_key,
 to_number(to_char(i.snapshot_date,'YYYYMMDD')) date_key,
 md5(i.stockout_flag::varchar) stock_status_key,
 i.opening_stock stock_inicial, i.received_units unidades_recibidas, i.sold_units unidades_vendidas,
 i.reserved_units unidades_reservadas, i.damaged_units unidades_danadas, i.adjusted_units unidades_ajustadas,
 i.closing_stock stock_final, i.reorder_point punto_reorden, i.safety_stock stock_seguridad,
 i.stockout_flag indicador_agotamiento, i.snapshot_date fecha_snapshot
from {{ ref('stg_erp_inventory__inventory') }} i
