{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.OLIST.CUSTOMERS #}

{{ config(materialized='table') }}  {# tabla grande (>= 3000 filas): fisica en vez de vista #}

with source as (
    select * from {{ source('olist', 'customers') }}
),

renamed as (
    select
        trim("CUSTOMER_ID")::varchar as customer_id,
        trim("CUSTOMER_UNIQUE_ID")::varchar as customer_unique_id,
        "CUSTOMER_ZIP_CODE_PREFIX"::number as customer_zip_code_prefix,
        initcap(trim("CUSTOMER_CITY")) as customer_city,
        upper(trim("CUSTOMER_STATE")) as customer_state
    from source
)

select * from renamed
qualify row_number() over (partition by customer_id order by customer_id) = 1
