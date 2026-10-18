{{ config(materialized='table') }}
with r as (select * from {{ ref('stg_finance__financial_reconciliation') }}),
p as (select * from {{ ref('stg_finance__payment_transactions') }})
select r.reconciliation_id, r.transaction_id, md5(p.seller_id) seller_key,
       to_number(to_char(r.reconciliation_date,'YYYYMMDD')) date_key,
       md5(r.reconciliation_status) reconciliation_status_key,
       r.expected_amount monto_esperado, r.received_amount monto_recibido,
       coalesce(r.difference_amount,r.expected_amount-r.received_amount) diferencia_monto,
       r.discrepancy_reason motivo_discrepancia, r.reconciliation_date fecha_conciliacion
from r left join p on r.transaction_id=p.transaction_id
