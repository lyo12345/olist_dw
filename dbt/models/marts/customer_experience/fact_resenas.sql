{{ config(materialized='table') }}
with r as (select * from {{ ref('stg_olist__order_reviews') }}),
o as (select * from {{ ref('stg_olist__orders') }})
select r.review_id, r.order_id, md5(o.customer_id) customer_key,
       to_number(to_char(r.review_creation_date,'YYYYMMDD')) date_key,
       md5(o.order_status) order_status_key,
       r.review_score puntuacion, 1 cantidad_resenas,
       r.review_comment_title titulo, r.review_comment_message comentario,
       r.review_creation_date fecha_resena, r.review_answer_timestamp fecha_respuesta
from r left join o on r.order_id=o.order_id
