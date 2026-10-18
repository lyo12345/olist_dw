{{ config(materialized='table') }}
with oi as (select * from {{ ref('stg_olist__order_items') }}),
o as (select * from {{ ref('stg_olist__orders') }})
select
 oi.order_id, oi.order_item_id, md5(oi.product_id) product_key, md5(oi.seller_id) seller_key,
 md5(o.customer_id) customer_key,
 to_number(to_char(o.order_purchase_timestamp,'YYYYMMDD')) date_key,
 c.geography_key geography_key,
 md5(o.order_status) order_status_key,
 1 cantidad_articulos, oi.price precio, oi.freight_value flete,
 oi.price + oi.freight_value valor_articulo,
 o.order_purchase_timestamp fecha_venta
from oi join o on oi.order_id=o.order_id
left join (
  select dc.*, dg.geography_key
  from {{ ref('dim_customer') }} dc
  left join {{ ref('dim_geography') }} dg on dg.codigo_postal=dc.codigo_postal
) c on c.customer_id=o.customer_id
