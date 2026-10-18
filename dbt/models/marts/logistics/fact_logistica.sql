{{ config(materialized='table') }}
with s as (select * from {{ ref('stg_logistics_tms__shipments') }}),
o as (select * from {{ ref('stg_olist__orders') }})
select
 s.shipment_id, s.order_id, md5(s.seller_id) seller_key, md5(s.customer_id) customer_key,
 case when s.carrier_id is null then null else md5(concat('TMS|',s.carrier_id)) end carrier_key,
 -- Nota: en Snowflake, concat/|| ya propaga NULL automáticamente (a diferencia de otros motores
 -- donde NULL se trata como cadena vacía), por lo que carrier_key ya salía NULL correctamente
 -- cuando carrier_id es NULL (~1.3% de envíos sin transportista documentado, ver data_quality_report.md).
 -- Se deja este CASE WHEN explícito por legibilidad y como salvaguarda ante un futuro cambio de motor.
 md5(s.route_id) route_key,
 to_number(to_char(s.shipment_date,'YYYYMMDD')) date_key,
 s.status estado_envio,
 datediff(day,o.order_purchase_timestamp,s.shipment_date) dias_preparacion,
 datediff(day,s.shipment_date,s.actual_delivery_date) dias_transito,
 datediff(day,o.order_purchase_timestamp,s.actual_delivery_date) dias_entrega_total,
 greatest(datediff(day,s.estimated_delivery_date,s.actual_delivery_date),0) dias_retraso,
 s.shipping_cost costo_envio,
 iff(s.actual_delivery_date is not null and s.actual_delivery_date<=s.estimated_delivery_date,1,0) indicador_entrega_a_tiempo,
 s.package_weight peso_paquete, s.package_volume volumen_paquete,
 s.shipment_date fecha_envio, s.estimated_delivery_date fecha_estimada_entrega, s.actual_delivery_date fecha_entrega
from s left join o on s.order_id=o.order_id
