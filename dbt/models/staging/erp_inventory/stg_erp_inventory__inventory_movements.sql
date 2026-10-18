{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.ERP_INVENTORY.INVENTORY_MOVEMENTS #}

{{ config(materialized='table') }}  {# tabla grande (>= 3000 filas): fisica en vez de vista #}

with source as (
    select * from {{ source('erp_inventory', 'inventory_movements') }}
),

renamed as (
    select
        trim("MOVEMENT_ID")::varchar as movement_id,
        trim("PRODUCT_ID")::varchar as product_id,
        trim("WAREHOUSE_ID")::varchar as warehouse_id,
        "MOVEMENT_DATE"::timestamp_ntz as movement_date,
        trim("MOVEMENT_TYPE")::varchar as movement_type,
        "QUANTITY"::number as quantity,
        "UNIT_COST"::float as unit_cost,
        "TOTAL_COST"::float as total_cost,
        trim("REFERENCE_TYPE")::varchar as reference_type,
        trim("REFERENCE_ID")::varchar as reference_id,
        trim("REASON")::varchar as reason,
        trim("CREATED_BY")::varchar as created_by
    from source
)

select * from renamed
qualify row_number() over (partition by movement_id order by movement_id) = 1
