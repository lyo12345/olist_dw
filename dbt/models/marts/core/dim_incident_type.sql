{{ config(materialized='table') }}
select md5(concat_ws('|',incident_type,severity)) incident_type_key, incident_type tipo,
       severity severidad, case when upper(severity) in ('HIGH','CRITICAL','SEVERE') then 'grave' else 'normal' end categoria
from (select distinct incident_type, severity from {{ ref('stg_external_carrier__carrier_incidents') }})
