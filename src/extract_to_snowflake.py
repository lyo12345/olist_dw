"""PASO 4: extrae las tablas desde PostgreSQL / MySQL y las sube a Snowflake (capa Bronze).

Por cada tabla:  SELECT en la base de origen -> CSV temporal -> PUT al stage de la tabla
-> COPY INTO.  Antes de cargar hace TRUNCATE, asi que es una carga completa e idempotente.

Uso:
    python src/extract_to_snowflake.py                   # las 58 tablas
    python src/extract_to_snowflake.py --source 01_olist # una fuente
    python src/extract_to_snowflake.py --engine mysql
"""
import argparse
import csv
import datetime as dt
import os
import tempfile
import time

from common import SF_DB, common_args, select_tables, sf_conn, source_conn


def fmt(sf_type, v):
    if v is None:
        return ""
    if sf_type == "BOOLEAN":
        return "true" if v else "false"
    if isinstance(v, dt.datetime):
        return v.isoformat(sep=" ")
    if isinstance(v, dt.date):
        return v.isoformat()
    if isinstance(v, float):
        return repr(v)
    return v


def open_cursor(conn, engine, name):
    if engine == "postgres":
        cur = conn.cursor(name=f"cur_{name}")  # cursor de servidor: no carga todo en memoria
        cur.itersize = 20000
        return cur
    import pymysql

    return conn.cursor(pymysql.cursors.SSCursor)


def main():
    ap = common_args(argparse.ArgumentParser(description=__doc__))
    a = ap.parse_args()
    tables = select_tables(a.engine, a.source)
    sf = sf_conn()
    sfc = sf.cursor()
    sfc.execute(f"USE DATABASE {SF_DB}")
    conns = {}
    tmp = tempfile.mkdtemp(prefix="olist_extract_")
    total = 0
    for t in tables:
        t0 = time.time()
        if t.engine not in conns:
            conns[t.engine] = source_conn(t.engine)
        conn = conns[t.engine]
        cols = ", ".join(f'"{c.lower()}"' if t.engine == "postgres" else f"`{c.lower()}`" for c in t.col_names)
        types = [ty for _, ty in t.cols]
        path = os.path.join(tmp, f"{t.name.lower()}.csv")
        n = 0
        cur = open_cursor(conn, t.engine, t.name.lower())
        cur.execute(f"SELECT {cols} FROM {t.src_name}")
        with open(path, "w", newline="", encoding="utf-8") as f:
            w = csv.writer(f)
            w.writerow(t.col_names)  # el file format hace SKIP_HEADER=1
            for row in cur:
                w.writerow([fmt(ty, v) for ty, v in zip(types, row)])
                n += 1
        cur.close()
        if t.engine == "postgres":
            conn.rollback()  # cierra la transaccion del cursor de servidor
        stage = f"@{SF_DB}.{t.schema}.%{t.name}"
        sfc.execute(f"TRUNCATE TABLE {t.sf_name}")
        sfc.execute(f"PUT 'file://{path}' {stage} AUTO_COMPRESS=TRUE OVERWRITE=TRUE")
        sfc.execute(
            f"COPY INTO {t.sf_name} FROM {stage} "
            f"FILE_FORMAT = (FORMAT_NAME = {SF_DB}.PUBLIC.CSV_STANDARD) "
            f"ON_ERROR = 'ABORT_STATEMENT' PURGE = TRUE FORCE = TRUE"
        )
        os.remove(path)
        total += n
        print(f"[{t.engine:8}] -> SNOWFLAKE {t.schema}.{t.name}: {n:>8} filas ({time.time() - t0:.1f}s)", flush=True)
    for c in conns.values():
        c.close()
    sf.close()
    print(f"OK: {len(tables)} tablas, {total} filas subidas a Snowflake.")


if __name__ == "__main__":
    main()
