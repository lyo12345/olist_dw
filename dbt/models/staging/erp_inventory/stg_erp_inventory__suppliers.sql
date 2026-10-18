{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.ERP_INVENTORY.SUPPLIERS #}

with source as (
    select * from {{ source('erp_inventory', 'suppliers') }}
),

renamed as (
    select
        trim("SUPPLIER_ID")::varchar as supplier_id,
        trim("SUPPLIER_NAME")::varchar as supplier_name,
        trim("SUPPLIER_TYPE")::varchar as supplier_type,
        initcap(trim("CITY")) as city,
        upper(trim("STATE")) as state,
        trim("COUNTRY")::varchar as country,
        "REGISTRATION_DATE"::timestamp_ntz as registration_date,
        trim("STATUS")::varchar as status,
        "LEAD_TIME_DAYS"::float as lead_time_days,
        trim("PAYMENT_TERMS")::varchar as payment_terms,
        "SUPPLIER_RATING"::float as supplier_rating
    from source
)

select * from renamed
qualify row_number() over (partition by supplier_id order by supplier_id) = 1
