{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.CUSTOMER_SERVICE.TICKET_INTERACTIONS #}

{{ config(materialized='table') }}  {# tabla grande (>= 3000 filas): fisica en vez de vista #}

with source as (
    select * from {{ source('customer_service', 'ticket_interactions') }}
),

renamed as (
    select
        trim("INTERACTION_ID")::varchar as interaction_id,
        trim("TICKET_ID")::varchar as ticket_id,
        "INTERACTION_TIMESTAMP"::timestamp_ntz as interaction_timestamp,
        trim("AGENT_ID")::varchar as agent_id,
        trim("CHANNEL")::varchar as channel,
        trim("INTERACTION_TYPE")::varchar as interaction_type,
        "RESPONSE_TIME_MINUTES"::float as response_time_minutes,
        trim("INTERACTION_TEXT")::varchar as interaction_text,
        trim("SENTIMENT_LABEL")::varchar as sentiment_label
    from source
)

select * from renamed
qualify row_number() over (partition by interaction_id order by interaction_id) = 1
