{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.EXTERNAL_CARRIER.CARRIER_SHIPMENTS #}

with source as (
    select * from {{ source('external_carrier', 'carrier_shipments') }}
),

renamed as (
    select
        trim("SHIPMENT_ID")::varchar as shipment_id,
        trim("ORDER_ID")::varchar as order_id,
        trim("CARRIER_ID")::varchar as carrier_id,
        upper(trim("ORIGIN_REGION")) as origin_region,
        upper(trim("DESTINATION_REGION")) as destination_region,
        "SHIPMENT_CREATED_AT"::timestamp_ntz as shipment_created_at,
        "PROMISED_DELIVERY_DATE"::timestamp_ntz as promised_delivery_date,
        "ACTUAL_DELIVERY_DATE"::timestamp_ntz as actual_delivery_date,
        trim("SHIPMENT_STATUS")::varchar as shipment_status,
        trim("SELLER_ID")::varchar as seller_id,
        trim("CUSTOMER_ID")::varchar as customer_id
    from source
)

select * from renamed
qualify row_number() over (partition by shipment_id order by shipment_id) = 1
