{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.ERP_INVENTORY.PURCHASE_ORDER_ITEMS #}

{{ config(materialized='table') }}  {# tabla grande (>= 3000 filas): fisica en vez de vista #}

with source as (
    select * from {{ source('erp_inventory', 'purchase_order_items') }}
),

renamed as (
    select
        trim("PURCHASE_ORDER_ID")::varchar as purchase_order_id,
        trim("PURCHASE_ORDER_ITEM_ID")::varchar as purchase_order_item_id,
        trim("PRODUCT_ID")::varchar as product_id,
        "QUANTITY_ORDERED"::number as quantity_ordered,
        "QUANTITY_RECEIVED"::float as quantity_received,
        "UNIT_COST"::float as unit_cost,
        "DISCOUNT"::float as discount,
        "TAX"::float as tax,
        "LINE_TOTAL"::float as line_total
    from source
)

select * from renamed
qualify row_number() over (partition by purchase_order_item_id order by purchase_order_item_id) = 1
