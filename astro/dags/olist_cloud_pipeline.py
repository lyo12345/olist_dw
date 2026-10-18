"""
olist_cloud_pipeline  ·  Parte en la nube del proyecto Olist (Astronomer + dbt Cloud + Snowflake)

Dispara el job `olist_dbt_build` de dbt Cloud (dbt build = Silver + Gold + tests) y espera el
resultado: si un modelo o un test falla, la tarea queda en rojo.

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


def notify_failure(context) -> None:
    """Punto de extension: aqui se puede enviar un correo o un mensaje a Slack."""
    ti = context["task_instance"]
    log.error("FALLO %s.%s (intento %s)", ti.dag_id, ti.task_id, ti.try_number)


with DAG(
    dag_id="olist_cloud_pipeline",
    description="dbt Cloud: Silver + Gold + tests sobre Snowflake",
    start_date=pendulum.datetime(2026, 10, 1, tz="America/La_Paz"),
    schedule="0 6 * * *",
    catchup=False,
    max_active_runs=1,
    default_args={"owner": "olist", "retries": 1, "retry_delay": timedelta(minutes=5),
                  "on_failure_callback": notify_failure},
    tags=["olist", "nube", "dbt-cloud", "snowflake"],
) as dag:

    DbtCloudRunJobOperator(
        task_id="dbt_cloud_build",
        dbt_cloud_conn_id=DBT_CLOUD_CONN_ID,
        job_id=DBT_CLOUD_JOB_ID,
        check_interval=30,
        timeout=3600,
        wait_for_termination=True,
        additional_run_config={"cause": "Disparado por Airflow (olist_cloud_pipeline)"},
        execution_timeout=timedelta(minutes=70),
    )
