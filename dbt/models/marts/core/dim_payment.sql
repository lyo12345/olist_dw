{{ config(materialized='table') }}
-- Dim_Pago es una dimensión conformada compartida por Fact_Pagos (Olist) y
-- Fact_Transacciones_Pasarela (Payment Gateway). Se unen ambas fuentes para
-- evitar payment_key huérfanas cuando la pasarela reporta combinaciones
-- tipo/cuotas que Olist nunca genera (bug detectado en revisión).
with olist_pagos as (
 select distinct payment_type as tipo_pago, payment_installments as cuotas
 from {{ ref('stg_olist__order_payments') }}
),
gateway_pagos as (
 select distinct payment_type_source as tipo_pago, installments as cuotas
 from {{ ref('stg_payment_gateway__gateway_transactions') }}
),
x as (
 select * from olist_pagos
 union
 select * from gateway_pagos
)
select md5(concat_ws('|',coalesce(tipo_pago,''),coalesce(cuotas::varchar,''))) payment_key,
       tipo_pago as tipo, tipo_pago as metodo, cuotas as condicion_cuotas,
       case when tipo_pago in ('credit_card','debit_card') then 'tarjeta'
            when tipo_pago='boleto' then 'efectivo_boleto'
            when tipo_pago='voucher' then 'voucher'
            when tipo_pago='pix' then 'pago_instantaneo' else 'otro' end categoria
from x
