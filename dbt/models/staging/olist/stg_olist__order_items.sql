{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.OLIST.ORDER_ITEMS #}

{{ config(materialized='table') }}  {# tabla grande (>= 3000 filas): fisica en vez de vista #}

with source as (
    select * from {{ source('olist', 'order_items') }}
),

renamed as (
    select
        trim("ORDER_ID")::varchar as order_id,
        "ORDER_ITEM_ID"::number as order_item_id,
        trim("PRODUCT_ID")::varchar as product_id,
        trim("SELLER_ID")::varchar as seller_id,
        "SHIPPING_LIMIT_DATE"::timestamp_ntz as shipping_limit_date,
        "PRICE"::float as price,
        "FREIGHT_VALUE"::float as freight_value
    from source
)

select * from renamed
qualify row_number() over (partition by order_id, order_item_id order by order_id, order_item_id) = 1
