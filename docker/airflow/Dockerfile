FROM apache/airflow:2.10.5-python3.12

# Librerias del pipeline (Snowflake, MySQL, Postgres ya viene en la imagen)
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# dbt Core en un entorno virtual aparte (evita conflictos de versiones con Airflow)
RUN python -m venv /home/airflow/dbt-venv \
 && /home/airflow/dbt-venv/bin/pip install --no-cache-dir "dbt-snowflake~=1.9.0"
