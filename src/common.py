"""Utilidades compartidas por todos los scripts del pipeline.

- Lee el DDL de Snowflake (snowflake/02_ddl_tables.sql) y de ahi deduce las 58 tablas,
  sus columnas y tipos. Asi Postgres, MySQL y Snowflake quedan con la MISMA estructura.
- Define en que motor vive cada fuente (Postgres o MySQL).
- Conversores de valores y conexiones a las 3 bases.
"""
import csv
import os
import re
import sys
from dataclasses import dataclass
from pathlib import Path

csv.field_size_limit(2**31 - 1)

# En el contenedor ROOT = /opt/airflow ; fuera, la carpeta del proyecto.
ROOT = Path(os.environ.get("PROJECT_ROOT") or Path(__file__).resolve().parents[1])
DATA_DIR = ROOT / "data"
DDL_FILE = ROOT / "snowflake" / "02_ddl_tables.sql"
SF_DB = "OLIST_SYNTHETIC_V2"

# carpeta de datos -> (schema en Snowflake, motor de la base de origen)
SOURCES = {
    "01_olist": ("OLIST", "postgres"),
    "02_marketing_funnel": ("MARKETING_FUNNEL", "mysql"),
    "03_erp_inventory": ("ERP_INVENTORY", "postgres"),
    "04_customer_service": ("CUSTOMER_SERVICE", "mysql"),
    "05_marketing_campaigns": ("MARKETING_CAMPAIGNS", "mysql"),
    "06_logistics_tms": ("LOGISTICS_TMS", "postgres"),
    "07_finance": ("FINANCE", "postgres"),
    "08_external_carrier": ("EXTERNAL_CARRIER", "mysql"),
    "09_payment_gateway": ("PAYMENT_GATEWAY", "mysql"),
}

NULLS = {"", "NULL", "None", "NaT", "nan"}  # igual que NULL_IF del file format de Snowflake

_TABLE_RE = re.compile(r"CREATE OR REPLACE TABLE\s+\w+\.(\w+)\.(\w+)\s*\((.*?)\n\);", re.S)
_COL_RE = re.compile(r'"(\w+)"\s+(VARCHAR\(\d+\)|NUMBER\(\d+,\d+\)|FLOAT|TIMESTAMP_NTZ|DATE|BOOLEAN)')


@dataclass
class Table:
    folder: str
    schema: str  # MAYUSCULAS (como en Snowflake)
    name: str  # MAYUSCULAS
    engine: str
    cols: list  # [(nombre_mayus, tipo_snowflake)]

    @property
    def col_names(self):
        return [c for c, _ in self.cols]

    @property
    def csv_path(self):
        return DATA_DIR / self.folder / "csv" / f"{self.name.lower()}.csv"

    @property
    def pg_name(self):
        return f'"{self.schema.lower()}"."{self.name.lower()}"'

    @property
    def my_name(self):
        return f"`{self.schema.lower()}`.`{self.name.lower()}`"

    @property
    def src_name(self):
        return self.pg_name if self.engine == "postgres" else self.my_name

    @property
    def sf_name(self):
        return f"{SF_DB}.{self.schema}.{self.name}"


def all_tables():
    schema_to_folder = {v[0]: (k, v[1]) for k, v in SOURCES.items()}
    text = DDL_FILE.read_text(encoding="utf-8")
    tables = []
    for schema, name, body in _TABLE_RE.findall(text):
        folder, engine = schema_to_folder[schema]
        cols = [(c, t) for c, t in _COL_RE.findall(body)]
        tables.append(Table(folder, schema, name, engine, cols))
    return tables


def select_tables(engine=None, sources=None):
    out = []
    for t in all_tables():
        if engine and engine != "all" and t.engine != engine:
            continue
        if sources and t.folder not in sources:
            continue
        out.append(t)
    return out


def convert(sf_type, v):
    """Convierte un texto del CSV al tipo Python que corresponde."""
    if v in NULLS:
        return None
    if sf_type.startswith("NUMBER"):
        try:
            return int(v)
        except ValueError:
            return int(float(v))
    if sf_type == "FLOAT":
        return float(v)
    if sf_type == "BOOLEAN":
        return v.strip().lower() in ("true", "t", "1", "yes", "y")
    return v


def iter_rows(table):
    """Lee el CSV de la tabla y devuelve filas convertidas, en el orden de columnas del DDL."""
    with open(table.csv_path, newline="", encoding="utf-8-sig") as f:
        r = csv.reader(f)
        header = [h.strip().lower() for h in next(r)]
        idx = [header.index(c.lower()) for c in table.col_names]
        types = [t for _, t in table.cols]
        for row in r:
            yield [convert(t, row[i]) for t, i in zip(types, idx)]


def chunks(iterable, size):
    batch = []
    for x in iterable:
        batch.append(x)
        if len(batch) >= size:
            yield batch
            batch = []
    if batch:
        yield batch


# ---------------------------------------------------------------- conexiones
def pg_conn():
    import psycopg2

    return psycopg2.connect(
        host=os.environ.get("PG_HOST", "postgres"),
        port=int(os.environ.get("PG_PORT", "5432")),
        dbname=os.environ.get("PG_DB", "olist_pg"),
        user=os.environ.get("PG_USER", "olist"),
        password=os.environ["PG_PASSWORD"],
    )


def mysql_conn():
    import pymysql

    return pymysql.connect(
        host=os.environ.get("MYSQL_HOST", "mysql"),
        port=int(os.environ.get("MYSQL_PORT", "3306")),
        user=os.environ.get("MYSQL_USER", "olist"),
        password=os.environ["MYSQL_PASSWORD"],
        charset="utf8mb4",
        autocommit=False,
    )


def sf_conn():
    import snowflake.connector

    kw = dict(
        account=os.environ["SNOWFLAKE_ACCOUNT"],
        user=os.environ["SNOWFLAKE_USER"],
        warehouse=os.environ.get("SNOWFLAKE_WAREHOUSE", "COMPUTE_WH"),
        role=os.environ.get("SNOWFLAKE_ROLE", "SYSADMIN"),
    )
    key_file = os.environ.get("SNOWFLAKE_PRIVATE_KEY_FILE")
    if key_file:  # autenticacion por llave RSA (opcional)
        from cryptography.hazmat.primitives import serialization

        with open(key_file, "rb") as f:
            pk = serialization.load_pem_private_key(f.read(), password=None)
        kw["private_key"] = pk.private_bytes(
            serialization.Encoding.DER,
            serialization.PrivateFormat.PKCS8,
            serialization.NoEncryption(),
        )
    else:
        kw["password"] = os.environ["SNOWFLAKE_PASSWORD"]
    return snowflake.connector.connect(**kw)


def source_conn(engine):
    return pg_conn() if engine == "postgres" else mysql_conn()


def common_args(parser):
    parser.add_argument("--engine", choices=["postgres", "mysql", "all"], default="all")
    parser.add_argument("--source", action="append", help="carpeta de fuente, ej. 01_olist (repetible)")
    return parser
