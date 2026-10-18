{{ config(materialized='table') }}
select s.settlement_id, md5(s.seller_id) seller_key,
       to_number(to_char(s.settlement_date,'YYYYMMDD')) date_key,
       md5(s.settlement_status) settlement_status_key,
       s.gross_sales ventas_brutas, s.commissions comisiones, s.freight_charges cargos_flete,
       s.refunds reembolsos, s.adjustments ajustes, s.net_settlement liquidacion_neta,
       s.settlement_date fecha_liquidacion
from {{ ref('stg_finance__seller_settlements') }} s
