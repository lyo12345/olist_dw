{{ config(materialized='table') }}
with t as (select * from {{ ref('stg_customer_service__service_tickets') }}),
ia as (select ticket_id,count(*) cantidad_interacciones from {{ ref('stg_customer_service__ticket_interactions') }} group by ticket_id)
select t.ticket_id, md5(t.customer_id) customer_key, md5(t.assigned_agent_id) agent_key,
       to_number(to_char(t.ticket_date,'YYYYMMDD')) date_key,
       md5(concat_ws('|',coalesce(t.issue_category,''),coalesce(t.issue_subcategory,''),coalesce(t.priority,''))) ticket_type_key,
       md5(upper(trim(t.ticket_channel))) channel_key,
       1 cantidad_ticket,
       datediff(minute,t.ticket_date,t.first_response_timestamp) minutos_primera_respuesta,
       datediff(minute,t.ticket_date,t.resolution_timestamp) minutos_resolucion,
       coalesce(ia.cantidad_interacciones,0) cantidad_interacciones,
       t.satisfaction_score puntuacion_satisfaccion,
       iff(t.escalation_flag,1,0) indicador_escalamiento,
       t.status estado_ticket, t.ticket_date fecha_ticket
from t left join ia on t.ticket_id=ia.ticket_id
