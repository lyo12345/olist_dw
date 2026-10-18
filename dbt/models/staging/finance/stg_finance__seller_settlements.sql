{# Modelo de staging (Silver) generado automaticamente #}
{# Fuente Bronze: OLIST_SYNTHETIC_V2.FINANCE.SELLER_SETTLEMENTS #}

with source as (
    select * from {{ source('finance', 'seller_settlements') }}
),

renamed as (
    select
        trim("SETTLEMENT_ID")::varchar as settlement_id,
        trim("SELLER_ID")::varchar as seller_id,
        "SETTLEMENT_DATE"::timestamp_ntz as settlement_date,
        "GROSS_SALES"::float as gross_sales,
        "COMMISSIONS"::float as commissions,
        "FREIGHT_CHARGES"::float as freight_charges,
        "REFUNDS"::float as refunds,
        "ADJUSTMENTS"::float as adjustments,
        "NET_SETTLEMENT"::float as net_settlement,
        trim("SETTLEMENT_STATUS")::varchar as settlement_status
    from source
)

select * from renamed
qualify row_number() over (partition by settlement_id order by settlement_id) = 1
