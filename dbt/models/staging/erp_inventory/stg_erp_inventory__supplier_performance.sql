{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.ERP_INVENTORY.SUPPLIER_PERFORMANCE #}

with source as (
    select * from {{ source('erp_inventory', 'supplier_performance') }}
),

renamed as (
    select
        trim("SUPPLIER_ID")::varchar as supplier_id,
        "EVALUATION_DATE"::timestamp_ntz as evaluation_date,
        "DELIVERY_DELAY_DAYS"::float as delivery_delay_days,
        "QUALITY_SCORE"::float as quality_score,
        "FULFILLMENT_RATE"::float as fulfillment_rate,
        "DEFECT_RATE"::float as defect_rate,
        "SERVICE_SCORE"::float as service_score
    from source
)

select * from renamed
