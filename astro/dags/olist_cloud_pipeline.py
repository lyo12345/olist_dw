"""
olist_cloud_pipeline  ·  Parte en la nube del proyecto Olist (Astronomer + Snowflake + dbt Cloud)

  verificar_bronze  ->  dbt_cloud_build  ->  verificar_gold

* Bronze se carga desde PostgreSQL/MySQL (local, ver olist_elt_pipeline en tu PC).
* Este DAG corre en Astronomer: comprueba que Bronze tenga datos, dispara el job de dbt Cloud
  (Silver + Gold + tests) y comprueba que Gold quedo poblada.

Variables de entorno del Deployment (Astronomer > Environment):
  DBT_CLOUD_JOB_ID                 ID del job de dbt Cloud
  AIRFLOW_CONN_DBT_CLOUD_DEFAULT   dbt-cloud://<ACCOUNT_ID>:<TOKEN_SERVICIO>@        (secreta)
  SNOWFLAKE_ACCOUNT / SNOWFLAKE_USER / SNOWFLAKE_PASSWORD (secreta) / SNOWFLAKE_ROLE / SNOWFLAKE_WAREHOUSE
"""
from __future__ import annotations

import logging
import os
from datetime import timedelta

import pendulum
from airflow.providers.dbt.cloud.operators.dbt import DbtCloudRunJobOperator
from airflow.sdk import DAG, task

log = logging.getLogger(__name__)

DBT_CLOUD_CONN_ID = "dbt_cloud_default"
DBT_CLOUD_JOB_ID = int(os.environ.get("DBT_CLOUD_JOB_ID", "0"))
DB = "OLIST_SYNTHETIC_V2"

BRONZE_MIN_ROWS = {
    "OLIST.ORDERS": 30000,
    "OLIST.ORDER_ITEMS": 30000,
    "OLIST.CUSTOMERS": 30000,
    "FINANCE.PAYMENT_TRANSACTIONS": 30000,
    "LOGISTICS_TMS.SHIPMENTS": 30000,
    "PAYMENT_GATEWAY.GATEWAY_EVENTS": 100000,
}
GOLD_MIN_ROWS = {"GOLD.FACT_VENTAS": 1000, "GOLD.FACT_PAGOS": 1000}


def _snowflake():
    import snowflake.connector

    return snowflake.connector.connect(
        account=os.environ["SNOWFLAKE_ACCOUNT"],
        user=os.environ["SNOWFLAKE_USER"],
        password=os.environ["SNOWFLAKE_PASSWORD"],
        role=os.environ.get("SNOWFLAKE_ROLE", "SYSADMIN"),
        warehouse=os.environ.get("SNOWFLAKE_WAREHOUSE", "COMPUTE_WH"),
    )


def _check(min_rows: dict[str, int]) -> None:
    conn = _snowflake()
    try:
        cur = conn.cursor()
        bad = []
        for table, minimo in min_rows.items():
            cur.execute(f"SELECT COUNT(*) FROM {DB}.{table}")
            n = cur.fetchone()[0]
            log.info("%s: %s filas (minimo %s)", table, n, minimo)
            if n < minimo:
                bad.append(f"{table}={n}")
        if bad:
            raise ValueError("Tablas con menos filas de las esperadas: " + ", ".join(bad))
    finally:
        conn.close()


def notify_failure(context) -> None:
    """Punto de extension: aqui se puede enviar un correo o un mensaje a Slack."""
    ti = context["task_instance"]
    log.error("FALLO %s.%s (intento %s)", ti.dag_id, ti.task_id, ti.try_number)


with DAG(
    dag_id="olist_cloud_pipeline",
    description="Snowflake Bronze -> dbt Cloud (Silver + Gold) con verificaciones",
    start_date=pendulum.datetime(2026, 10, 1, tz="America/La_Paz"),
    schedule="0 6 * * *",
    catchup=False,
    max_active_runs=1,
    default_args={"owner": "olist", "retries": 1, "retry_delay": timedelta(minutes=5),
                  "on_failure_callback": notify_failure},
    tags=["olist", "nube", "dbt-cloud", "snowflake"],
) as dag:

    @task
    def verificar_bronze():
        _check(BRONZE_MIN_ROWS)

    dbt_build = DbtCloudRunJobOperator(
        task_id="dbt_cloud_build",
        dbt_cloud_conn_id=DBT_CLOUD_CONN_ID,
        job_id=DBT_CLOUD_JOB_ID,
        check_interval=30,
        timeout=3600,
        wait_for_termination=True,
        additional_run_config={"cause": "Disparado por Airflow (olist_cloud_pipeline)"},
        execution_timeout=timedelta(minutes=70),
    )

    @task
    def verificar_gold():
        _check(GOLD_MIN_ROWS)

    verificar_bronze() >> dbt_build >> verificar_gold()
