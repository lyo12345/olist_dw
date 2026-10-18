"""Pipeline ELT completo del proyecto Olist.

   CSV --> PostgreSQL / MySQL --> Snowflake (Bronze) --> validacion --> dbt (Silver + Gold)

Estructura:
   [carga Postgres] --> 4 tareas de extraccion a Snowflake (una por fuente)  \
                                                                             >--> validar --> dbt build
   [carga MySQL]    --> 5 tareas de extraccion a Snowflake (una por fuente)  /
"""
from datetime import timedelta

import pendulum
from airflow import DAG
from airflow.operators.bash import BashOperator

SRC = "/opt/airflow/src"
DBT = "/home/airflow/dbt-venv/bin/dbt"
DBT_ARGS = "--project-dir /opt/airflow/dbt --profiles-dir /opt/airflow/dbt"

# fuente -> motor de origen (debe coincidir con src/common.py)
POSTGRES_SOURCES = ["01_olist", "03_erp_inventory", "06_logistics_tms", "07_finance"]
MYSQL_SOURCES = [
    "02_marketing_funnel",
    "04_customer_service",
    "05_marketing_campaigns",
    "08_external_carrier",
    "09_payment_gateway",
]

with DAG(
    dag_id="olist_elt_pipeline",
    description="CSV -> Postgres/MySQL -> Snowflake -> dbt",
    start_date=pendulum.datetime(2026, 10, 1, tz="America/La_Paz"),
    schedule="0 6 * * *",
    catchup=False,
    max_active_runs=1,
    default_args={"owner": "olist", "retries": 1, "retry_delay": timedelta(minutes=2)},
    tags=["olist", "elt", "snowflake", "dbt"],
) as dag:

    load_pg = BashOperator(task_id="csv_a_postgres", bash_command=f"python {SRC}/load_csv_to_dbs.py --engine postgres")
    load_my = BashOperator(task_id="csv_a_mysql", bash_command=f"python {SRC}/load_csv_to_dbs.py --engine mysql")

    validar = BashOperator(task_id="validar_conteos", bash_command=f"python {SRC}/validate.py")
    dbt_build = BashOperator(
        task_id="dbt_build",
        bash_command=f"{DBT} build {DBT_ARGS}",
        execution_timeout=timedelta(minutes=60),
    )

    for src in POSTGRES_SOURCES:
        t = BashOperator(task_id=f"snowflake_{src}", bash_command=f"python {SRC}/extract_to_snowflake.py --source {src}")
        load_pg >> t >> validar
    for src in MYSQL_SOURCES:
        t = BashOperator(task_id=f"snowflake_{src}", bash_command=f"python {SRC}/extract_to_snowflake.py --source {src}")
        load_my >> t >> validar

    validar >> dbt_build
