{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.LOGISTICS_TMS.CARRIER_PERFORMANCE #}

with source as (
    select * from {{ source('logistics_tms', 'carrier_performance') }}
),

renamed as (
    select
        trim("CARRIER_ID")::varchar as carrier_id,
        "EVALUATION_DATE"::date as evaluation_date,
        "ON_TIME_RATE"::float as on_time_rate,
        "AVERAGE_DELAY_MINUTES"::float as average_delay_minutes,
        "FAILED_DELIVERY_RATE"::float as failed_delivery_rate,
        "DAMAGE_RATE"::float as damage_rate,
        "COST_PER_KM"::float as cost_per_km,
        "SERVICE_SCORE"::float as service_score
    from source
)

select * from renamed
qualify row_number() over (partition by carrier_id, evaluation_date order by carrier_id, evaluation_date) = 1
