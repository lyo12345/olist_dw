{{ config(materialized='table') }}
select m.campaign_id, md5(m.campaign_id) campaign_key,
       to_number(to_char(m.metric_date,'YYYYMMDD')) date_key,
       md5(concat_ws('|',coalesce(c.target_segment,''),'','')) segment_key,
       -- channel_key siempre resuelve a UNKNOWN: campaign_daily_metrics no reporta canal por fila.
       -- Ver descripción en _marts__models.yml para el detalle.
       md5('UNKNOWN') channel_key,
       m.impressions impresiones, m.clicks clics, m.leads leads, m.conversions conversiones,
       m.spend gasto, m.revenue ingreso_atribuido,
       iff(m.impressions=0,null,m.clicks/m.impressions) ctr,
       iff(m.leads=0,null,m.conversions/m.leads) cvr,
       iff(m.spend=0,null,m.revenue/m.spend) roi,
       m.metric_date fecha_metrica
from {{ ref('stg_marketing_campaigns__campaign_daily_metrics') }} m
left join {{ ref('stg_marketing_campaigns__campaigns') }} c on m.campaign_id=c.campaign_id
