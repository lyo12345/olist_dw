{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.OLIST.ORDER_PAYMENTS #}

{{ config(materialized='table') }}  {# tabla grande (>= 3000 filas): fisica en vez de vista #}

with source as (
    select * from {{ source('olist', 'order_payments') }}
),

renamed as (
    select
        trim("ORDER_ID")::varchar as order_id,
        "PAYMENT_SEQUENTIAL"::number as payment_sequential,
        trim("PAYMENT_TYPE")::varchar as payment_type,
        "PAYMENT_INSTALLMENTS"::number as payment_installments,
        "PAYMENT_VALUE"::float as payment_value
    from source
)

select * from renamed
qualify row_number() over (partition by order_id, payment_sequential order by order_id, payment_sequential) = 1
