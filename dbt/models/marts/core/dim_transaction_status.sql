{{ config(materialized='table') }}
select md5(concat_ws('|',autorizacion,captura)) transaction_status_key,
       autorizacion, captura,
       autorizacion || ' / ' || captura estado
from (
  select distinct authorization_status autorizacion, capture_status captura
  from {{ ref('stg_payment_gateway__gateway_transactions') }}
)
