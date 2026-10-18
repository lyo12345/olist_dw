{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.MARKETING_CAMPAIGNS.CAMPAIGN_CHANNELS #}

with source as (
    select * from {{ source('marketing_campaigns', 'campaign_channels') }}
),

renamed as (
    select
        trim("CAMPAIGN_CHANNEL_ID")::varchar as campaign_channel_id,
        trim("CAMPAIGN_ID")::varchar as campaign_id,
        trim("CHANNEL")::varchar as channel,
        "PLANNED_BUDGET"::float as planned_budget,
        "ACTUAL_BUDGET"::float as actual_budget
    from source
)

select * from renamed
qualify row_number() over (partition by campaign_channel_id order by campaign_channel_id) = 1
