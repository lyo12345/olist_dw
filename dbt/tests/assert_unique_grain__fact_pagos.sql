-- Grano esperado: fact_pagos -> order_id, payment_sequential
select order_id, payment_sequential
from {{ ref('fact_pagos') }}
group by order_id, payment_sequential
having count(*) > 1
