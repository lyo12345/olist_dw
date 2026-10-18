{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.ERP_INVENTORY.PRODUCT_COST_HISTORY #}

with source as (
    select * from {{ source('erp_inventory', 'product_cost_history') }}
),

renamed as (
    select
        trim("PRODUCT_ID")::varchar as product_id,
        "EFFECTIVE_DATE"::timestamp_ntz as effective_date,
        "UNIT_COST"::float as unit_cost,
        trim("SUPPLIER_ID")::varchar as supplier_id,
        trim("COST_TYPE")::varchar as cost_type
    from source
)

select * from renamed
