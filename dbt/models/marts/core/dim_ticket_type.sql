{{ config(materialized='table') }}
select distinct
 md5(concat_ws('|',coalesce(issue_category,''),coalesce(issue_subcategory,''),coalesce(priority,''))) ticket_type_key,
 issue_category categoria, issue_subcategory subcategoria, priority prioridad
from {{ ref('stg_customer_service__service_tickets') }}
