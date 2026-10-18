{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.PAYMENT_GATEWAY.PAYMENT_GATEWAYS #}

with source as (
    select * from {{ source('payment_gateway', 'payment_gateways') }}
),

renamed as (
    select
        trim("GATEWAY_ID")::varchar as gateway_id,
        trim("GATEWAY_NAME")::varchar as gateway_name,
        trim("GATEWAY_TYPE")::varchar as gateway_type,
        trim("COUNTRY")::varchar as country,
        trim("CURRENCY")::varchar as currency,
        "ACTIVE_FLAG"::boolean as active_flag,
        trim("API_VERSION")::varchar as api_version,
        "SETTLEMENT_CYCLE_DAYS"::number as settlement_cycle_days
    from source
)

select * from renamed
qualify row_number() over (partition by gateway_id order by gateway_id) = 1
