{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.MARKETING_FUNNEL.MQL #}

with source as (
    select * from {{ source('marketing_funnel', 'mql') }}
),

renamed as (
    select
        trim("MQL_ID")::varchar as mql_id,
        "FIRST_CONTACT_DATE"::timestamp_ntz as first_contact_date,
        trim("LANDING_PAGE_ID")::varchar as landing_page_id,
        trim("ORIGIN")::varchar as origin
    from source
)

select * from renamed
qualify row_number() over (partition by mql_id order by mql_id) = 1
