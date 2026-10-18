# dbt — Olist Silver / Gold

Proyecto dbt para implementar la capa **Silver** y la capa **Gold** del Data Warehouse definido en el caso de estudio Olist.

## Capas

- `staging/`: Silver. Normalización de nombres y tipos, limpieza, deduplicación y estandarización.
- `marts/core/`: dimensiones conformadas y catálogos controlados.
- `marts/<dominio>/`: 18 hechos Gold organizados por Data Mart lógico.

## Gold

La capa Gold implementa exactamente los 18 hechos lógicos definidos en el caso:

`fact_ventas`, `fact_pagos`, `fact_logistica`, `fact_resenas`, `fact_leads`, `fact_inventario`, `fact_movimientos_inventario`, `fact_compras`, `fact_campanas`, `fact_eventos_marketing`, `fact_atencion`, `fact_interacciones_atencion`, `fact_liquidaciones`, `fact_conciliaciones`, `fact_transacciones_pasarela`, `fact_eventos_pasarela`, `fact_eventos_transportista`, `fact_incidencias_transportista`.

Las dimensiones conformadas principales son:

`dim_date`, `dim_customer`, `dim_product`, `dim_seller`, `dim_geography`, `dim_payment`, `dim_channel`, `dim_warehouse`, `dim_supplier`, `dim_carrier`, `dim_route`, `dim_campaign`, `dim_segment`, `dim_agent`, `dim_ticket_type`, `dim_gateway`.

Se incluyen además dimensiones controladas para estados y tipos de eventos.

## Convenciones

- Las claves de dimensión usan claves técnicas reproducibles mediante `MD5` del identificador natural.
- `date_key` usa formato `YYYYMMDD`.
- Los hechos mantienen las claves de dimensiones necesarias para análisis dimensional.
- No existe SCD2 en esta versión.
- Las medidas no aditivas o semi-aditivas conservan su naturaleza documentada.

## Validación

```bash
dbt debug
dbt build
```

Si una fuente requiere refresco:

```bash
dbt source freshness
```

## Importante

Los sistemas sintéticos (`ERP`, `CRM`, `Marketing Campaigns`, `TMS`, `Finance`, `Payment Gateway` y `External Carrier`) son extensiones académicas. Sus métricas no deben interpretarse como datos históricos reales de Olist.
