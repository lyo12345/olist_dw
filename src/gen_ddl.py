"""Genera los DDL de Postgres y MySQL a partir del DDL de Snowflake.

Uso (ya viene ejecutado; solo hace falta si cambias snowflake/02_ddl_tables.sql):
    python src/gen_ddl.py
"""
import re
from common import ROOT, all_tables

PG_MAP = {"FLOAT": "DOUBLE PRECISION", "TIMESTAMP_NTZ": "TIMESTAMP", "DATE": "DATE", "BOOLEAN": "BOOLEAN"}
MY_MAP = {"FLOAT": "DOUBLE", "TIMESTAMP_NTZ": "DATETIME", "DATE": "DATE", "BOOLEAN": "TINYINT(1)"}


def pg_type(t):
    if t.startswith("NUMBER"):
        return "BIGINT"
    return PG_MAP.get(t, t)


def my_type(t):
    if t.startswith("NUMBER"):
        return "BIGINT"
    return MY_MAP.get(t, t)


def main():
    tables = all_tables()
    pg, my = [], []
    pg_schemas, my_schemas = [], []
    for t in tables:
        if t.engine == "postgres":
            if t.schema not in pg_schemas:
                pg_schemas.append(t.schema)
                pg.append(f"CREATE SCHEMA IF NOT EXISTS {t.schema.lower()};\n")
            cols = ",\n".join(f'    "{c.lower()}" {pg_type(ty)}' for c, ty in t.cols)
            pg.append(f"CREATE TABLE IF NOT EXISTS {t.pg_name} (\n{cols}\n);\n")
        else:
            if t.schema not in my_schemas:
                my_schemas.append(t.schema)
                db = t.schema.lower()
                my.append(
                    f"CREATE DATABASE IF NOT EXISTS `{db}` CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;\n"
                    f"GRANT ALL PRIVILEGES ON `{db}`.* TO 'olist'@'%';\n"
                )
            cols = ",\n".join(f"    `{c.lower()}` {my_type(ty)}" for c, ty in t.cols)
            my.append(f"CREATE TABLE IF NOT EXISTS {t.my_name} (\n{cols}\n);\n")
    my.append("FLUSH PRIVILEGES;\n")
    (ROOT / "sql/postgres/10_schemas_tablas.sql").write_text("\n".join(pg), encoding="utf-8")
    (ROOT / "sql/mysql/10_bases_tablas.sql").write_text("\n".join(my), encoding="utf-8")
    n_pg = sum(1 for t in tables if t.engine == "postgres")
    print(f"Postgres: {len(pg_schemas)} schemas, {n_pg} tablas | MySQL: {len(my_schemas)} bases, {len(tables) - n_pg} tablas")


if __name__ == "__main__":
    main()
