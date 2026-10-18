{{ config(materialized='table') }}
with i as (select * from {{ ref('stg_erp_inventory__purchase_order_items') }}),
o as (select * from {{ ref('stg_erp_inventory__purchase_orders') }})
select i.purchase_order_item_id, i.purchase_order_id, md5(i.product_id) product_key,
       md5(o.supplier_id) supplier_key, md5(o.warehouse_id) warehouse_key,
       to_number(to_char(o.order_date,'YYYYMMDD')) date_key,
       i.quantity_ordered cantidad_solicitada, i.quantity_received cantidad_recibida,
       i.quantity_ordered-coalesce(i.quantity_received,0) cantidad_pendiente,
       i.unit_cost costo_unitario, i.discount descuento, i.tax impuesto, i.line_total costo_total,
       datediff(day,o.order_date,o.received_date) dias_abastecimiento,
       o.order_date fecha_pedido, o.expected_date fecha_esperada, o.received_date fecha_recepcion,
       o.status estado_compra
from i join o on i.purchase_order_id=o.purchase_order_id
