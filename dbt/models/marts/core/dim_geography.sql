{{ config(materialized='table') }}
with g as (
 select distinct geolocation_zip_code_prefix as codigo_postal, geolocation_city as ciudad,
        geolocation_state as estado, geolocation_lat as latitud, geolocation_lng as longitud
 from {{ ref('stg_olist__geolocation') }}
),
base as (
 select codigo_postal, ciudad, estado, latitud, longitud from g
 union
 select customer_zip_code_prefix, customer_city, customer_state, null, null
 from {{ ref('stg_olist__customers') }}
 union
 select seller_zip_code_prefix, seller_city, seller_state, null, null
 from {{ ref('stg_olist__sellers') }}
)
select md5(concat_ws('|',coalesce(codigo_postal::varchar,''),coalesce(ciudad,''),coalesce(estado,''))) geography_key,
       codigo_postal, ciudad, estado, 'Brasil' as pais,
       case when estado in ('SP','RJ','MG','ES') then 'Sudeste'
            when estado in ('PR','SC','RS') then 'Sul'
            when estado in ('BA','PE','CE','MA','PB','RN','AL','SE','PI') then 'Nordeste'
            when estado in ('GO','MT','MS','DF') then 'Centro-Oeste'
            when estado in ('AM','PA','AC','RO','RR','AP','TO') then 'Norte'
            else 'Sin clasificar' end as region,
       latitud, longitud
from base
qualify row_number() over (
  partition by codigo_postal
  order by case when latitud is not null then 0 else 1 end, ciudad
)=1
