"""Compara conteos de filas: CSV  vs  base de origen (Postgres/MySQL)  vs  Snowflake.

Uso:
    python src/validate.py                 # las 3 columnas
    python src/validate.py --no-snowflake  # solo CSV vs Postgres/MySQL
Sale con codigo 1 si hay diferencias (asi Airflow marca la tarea como fallida).
"""
import argparse
import csv
import sys

from common import SF_DB, all_tables, sf_conn, source_conn


def count_csv(t):
    with open(t.csv_path, newline="", encoding="utf-8-sig") as f:
        r = csv.reader(f)
        next(r)
        return sum(1 for _ in r)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--no-snowflake", action="store_true")
    a = ap.parse_args()
    conns = {}
    sf = None if a.no_snowflake else sf_conn()
    bad = 0
    print(f"{'tabla':48}{'CSV':>10}{'ORIGEN':>10}{'SNOWFLAKE':>11}  estado")
    for t in all_tables():
        n_csv = count_csv(t)
        if t.engine not in conns:
            conns[t.engine] = source_conn(t.engine)
        cur = conns[t.engine].cursor()
        cur.execute(f"SELECT COUNT(*) FROM {t.src_name}")
        n_src = cur.fetchone()[0]
        cur.close()
        n_sf = None
        if sf:
            c = sf.cursor()
            c.execute(f"SELECT COUNT(*) FROM {SF_DB}.{t.schema}.{t.name}")
            n_sf = c.fetchone()[0]
            c.close()
        ok = n_csv == n_src and (n_sf is None or n_sf == n_csv)
        bad += 0 if ok else 1
        print(f"{t.schema + '.' + t.name:48}{n_csv:>10}{n_src:>10}{(n_sf if n_sf is not None else '-'):>11}  {'OK' if ok else 'DIFERENCIA'}")
    print(f"\n{'TODO OK' if bad == 0 else str(bad) + ' tablas con diferencias'}")
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
