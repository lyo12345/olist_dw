{{ config(materialized='table') }}
select i.interaction_id, i.ticket_id, md5(t.customer_id) customer_key, md5(i.agent_id) agent_key,
       to_number(to_char(i.interaction_timestamp,'YYYYMMDD')) date_key,
       md5(upper(trim(i.channel))) channel_key,
       1 cantidad_interaccion, i.response_time_minutes minutos_respuesta,
       i.interaction_timestamp fecha_interaccion, i.interaction_type tipo_interaccion,
       i.interaction_text texto_interaccion, i.sentiment_label etiqueta_sentimiento
from {{ ref('stg_customer_service__ticket_interactions') }} i
left join {{ ref('stg_customer_service__service_tickets') }} t on i.ticket_id=t.ticket_id
