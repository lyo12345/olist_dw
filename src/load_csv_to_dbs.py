"""PASO 2: carga los CSV en PostgreSQL y MySQL (las bases "operacionales" de origen).

Es idempotente: vacia cada tabla (TRUNCATE) y la vuelve a llenar.

Uso:
    python src/load_csv_to_dbs.py                      # todo
    python src/load_csv_to_dbs.py --engine postgres    # solo Postgres
    python src/load_csv_to_dbs.py --source 01_olist    # una sola fuente
"""
import argparse
import csv
import io
import time

from common import chunks, common_args, iter_rows, mysql_conn, pg_conn, select_tables


def load_postgres(tables):
    conn = pg_conn()
    cur = conn.cursor()
    for t in tables:
        t0 = time.time()
        cur.execute(f"TRUNCATE TABLE {t.pg_name}")
        cols = ", ".join(f'"{c.lower()}"' for c in t.col_names)
        n = 0
        for batch in chunks(iter_rows(t), 20000):
            buf = io.StringIO()
            w = csv.writer(buf, lineterminator="\n")
            for r in batch:
                w.writerow(["" if v is None else ("true" if v is True else "false" if v is False else v) for v in r])
            buf.seek(0)
            cur.copy_expert(f"COPY {t.pg_name} ({cols}) FROM STDIN WITH (FORMAT csv, NULL '')", buf)
            n += len(batch)
        conn.commit()
        print(f"[postgres] {t.schema}.{t.name}: {n:>8} filas  ({time.time() - t0:.1f}s)", flush=True)
    conn.close()


def load_mysql(tables):
    conn = mysql_conn()
    cur = conn.cursor()
    for t in tables:
        t0 = time.time()
        cur.execute(f"TRUNCATE TABLE {t.my_name}")
        cols = ", ".join(f"`{c.lower()}`" for c in t.col_names)
        sql = f"INSERT INTO {t.my_name} ({cols}) VALUES ({', '.join(['%s'] * len(t.cols))})"
        n = 0
        for batch in chunks(iter_rows(t), 5000):
            cur.executemany(sql, batch)
            n += len(batch)
        conn.commit()
        print(f"[mysql]    {t.schema}.{t.name}: {n:>8} filas  ({time.time() - t0:.1f}s)", flush=True)
    conn.close()


def main():
    ap = common_args(argparse.ArgumentParser(description=__doc__))
    a = ap.parse_args()
    if a.engine in ("postgres", "all"):
        ts = select_tables("postgres", a.source)
        if ts:
            load_postgres(ts)
    if a.engine in ("mysql", "all"):
        ts = select_tables("mysql", a.source)
        if ts:
            load_mysql(ts)
    print("OK: carga a las bases de origen terminada.")


if __name__ == "__main__":
    main()
