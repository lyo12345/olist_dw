{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.OLIST.PRODUCT_CATEGORY_NAME_TRANSLATION #}

with source as (
    select * from {{ source('olist', 'product_category_name_translation') }}
),

renamed as (
    select
        trim("PRODUCT_CATEGORY_NAME")::varchar as product_category_name,
        trim("PRODUCT_CATEGORY_NAME_ENGLISH")::varchar as product_category_name_english
    from source
)

select * from renamed
qualify row_number() over (partition by product_category_name order by product_category_name) = 1
