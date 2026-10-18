{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.MARKETING_CAMPAIGNS.CAMPAIGN_AUDIENCE #}

{{ config(materialized='table') }}  {# tabla grande (>= 3000 filas): fisica en vez de vista #}

with source as (
    select * from {{ source('marketing_campaigns', 'campaign_audience') }}
),

renamed as (
    select
        trim("AUDIENCE_ID")::varchar as audience_id,
        trim("CAMPAIGN_ID")::varchar as campaign_id,
        trim("CUSTOMER_SEGMENT")::varchar as customer_segment,
        upper(trim("REGION")) as region,
        trim("CATEGORY")::varchar as category,
        "AUDIENCE_SIZE"::number as audience_size
    from source
)

select * from renamed
qualify row_number() over (partition by audience_id order by audience_id) = 1
