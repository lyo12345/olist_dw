{{ config(materialized='table') }}
select g.gateway_transaction_id, g.order_id, md5(g.gateway_id) gateway_key,
       to_number(to_char(g.transaction_timestamp,'YYYYMMDD')) date_key,
       md5(concat_ws('|',g.authorization_status,g.capture_status)) transaction_status_key,
       md5(concat_ws('|',coalesce(g.payment_type_source,''),coalesce(g.installments::varchar,''))) payment_key,
       g.amount monto_transaccion,
       iff(upper(g.authorization_status) in ('APPROVED','AUTHORIZED'),g.amount,0) monto_autorizado,
       iff(upper(g.capture_status) in ('CAPTURED','APPROVED'),g.amount,0) monto_capturado,
       coalesce(r.monto_reembolsado,0) monto_reembolsado,
       g.gateway_fee comision_pasarela, g.processing_time_ms tiempo_procesamiento_ms,
       g.transaction_timestamp fecha_transaccion
from {{ ref('stg_payment_gateway__gateway_transactions') }} g
left join (
 select gateway_transaction_id,sum(refund_amount) monto_reembolsado
 from {{ ref('stg_payment_gateway__refunds_gateway') }} group by gateway_transaction_id
) r on g.gateway_transaction_id=r.gateway_transaction_id
