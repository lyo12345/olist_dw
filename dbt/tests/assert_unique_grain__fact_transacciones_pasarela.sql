-- Grano esperado: fact_transacciones_pasarela -> gateway_transaction_id
select gateway_transaction_id
from {{ ref('fact_transacciones_pasarela') }}
group by gateway_transaction_id
having count(*) > 1
