{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.OLIST.ORDERS #}

{{ config(materialized='table') }}  {# tabla grande (>= 3000 filas): fisica en vez de vista #}

with source as (
    select * from {{ source('olist', 'orders') }}
),

renamed as (
    select
        trim("ORDER_ID")::varchar as order_id,
        trim("CUSTOMER_ID")::varchar as customer_id,
        trim("ORDER_STATUS")::varchar as order_status,
        "ORDER_PURCHASE_TIMESTAMP"::timestamp_ntz as order_purchase_timestamp,
        "ORDER_APPROVED_AT"::timestamp_ntz as order_approved_at,
        "ORDER_DELIVERED_CARRIER_DATE"::timestamp_ntz as order_delivered_carrier_date,
        "ORDER_DELIVERED_CUSTOMER_DATE"::timestamp_ntz as order_delivered_customer_date,
        "ORDER_ESTIMATED_DELIVERY_DATE"::timestamp_ntz as order_estimated_delivery_date
    from source
)

select * from renamed
qualify row_number() over (partition by order_id order by order_id) = 1
