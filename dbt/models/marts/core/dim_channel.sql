{{ config(materialized='table') }}
with x as (
 select distinct channel as canal from {{ ref('stg_marketing_campaigns__campaign_events') }}
 union select distinct channel from {{ ref('stg_marketing_campaigns__campaign_channels') }}
 union select distinct ticket_channel from {{ ref('stg_customer_service__service_tickets') }}
 union select distinct channel from {{ ref('stg_customer_service__ticket_interactions') }}
 union select distinct origin from {{ ref('stg_marketing_funnel__mql') }}
 union select 'UNKNOWN'
)
select md5(upper(trim(canal))) channel_key, upper(trim(canal)) nombre_canal,
       case when upper(trim(canal)) in ('EMAIL','E-MAIL') then 'EMAIL'
            when upper(trim(canal)) in ('SOCIAL','SOCIAL_MEDIA') then 'SOCIAL'
            when upper(trim(canal)) in ('PHONE','TELEFONO') then 'PHONE'
            when upper(trim(canal)) in ('UNKNOWN','SIN_DATO') then 'UNKNOWN'
            else upper(trim(canal)) end grupo_canal,
       case when upper(trim(canal)) in ('EMAIL','E-MAIL','SOCIAL','SOCIAL_MEDIA') then 'digital'
            else 'servicio' end modalidad
from x where canal is not null
