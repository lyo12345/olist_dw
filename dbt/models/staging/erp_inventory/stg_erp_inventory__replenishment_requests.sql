{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.ERP_INVENTORY.REPLENISHMENT_REQUESTS #}

with source as (
    select * from {{ source('erp_inventory', 'replenishment_requests') }}
),

renamed as (
    select
        trim("REPLENISHMENT_ID")::varchar as replenishment_id,
        trim("PRODUCT_ID")::varchar as product_id,
        trim("WAREHOUSE_ID")::varchar as warehouse_id,
        "REQUEST_DATE"::timestamp_ntz as request_date,
        "REQUESTED_QUANTITY"::number as requested_quantity,
        "APPROVED_QUANTITY"::float as approved_quantity,
        trim("PRIORITY")::varchar as priority,
        trim("STATUS")::varchar as status,
        "EXPECTED_DELIVERY_DATE"::timestamp_ntz as expected_delivery_date
    from source
)

select * from renamed
qualify row_number() over (partition by replenishment_id order by replenishment_id) = 1
