{{ config(materialized='table') }}
with c as (select * from {{ ref('stg_olist__customers') }}),
crm as (select * from {{ ref('stg_customer_service__customers_crm') }})
select
  md5(c.customer_id) as customer_key,
  c.customer_id, c.customer_unique_id, c.customer_city as ciudad, c.customer_state as estado,
  c.customer_zip_code_prefix as codigo_postal,
  case when c.customer_state in ('SP','RJ','MG','ES') then 'Sudeste'
       when c.customer_state in ('PR','SC','RS') then 'Sul'
       when c.customer_state in ('BA','PE','CE','MA','PB','RN','AL','SE','PI') then 'Nordeste'
       when c.customer_state in ('GO','MT','MS','DF') then 'Centro-Oeste'
       when c.customer_state in ('AM','PA','AC','RO','RR','AP','TO') then 'Norte'
       else 'Sin clasificar' end as region,
  coalesce(crm.customer_segment,'sin_dato') as segmento,
  crm.preferred_channel as canal_preferido,
  crm.loyalty_level as nivel_lealtad,
  crm.status as estado_cliente
from c left join crm on c.customer_id=crm.customer_id
