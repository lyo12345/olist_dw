{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.MARKETING_FUNNEL.CLOSED_DEALS #}

with source as (
    select * from {{ source('marketing_funnel', 'closed_deals') }}
),

renamed as (
    select
        trim("MQL_ID")::varchar as mql_id,
        trim("SELLER_ID")::varchar as seller_id,
        trim("SDR_ID")::varchar as sdr_id,
        trim("SR_ID")::varchar as sr_id,
        "WON_DATE"::timestamp_ntz as won_date,
        trim("BUSINESS_SEGMENT")::varchar as business_segment,
        trim("LEAD_TYPE")::varchar as lead_type,
        trim("LEAD_BEHAVIOUR_PROFILE")::varchar as lead_behaviour_profile,
        "HAS_COMPANY"::float as has_company,
        "HAS_GTIN"::float as has_gtin,
        trim("AVERAGE_STOCK")::varchar as average_stock,
        trim("BUSINESS_TYPE")::varchar as business_type,
        "DECLARED_PRODUCT_CATALOG_SIZE"::float as declared_product_catalog_size,
        "DECLARED_MONTHLY_REVENUE"::float as declared_monthly_revenue
    from source
)

select * from renamed
qualify row_number() over (partition by mql_id order by mql_id) = 1
