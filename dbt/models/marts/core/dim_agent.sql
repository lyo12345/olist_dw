{{ config(materialized='table') }}
select md5(agent_id) agent_key, agent_id, agent_name nombre_agente, team equipo, region,
       hiring_date fecha_contratacion, status estado, experience_level nivel_experiencia
from {{ ref('stg_customer_service__service_agents') }}
