{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.CUSTOMER_SERVICE.CUSTOMERS_CRM #}

with source as (
    select * from {{ source('customer_service', 'customers_crm') }}
),

renamed as (
    select
        trim("CRM_CUSTOMER_ID")::varchar as crm_customer_id,
        trim("CUSTOMER_ID")::varchar as customer_id,
        trim("CUSTOMER_UNIQUE_ID")::varchar as customer_unique_id,
        "REGISTRATION_DATE"::timestamp_ntz as registration_date,
        trim("CUSTOMER_SEGMENT")::varchar as customer_segment,
        trim("PREFERRED_CHANNEL")::varchar as preferred_channel,
        trim("LOYALTY_LEVEL")::varchar as loyalty_level,
        trim("STATUS")::varchar as status
    from source
)

select * from renamed
qualify row_number() over (partition by crm_customer_id order by crm_customer_id) = 1
