{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.OLIST.GEOLOCATION #}

with source as (
    select * from {{ source('olist', 'geolocation') }}
),

renamed as (
    select
        "GEOLOCATION_ZIP_CODE_PREFIX"::number as geolocation_zip_code_prefix,
        "GEOLOCATION_LAT"::float as geolocation_lat,
        "GEOLOCATION_LNG"::float as geolocation_lng,
        initcap(trim("GEOLOCATION_CITY")) as geolocation_city,
        upper(trim("GEOLOCATION_STATE")) as geolocation_state
    from source
)

select * from renamed
