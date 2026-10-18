{{ config(materialized='table') }}
with s as (select * from {{ ref('stg_olist__sellers') }}),
a as (select * from {{ ref('stg_finance__seller_accounts') }})
select
  md5(s.seller_id) as seller_key, s.seller_id,
  s.seller_city as ciudad, s.seller_state as estado, s.seller_zip_code_prefix as codigo_postal,
  case when s.seller_state in ('SP','RJ','MG','ES') then 'Sudeste'
       when s.seller_state in ('PR','SC','RS') then 'Sul'
       when s.seller_state in ('BA','PE','CE','MA','PB','RN','AL','SE','PI') then 'Nordeste'
       when s.seller_state in ('GO','MT','MS','DF') then 'Centro-Oeste'
       when s.seller_state in ('AM','PA','AC','RO','RR','AP','TO') then 'Norte'
       else 'Sin clasificar' end as region,
  a.account_status as estado_cuenta, a.settlement_frequency as frecuencia_liquidacion,
  a.commission_rate as tasa_comision
from s left join a on s.seller_id=a.seller_id
