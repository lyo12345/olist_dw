{{ config(materialized='table') }}

with combos as (
    select distinct customer_segment segmento_cliente, region, category categoria_objetivo
    from {{ ref('stg_marketing_campaigns__campaign_audience') }}
    union
    select distinct target_segment, null, null
    from {{ ref('stg_marketing_campaigns__campaigns') }}
),

audience_agg as (
    select
        customer_segment segmento_cliente,
        region,
        category categoria_objetivo,
        sum(audience_size) as tamano_audiencia
    from {{ ref('stg_marketing_campaigns__campaign_audience') }}
    group by 1, 2, 3
)

select
    md5(concat_ws('|',
        coalesce(c.segmento_cliente, ''),
        coalesce(c.region, ''),
        coalesce(c.categoria_objetivo, '')
    )) as segment_key,
    c.segmento_cliente,
    c.region,
    c.categoria_objetivo,
    a.tamano_audiencia
from combos c
left join audience_agg a
    on c.segmento_cliente = a.segmento_cliente
    and coalesce(c.region, '') = coalesce(a.region, '')
    and coalesce(c.categoria_objetivo, '') = coalesce(a.categoria_objetivo, '')
