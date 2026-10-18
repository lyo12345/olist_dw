"""
olist_cloud_pipeline  ·  Parte en la nube del proyecto Olist (Astronomer + dbt Cloud + Snowflake)

Grafo (19 nodos):

  silver_<fuente> x9 (en paralelo)  ->  gold_dimensiones  ->  gold_<mart> x8 (en paralelo)  ->  dbt_test_final

Todos los nodos usan el MISMO job de dbt Cloud (olist_dbt_build) pero con un comando distinto
(`steps_override`), asi cada capa/fuente/mart se ve, se reintenta y falla por separado en Airflow.

Variables de entorno del Deployment (Astronomer > Environment):
  DBT_CLOUD_JOB_ID                 ID del job de dbt Cloud
  AIRFLOW_CONN_DBT_CLOUD_DEFAULT   dbt-cloud://<ACCOUNT_ID>:<TOKEN_SERVICIO>@<HOST_DE_TU_CUENTA>   (secreta)
"""
from __future__ import annotations

import logging
import os
from datetime import timedelta

import pendulum
from airflow.providers.dbt.cloud.operators.dbt import DbtCloudRunJobOperator
from airflow.sdk import DAG

log = logging.getLogger(__name__)

DBT_CLOUD_CONN_ID = "dbt_cloud_default"
DBT_CLOUD_JOB_ID = int(os.environ.get("DBT_CLOUD_JOB_ID", "0"))

# Carpetas de dbt/models/staging (Silver) = una por fuente
SILVER_SOURCES = [
    "olist",
    "marketing_funnel",
    "erp_inventory",
    "customer_service",
    "marketing_campaigns",
    "logistics_tms",
    "finance",
    "external_carrier",
    "payment_gateway",
]
# Carpetas de dbt/models/marts (Gold) con tablas de hechos
GOLD_MARTS = [
    "commercial",
    "customer_experience",
    "customer_service",
    "financial",
    "inventory",
    "logistics",
    "marketing",
    "payment_gateway",
]


def notify_failure(context) -> None:
    """Punto de extension: aqui se puede enviar un correo o un mensaje a Slack."""
    ti = context["task_instance"]
    log.error("FALLO %s.%s (intento %s)", ti.dag_id, ti.task_id, ti.try_number)


def dbt_step(task_id: str, command: str) -> DbtCloudRunJobOperator:
    """Lanza el job de dbt Cloud sustituyendo sus comandos por `command` y espera el resultado."""
    return DbtCloudRunJobOperator(
        task_id=task_id,
        dbt_cloud_conn_id=DBT_CLOUD_CONN_ID,
        job_id=DBT_CLOUD_JOB_ID,
        check_interval=20,
        timeout=3600,
        wait_for_termination=True,
        additional_run_config={
            "cause": f"Disparado por Airflow ({task_id})",
            "steps_override": [command],
        },
        execution_timeout=timedelta(minutes=70),
    )


with DAG(
    dag_id="olist_cloud_pipeline",
    description="dbt Cloud por capas: Silver (9 fuentes) -> Gold dimensiones -> Gold hechos (8 marts) -> tests",
    start_date=pendulum.datetime(2026, 10, 1, tz="America/La_Paz"),
    schedule="0 6 * * *",
    catchup=False,
    max_active_runs=1,
    default_args={"owner": "olist", "retries": 1, "retry_delay": timedelta(minutes=3),
                  "on_failure_callback": notify_failure},
    tags=["olist", "nube", "dbt-cloud", "snowflake"],
) as dag:

    silver = [dbt_step(f"silver_{s}", f"dbt build --select path:models/staging/{s}") for s in SILVER_SOURCES]

    gold_dims = dbt_step("gold_dimensiones", "dbt build --select path:models/marts/core")

    gold_facts = [dbt_step(f"gold_{m}", f"dbt build --select path:models/marts/{m}") for m in GOLD_MARTS]

    # Pasada final con TODOS los tests (incluye relaciones entre hechos y dimensiones)
    test_final = dbt_step("dbt_test_final", "dbt test")

    silver >> gold_dims >> gold_facts >> test_final
