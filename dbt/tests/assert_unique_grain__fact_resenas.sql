-- Grano esperado: fact_resenas -> review_id
select review_id
from {{ ref('fact_resenas') }}
group by review_id
having count(*) > 1
