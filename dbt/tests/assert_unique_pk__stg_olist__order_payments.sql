-- Verifica que la PK compuesta (order_id, payment_sequential) de stg_olist__order_payments sea unica.
-- El test PASA si esta consulta no devuelve filas.
select order_id, payment_sequential, count(*) as n
from {{ ref('stg_olist__order_payments') }}
group by order_id, payment_sequential
having count(*) > 1
