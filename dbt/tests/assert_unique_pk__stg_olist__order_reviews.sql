-- Verifica que la PK compuesta (review_id, order_id) de stg_olist__order_reviews sea unica.
-- El test PASA si esta consulta no devuelve filas.
select review_id, order_id, count(*) as n
from {{ ref('stg_olist__order_reviews') }}
group by review_id, order_id
having count(*) > 1
