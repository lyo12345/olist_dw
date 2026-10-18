{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.MARKETING_CAMPAIGNS.PROMOTIONS #}

with source as (
    select * from {{ source('marketing_campaigns', 'promotions') }}
),

renamed as (
    select
        trim("PROMOTION_ID")::varchar as promotion_id,
        trim("CAMPAIGN_ID")::varchar as campaign_id,
        trim("PRODUCT_ID")::varchar as product_id,
        trim("SELLER_ID")::varchar as seller_id,
        trim("PROMOTION_TYPE")::varchar as promotion_type,
        "DISCOUNT_PERCENTAGE"::float as discount_percentage,
        "START_DATE"::timestamp_ntz as start_date,
        "END_DATE"::timestamp_ntz as end_date,
        "MAXIMUM_REDEMPTIONS"::float as maximum_redemptions
    from source
)

select * from renamed
qualify row_number() over (partition by promotion_id order by promotion_id) = 1
