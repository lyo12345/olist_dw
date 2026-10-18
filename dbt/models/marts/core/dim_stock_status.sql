{{ config(materialized='table') }}
-- La llave se construye a partir del mismo valor que fact_inventario usa como
-- origen (i.stockout_flag::varchar), en lugar de un texto fijo ('AGOTADO'/'DISPONIBLE')
-- que nunca coincidía con la llave real del hecho (bug detectado en revisión).
select md5(stockout_flag::varchar) stock_status_key,
       stockout_flag,
       iff(stockout_flag=1,'AGOTADO','DISPONIBLE') estado,
       iff(stockout_flag=1,'sin_stock','disponible') descripcion,
       iff(stockout_flag=1,'AGOTADO','DISPONIBLE') clasificacion
from (
 select 0 as stockout_flag
 union all select 1
)
