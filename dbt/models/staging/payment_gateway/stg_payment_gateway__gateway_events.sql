{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.PAYMENT_GATEWAY.GATEWAY_EVENTS #}

{{ config(materialized='table') }}  {# tabla grande (>= 3000 filas): fisica en vez de vista #}

with source as (
    select * from {{ source('payment_gateway', 'gateway_events') }}
),

renamed as (
    select
        trim("GATEWAY_EVENT_ID")::varchar as gateway_event_id,
        trim("GATEWAY_TRANSACTION_ID")::varchar as gateway_transaction_id,
        "EVENT_TIMESTAMP"::timestamp_ntz as event_timestamp,
        trim("EVENT_TYPE")::varchar as event_type,
        trim("EVENT_STATUS")::varchar as event_status,
        "RESPONSE_CODE"::number as response_code,
        "PROCESSING_TIME_MS"::number as processing_time_ms
    from source
)

select * from renamed
qualify row_number() over (partition by gateway_event_id order by gateway_event_id) = 1
