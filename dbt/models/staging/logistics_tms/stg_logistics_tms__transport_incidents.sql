{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.LOGISTICS_TMS.TRANSPORT_INCIDENTS #}

with source as (
    select * from {{ source('logistics_tms', 'transport_incidents') }}
),

renamed as (
    select
        trim("INCIDENT_ID")::varchar as incident_id,
        trim("SHIPMENT_ID")::varchar as shipment_id,
        "INCIDENT_DATE"::timestamp_ntz as incident_date,
        trim("INCIDENT_TYPE")::varchar as incident_type,
        trim("SEVERITY")::varchar as severity,
        trim("DESCRIPTION")::varchar as description,
        trim("RESOLUTION_STATUS")::varchar as resolution_status,
        "RESOLUTION_DATE"::timestamp_ntz as resolution_date
    from source
)

select * from renamed
qualify row_number() over (partition by incident_id order by incident_id) = 1
