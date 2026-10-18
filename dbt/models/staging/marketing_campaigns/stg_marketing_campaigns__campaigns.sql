{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.MARKETING_CAMPAIGNS.CAMPAIGNS #}

with source as (
    select * from {{ source('marketing_campaigns', 'campaigns') }}
),

renamed as (
    select
        trim("CAMPAIGN_ID")::varchar as campaign_id,
        trim("CAMPAIGN_NAME")::varchar as campaign_name,
        trim("CAMPAIGN_TYPE")::varchar as campaign_type,
        "START_DATE"::timestamp_ntz as start_date,
        "END_DATE"::timestamp_ntz as end_date,
        trim("OBJECTIVE")::varchar as objective,
        "BUDGET"::float as budget,
        trim("TARGET_SEGMENT")::varchar as target_segment,
        trim("STATUS")::varchar as status
    from source
)

select * from renamed
qualify row_number() over (partition by campaign_id order by campaign_id) = 1
