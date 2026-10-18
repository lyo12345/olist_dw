{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.PAYMENT_GATEWAY.GATEWAY_TRANSACTIONS #}

{{ config(materialized='table') }}  {# tabla grande (>= 3000 filas): fisica en vez de vista #}

with source as (
    select * from {{ source('payment_gateway', 'gateway_transactions') }}
),

renamed as (
    select
        trim("GATEWAY_TRANSACTION_ID")::varchar as gateway_transaction_id,
        trim("ORDER_ID")::varchar as order_id,
        trim("PAYMENT_ID")::varchar as payment_id,
        trim("GATEWAY_ID")::varchar as gateway_id,
        "TRANSACTION_TIMESTAMP"::timestamp_ntz as transaction_timestamp,
        trim("TRANSACTION_TYPE")::varchar as transaction_type,
        "AMOUNT"::float as amount,
        trim("CURRENCY")::varchar as currency,
        trim("AUTHORIZATION_STATUS")::varchar as authorization_status,
        trim("CAPTURE_STATUS")::varchar as capture_status,
        "RESPONSE_CODE"::number as response_code,
        "PROCESSING_TIME_MS"::float as processing_time_ms,
        "GATEWAY_FEE"::float as gateway_fee,
        "MERCHANT_AMOUNT"::float as merchant_amount,
        trim("PAYMENT_TYPE_SOURCE")::varchar as payment_type_source,
        "INSTALLMENTS"::number as installments
    from source
)

select * from renamed
qualify row_number() over (partition by gateway_transaction_id order by gateway_transaction_id) = 1
