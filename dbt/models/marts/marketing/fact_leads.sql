{{ config(materialized='table') }}
with m as (select * from {{ ref('stg_marketing_funnel__mql') }}),
d as (select * from {{ ref('stg_marketing_funnel__closed_deals') }})
select
 m.mql_id, md5(d.seller_id) seller_key,
 to_number(to_char(m.first_contact_date,'YYYYMMDD')) date_key,
 md5(upper(trim(coalesce(m.origin,'UNKNOWN')))) channel_key,
 1 cantidad_leads, iff(d.mql_id is not null,1,0) indicador_conversion,
 datediff(day,m.first_contact_date,d.won_date) dias_hasta_conversion,
 m.first_contact_date fecha_primer_contacto, d.won_date fecha_conversion,
 m.landing_page_id origen_landing_page, m.origin origen,
 d.sdr_id, d.sr_id, d.business_segment, d.lead_type, d.lead_behaviour_profile,
 d.has_company, d.has_gtin, d.average_stock, d.business_type,
 d.declared_product_catalog_size, d.declared_monthly_revenue
from m left join d on m.mql_id=d.mql_id
