{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.PAYMENT_GATEWAY.CHARGEBACKS #}

with source as (
    select * from {{ source('payment_gateway', 'chargebacks') }}
),

renamed as (
    select
        trim("CHARGEBACK_ID")::varchar as chargeback_id,
        trim("GATEWAY_TRANSACTION_ID")::varchar as gateway_transaction_id,
        trim("ORDER_ID")::varchar as order_id,
        "CHARGEBACK_DATE"::timestamp_ntz as chargeback_date,
        "CHARGEBACK_AMOUNT"::float as chargeback_amount,
        trim("REASON_CATEGORY")::varchar as reason_category,
        trim("STATUS")::varchar as status,
        "RESOLUTION_DATE"::timestamp_ntz as resolution_date
    from source
)

select * from renamed
qualify row_number() over (partition by chargeback_id order by chargeback_id) = 1
