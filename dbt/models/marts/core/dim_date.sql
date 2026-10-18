{{ config(materialized='table') }}
with bounds as (
    select
      least(to_date('2016-01-01'), min(d)) as min_date,
      greatest(to_date('2027-12-31'), max(d)) as max_date
    from (
      select to_date(order_purchase_timestamp) d from {{ ref('stg_olist__orders') }}
      union all select to_date(snapshot_date) from {{ ref('stg_erp_inventory__inventory') }}
      union all select to_date(metric_date) from {{ ref('stg_marketing_campaigns__campaign_daily_metrics') }}
      union all select to_date(ticket_date) from {{ ref('stg_customer_service__service_tickets') }}
      union all select to_date(transaction_date) from {{ ref('stg_finance__payment_transactions') }}
    )
), spine as (
    select dateadd(day, seq4(), b.min_date) date_day
    from bounds b, table(generator(rowcount => 5000))
    where dateadd(day, seq4(), b.min_date) <= b.max_date
)
select
  to_number(to_char(date_day,'YYYYMMDD')) as date_key,
  date_day as fecha,
  day(date_day) as dia,
  dayname(date_day) as nombre_dia,
  weekofyear(date_day) as semana,
  month(date_day) as mes,
  monthname(date_day) as nombre_mes,
  quarter(date_day) as trimestre,
  iff(month(date_day)<=6,1,2) as semestre,
  year(date_day) as ano,
  iff(dayofweekiso(date_day)>=6,true,false) as indicador_fin_de_semana,
  -- Columnas añadidas para Power BI (nombres en español + columnas de orden)
  dayofweekiso(date_day) as num_dia_semana,   -- 1 = lunes ... 7 = domingo (ordena nombre_dia_es)
  decode(dayofweekiso(date_day), 1,'Lunes', 2,'Martes', 3,'Miércoles', 4,'Jueves',
         5,'Viernes', 6,'Sábado', 7,'Domingo') as nombre_dia_es,
  decode(month(date_day), 1,'Enero', 2,'Febrero', 3,'Marzo', 4,'Abril', 5,'Mayo', 6,'Junio',
         7,'Julio', 8,'Agosto', 9,'Septiembre', 10,'Octubre', 11,'Noviembre', 12,'Diciembre') as nombre_mes_es,
  to_char(date_day,'YYYY-MM') as mes_anio
from spine
