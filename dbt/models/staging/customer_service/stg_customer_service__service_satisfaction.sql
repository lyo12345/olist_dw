{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.CUSTOMER_SERVICE.SERVICE_SATISFACTION #}

with source as (
    select * from {{ source('customer_service', 'service_satisfaction') }}
),

renamed as (
    select
        trim("SURVEY_ID")::varchar as survey_id,
        trim("TICKET_ID")::varchar as ticket_id,
        "SURVEY_DATE"::timestamp_ntz as survey_date,
        "SATISFACTION_SCORE"::float as satisfaction_score,
        "RECOMMENDATION_SCORE"::float as recommendation_score,
        trim("COMMENT_TEXT")::varchar as comment_text
    from source
)

select * from renamed
qualify row_number() over (partition by survey_id order by survey_id) = 1
