{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.LOGISTICS_TMS.VEHICLES #}

with source as (
    select * from {{ source('logistics_tms', 'vehicles') }}
),

renamed as (
    select
        trim("VEHICLE_ID")::varchar as vehicle_id,
        trim("CARRIER_ID")::varchar as carrier_id,
        trim("VEHICLE_TYPE")::varchar as vehicle_type,
        "CAPACITY_KG"::float as capacity_kg,
        "CAPACITY_VOLUME"::float as capacity_volume,
        "REGISTRATION_YEAR"::float as registration_year,
        trim("STATUS")::varchar as status
    from source
)

select * from renamed
qualify row_number() over (partition by vehicle_id order by vehicle_id) = 1
