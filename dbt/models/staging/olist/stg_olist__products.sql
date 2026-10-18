{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.OLIST.PRODUCTS #}

with source as (
    select * from {{ source('olist', 'products') }}
),

renamed as (
    select
        trim("PRODUCT_ID")::varchar as product_id,
        trim("PRODUCT_CATEGORY_NAME")::varchar as product_category_name,
        "PRODUCT_NAME_LENGHT"::number as product_name_lenght,
        "PRODUCT_DESCRIPTION_LENGHT"::number as product_description_lenght,
        "PRODUCT_PHOTOS_QTY"::number as product_photos_qty,
        "PRODUCT_WEIGHT_G"::number as product_weight_g,
        "PRODUCT_LENGTH_CM"::number as product_length_cm,
        "PRODUCT_HEIGHT_CM"::number as product_height_cm,
        "PRODUCT_WIDTH_CM"::number as product_width_cm
    from source
)

select * from renamed
qualify row_number() over (partition by product_id order by product_id) = 1
