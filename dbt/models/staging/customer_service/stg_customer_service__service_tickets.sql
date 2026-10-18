{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.CUSTOMER_SERVICE.SERVICE_TICKETS #}

{{ config(materialized='table') }}  {# tabla grande (>= 3000 filas): fisica en vez de vista #}

with source as (
    select * from {{ source('customer_service', 'service_tickets') }}
),

renamed as (
    select
        trim("TICKET_ID")::varchar as ticket_id,
        trim("CUSTOMER_ID")::varchar as customer_id,
        trim("ORDER_ID")::varchar as order_id,
        trim("ASSIGNED_AGENT_ID")::varchar as assigned_agent_id,
        "TICKET_DATE"::timestamp_ntz as ticket_date,
        trim("TICKET_CHANNEL")::varchar as ticket_channel,
        trim("ISSUE_CATEGORY")::varchar as issue_category,
        trim("ISSUE_SUBCATEGORY")::varchar as issue_subcategory,
        trim("PRIORITY")::varchar as priority,
        trim("STATUS")::varchar as status,
        "FIRST_RESPONSE_TIMESTAMP"::timestamp_ntz as first_response_timestamp,
        "RESOLUTION_TIMESTAMP"::timestamp_ntz as resolution_timestamp,
        "SATISFACTION_SCORE"::float as satisfaction_score,
        "ESCALATION_FLAG"::boolean as escalation_flag
    from source
)

select * from renamed
qualify row_number() over (partition by ticket_id order by ticket_id) = 1
