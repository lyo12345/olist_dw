{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.LOGISTICS_TMS.CARRIERS #}

with source as (
    select * from {{ source('logistics_tms', 'carriers') }}
),

renamed as (
    select
        trim("CARRIER_ID")::varchar as carrier_id,
        trim("CARRIER_NAME")::varchar as carrier_name,
        trim("CARRIER_TYPE")::varchar as carrier_type,
        upper(trim("REGION")) as region,
        trim("SERVICE_LEVEL")::varchar as service_level,
        trim("STATUS")::varchar as status
    from source
)

select * from renamed
