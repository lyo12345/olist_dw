{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.CUSTOMER_SERVICE.SERVICE_AGENTS #}

with source as (
    select * from {{ source('customer_service', 'service_agents') }}
),

renamed as (
    select
        trim("AGENT_ID")::varchar as agent_id,
        trim("AGENT_NAME")::varchar as agent_name,
        trim("TEAM")::varchar as team,
        upper(trim("REGION")) as region,
        "HIRING_DATE"::timestamp_ntz as hiring_date,
        trim("STATUS")::varchar as status,
        trim("EXPERIENCE_LEVEL")::varchar as experience_level
    from source
)

select * from renamed
qualify row_number() over (partition by agent_id order by agent_id) = 1
