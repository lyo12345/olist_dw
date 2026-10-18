{{ config(materialized='table') }}
with p as (select * from {{ ref('stg_olist__products') }}),
tr as (select * from {{ ref('stg_olist__product_category_name_translation') }}),
erp as (select * from {{ ref('stg_erp_inventory__products_erp_reference') }})
select
  md5(p.product_id) as product_key, p.product_id,
  p.product_category_name as categoria_original,
  coalesce(tr.product_category_name_english,p.product_category_name) as categoria_traducida,
  p.product_name_lenght as longitud_nombre,
  p.product_description_lenght as longitud_descripcion,
  p.product_photos_qty as cantidad_fotografias,
  p.product_weight_g as peso_g,
  p.product_length_cm as longitud_cm, p.product_height_cm as altura_cm, p.product_width_cm as ancho_cm,
  erp.base_unit_cost as costo_base
from p
left join tr on p.product_category_name=tr.product_category_name
left join erp on p.product_id=erp.product_id
