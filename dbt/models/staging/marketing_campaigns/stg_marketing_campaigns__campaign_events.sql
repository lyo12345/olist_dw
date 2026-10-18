{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.MARKETING_CAMPAIGNS.CAMPAIGN_EVENTS #}

{{ config(materialized='table') }}  {# tabla grande (>= 3000 filas): fisica en vez de vista #}

with source as (
    select * from {{ source('marketing_campaigns', 'campaign_events') }}
),

renamed as (
    select
        trim("EVENT_ID")::varchar as event_id,
        trim("CAMPAIGN_ID")::varchar as campaign_id,
        trim("CUSTOMER_ID")::varchar as customer_id,
        "EVENT_TIMESTAMP"::timestamp_ntz as event_timestamp,
        trim("EVENT_TYPE")::varchar as event_type,
        trim("CHANNEL")::varchar as channel,
        trim("DEVICE_TYPE")::varchar as device_type,
        upper(trim("REGION")) as region,
        "CONVERSION_FLAG"::boolean as conversion_flag
    from source
)

select * from renamed
qualify row_number() over (partition by event_id order by event_id) = 1
