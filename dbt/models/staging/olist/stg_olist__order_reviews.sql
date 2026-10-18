{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.OLIST.ORDER_REVIEWS #}

{{ config(materialized='table') }}  {# tabla grande (>= 3000 filas): fisica en vez de vista #}

with source as (
    select * from {{ source('olist', 'order_reviews') }}
),

renamed as (
    select
        trim("REVIEW_ID")::varchar as review_id,
        trim("ORDER_ID")::varchar as order_id,
        "REVIEW_SCORE"::number as review_score,
        trim("REVIEW_COMMENT_TITLE")::varchar as review_comment_title,
        trim("REVIEW_COMMENT_MESSAGE")::varchar as review_comment_message,
        "REVIEW_CREATION_DATE"::timestamp_ntz as review_creation_date,
        "REVIEW_ANSWER_TIMESTAMP"::timestamp_ntz as review_answer_timestamp
    from source
)

select * from renamed
qualify row_number() over (partition by review_id, order_id order by review_id, order_id) = 1
