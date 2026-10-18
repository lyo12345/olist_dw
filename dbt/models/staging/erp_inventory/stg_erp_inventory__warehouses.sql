{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.ERP_INVENTORY.WAREHOUSES #}

with source as (
    select * from {{ source('erp_inventory', 'warehouses') }}
),

renamed as (
    select
        trim("WAREHOUSE_ID")::varchar as warehouse_id,
        trim("WAREHOUSE_NAME")::varchar as warehouse_name,
        initcap(trim("CITY")) as city,
        upper(trim("STATE")) as state,
        "CAPACITY_UNITS"::number as capacity_units,
        trim("WAREHOUSE_TYPE")::varchar as warehouse_type,
        trim("STATUS")::varchar as status
    from source
)

select * from renamed
qualify row_number() over (partition by warehouse_id order by warehouse_id) = 1
