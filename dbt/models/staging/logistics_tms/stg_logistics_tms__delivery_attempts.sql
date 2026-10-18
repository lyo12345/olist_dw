{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.LOGISTICS_TMS.DELIVERY_ATTEMPTS #}

{{ config(materialized='table') }}  {# tabla grande (>= 3000 filas): fisica en vez de vista #}

with source as (
    select * from {{ source('logistics_tms', 'delivery_attempts') }}
),

renamed as (
    select
        trim("ATTEMPT_ID")::varchar as attempt_id,
        trim("SHIPMENT_ID")::varchar as shipment_id,
        "ATTEMPT_NUMBER"::number as attempt_number,
        "ATTEMPT_DATE"::timestamp_ntz as attempt_date,
        trim("RESULT")::varchar as result,
        trim("REASON")::varchar as reason,
        "DELAY_MINUTES"::float as delay_minutes
    from source
)

select * from renamed
qualify row_number() over (partition by attempt_id order by attempt_id) = 1
