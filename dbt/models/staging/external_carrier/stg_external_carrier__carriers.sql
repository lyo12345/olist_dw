{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.EXTERNAL_CARRIER.CARRIERS #}

with source as (
    select * from {{ source('external_carrier', 'carriers') }}
),

renamed as (
    select
        trim("CARRIER_ID")::varchar as carrier_id,
        trim("CARRIER_NAME")::varchar as carrier_name,
        trim("CARRIER_TYPE")::varchar as carrier_type,
        trim("SERVICE_LEVEL")::varchar as service_level,
        upper(trim("REGION")) as region,
        "ACTIVE_FLAG"::number as active_flag
    from source
)

select * from renamed
