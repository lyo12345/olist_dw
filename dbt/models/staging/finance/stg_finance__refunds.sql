{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.FINANCE.REFUNDS #}

with source as (
    select * from {{ source('finance', 'refunds') }}
),

renamed as (
    select
        trim("REFUND_ID")::varchar as refund_id,
        trim("ORDER_ID")::varchar as order_id,
        trim("SELLER_ID")::varchar as seller_id,
        "REFUND_DATE"::timestamp_ntz as refund_date,
        trim("REFUND_REASON")::varchar as refund_reason,
        "REFUND_AMOUNT"::float as refund_amount,
        trim("REFUND_STATUS")::varchar as refund_status
    from source
)

select * from renamed
qualify row_number() over (partition by refund_id order by refund_id) = 1
