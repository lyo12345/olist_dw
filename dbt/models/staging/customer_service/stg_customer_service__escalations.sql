{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.CUSTOMER_SERVICE.ESCALATIONS #}

with source as (
    select * from {{ source('customer_service', 'escalations') }}
),

renamed as (
    select
        trim("ESCALATION_ID")::varchar as escalation_id,
        trim("TICKET_ID")::varchar as ticket_id,
        "ESCALATION_DATE"::timestamp_ntz as escalation_date,
        trim("ESCALATION_REASON")::varchar as escalation_reason,
        trim("ESCALATION_LEVEL")::varchar as escalation_level,
        "RESOLVED_DATE"::timestamp_ntz as resolved_date,
        trim("FINAL_STATUS")::varchar as final_status
    from source
)

select * from renamed
qualify row_number() over (partition by escalation_id order by escalation_id) = 1
