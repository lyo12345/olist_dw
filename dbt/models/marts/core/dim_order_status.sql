{{ config(materialized='table') }}
select md5(order_status) order_status_key, order_status estado, initcap(replace(order_status,'_',' ')) descripcion,
       case when order_status in ('delivered','shipped') then 'cumplido' when order_status in ('canceled','unavailable') then 'no_cumplido' else 'proceso' end categoria
from (select distinct order_status from {{ ref('stg_olist__orders') }})
