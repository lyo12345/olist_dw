"""PASO 3: crea en Snowflake la base OLIST_SYNTHETIC_V2, los 9 schemas, las 58 tablas y el file format."""
import re

from common import ROOT, sf_conn

FILES = ["01_ddl_database_schemas.sql", "02_ddl_tables.sql", "03_file_formats_and_stages.sql"]


def main():
    conn = sf_conn()
    for name in FILES:
        text = (ROOT / "snowflake" / name).read_text(encoding="utf-8")
        text = re.sub(r"--[^\n]*", "", text)  # quita comentarios (evita sentencias vacias al final)
        n = 0
        cur = conn.cursor()
        for stmt in text.split(";"):
            if stmt.strip():
                cur.execute(stmt)
                n += 1
        cur.close()
        print(f"OK {name}: {n} sentencias")
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) FROM OLIST_SYNTHETIC_V2.INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA <> 'INFORMATION_SCHEMA'")
    print("Tablas creadas en Snowflake:", cur.fetchone()[0])
    conn.close()


if __name__ == "__main__":
    main()