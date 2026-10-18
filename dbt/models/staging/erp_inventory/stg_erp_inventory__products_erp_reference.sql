{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.ERP_INVENTORY.PRODUCTS_ERP_REFERENCE #}

with source as (
    select * from {{ source('erp_inventory', 'products_erp_reference') }}
),

renamed as (
    select
        trim("PRODUCT_ID")::varchar as product_id,
        trim("PRODUCT_CATEGORY_NAME")::varchar as product_category_name,
        "PRODUCT_WEIGHT_G"::number as product_weight_g,
        "PRODUCT_LENGTH_CM"::number as product_length_cm,
        "PRODUCT_HEIGHT_CM"::number as product_height_cm,
        "PRODUCT_WIDTH_CM"::number as product_width_cm,
        "BASE_UNIT_COST"::float as base_unit_cost,
        trim("SUPPLIER_IDS")::varchar as supplier_ids,
        trim("WAREHOUSE_IDS")::varchar as warehouse_ids
    from source
)

select * from renamed
qualify row_number() over (partition by product_id order by product_id) = 1
