{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.LOGISTICS_TMS.SHIPMENTS #}

{{ config(materialized='table') }}  {# tabla grande (>= 3000 filas): fisica en vez de vista #}

with source as (
    select * from {{ source('logistics_tms', 'shipments') }}
),

renamed as (
    select
        trim("SHIPMENT_ID")::varchar as shipment_id,
        trim("ORDER_ID")::varchar as order_id,
        trim("SELLER_ID")::varchar as seller_id,
        trim("CUSTOMER_ID")::varchar as customer_id,
        trim("CARRIER_ID")::varchar as carrier_id,
        trim("ROUTE_ID")::varchar as route_id,
        "SHIPMENT_DATE"::timestamp_ntz as shipment_date,
        "ESTIMATED_DELIVERY_DATE"::timestamp_ntz as estimated_delivery_date,
        "ACTUAL_DELIVERY_DATE"::timestamp_ntz as actual_delivery_date,
        "SHIPPING_COST"::float as shipping_cost,
        "PACKAGE_WEIGHT"::float as package_weight,
        "PACKAGE_VOLUME"::float as package_volume,
        trim("STATUS")::varchar as status
    from source
)

select * from renamed
qualify row_number() over (partition by shipment_id order by shipment_id) = 1
