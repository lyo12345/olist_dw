-- Verifica que la PK compuesta (carrier_id, evaluation_date) de stg_logistics_tms__carrier_performance sea unica.
-- El test PASA si esta consulta no devuelve filas.
select carrier_id, evaluation_date, count(*) as n
from {{ ref('stg_logistics_tms__carrier_performance') }}
group by carrier_id, evaluation_date
having count(*) > 1
