{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.EXTERNAL_CARRIER.CARRIER_EVENTS #}

{{ config(materialized='table') }}  {# tabla grande (>= 3000 filas): fisica en vez de vista #}

with source as (
    select * from {{ source('external_carrier', 'carrier_events') }}
),

renamed as (
    select
        trim("CARRIER_EVENT_ID")::varchar as carrier_event_id,
        trim("SHIPMENT_ID")::varchar as shipment_id,
        trim("CARRIER_ID")::varchar as carrier_id,
        "EVENT_TIMESTAMP"::timestamp_ntz as event_timestamp,
        "EVENT_TIMESTAMP_RAW"::timestamp_ntz as event_timestamp_raw,
        trim("EVENT_TYPE")::varchar as event_type,
        trim("EVENT_STATUS")::varchar as event_status,
        trim("LOCATION")::varchar as location,
        trim("HUB_ID")::varchar as hub_id,
        trim("EXCEPTION_CODE")::varchar as exception_code,
        trim("DESCRIPTION")::varchar as description
    from source
)

select * from renamed
qualify row_number() over (partition by carrier_event_id order by carrier_event_id) = 1
