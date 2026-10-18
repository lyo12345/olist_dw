# Proyecto Olist DW desde cero — Docker (Windows) + PostgreSQL + MySQL → Snowflake → dbt → Airflow

## 0. Qué vamos a construir

```
 CSV (58 tablas, 9 fuentes)
        │  Paso 2: load_csv_to_dbs.py
        ▼
 ┌───────────────────────┐   ┌───────────────────────┐
 │ PostgreSQL (Docker)   │   │ MySQL (Docker)        │   ← "sistemas operacionales" de origen
 │ 01 olist              │   │ 02 marketing_funnel   │
 │ 03 erp_inventory      │   │ 04 customer_service   │
 │ 06 logistics_tms      │   │ 05 marketing_campaigns│
 │ 07 finance            │   │ 08 external_carrier   │
 └──────────┬────────────┘   │ 09 payment_gateway    │
            │                └──────────┬────────────┘
            └────── Paso 4: extract_to_snowflake.py ──────┐
                                                           ▼
                         Snowflake OLIST_SYNTHETIC_V2  (Bronze: 9 schemas, 58 tablas)
                                                           │  Paso 5: dbt build
                                                           ▼
                                   Silver (vistas) → Gold (dimensiones + 18 hechos)
                                                           │
                                                      Power BI

 Paso 6: Airflow (local, en Docker) ejecuta TODA la cadena en orden, cada día a las 06:00.
```

Qué hace cada pieza:

| Pieza | Para qué sirve aquí |
|---|---|
| **Docker Desktop** | Corre PostgreSQL, MySQL y Airflow en contenedores, sin instalar nada más en Windows. |
| **PostgreSQL / MySQL** | Simulan los sistemas operacionales de la empresa (de donde se extrae la información). |
| **Snowflake** | Data warehouse en la nube. Misma base (`OLIST_SYNTHETIC_V2`), mismos schemas y tablas que antes. |
| **dbt** | Transforma Bronze → Silver → Gold. Se reutiliza el proyecto `olist_silver` (carpeta `dbt/`). |
| **Airflow** | Orquesta: carga a las bases, sube a Snowflake, valida y lanza dbt. |

> Nota: Airflow corre **local** (no en Astronomer) porque PostgreSQL y MySQL viven en tu PC y la nube no puede alcanzarlas.

---

## 1. Preparar Windows

1. Requisitos: Windows 10/11 de 64 bits, **8 GB de RAM mínimo (16 GB recomendado)** y ~10 GB libres.
2. Instala **Docker Desktop**: <https://www.docker.com/products/docker-desktop/> → *Download for Windows* → ejecuta el instalador dejando marcada la opción **WSL 2** → reinicia cuando lo pida.
3. Abre Docker Desktop y espera a que abajo-izquierda diga **Engine running** (ícono verde).
4. Abre **PowerShell** y comprueba:
   ```powershell
   docker --version
   docker compose version
   ```
5. (Recomendado) Instala **VS Code** (<https://code.visualstudio.com>) para editar archivos.

## 2. Carpeta del proyecto y datos

1. Descomprime `olist_dw.zip` en **`C:\olist_dw`**. ⚠️ La ruta **no debe tener espacios ni tildes** (antes un espacio en `olist_2016 _2026` rompió un script).
2. Copia tus CSV: de tu carpeta `outputs\` copia las **9 carpetas** `01_olist`, `02_marketing_funnel`, … `09_payment_gateway` dentro de `C:\olist_dw\data\`. (No copies `07_reports`.) Debe quedar así:
   ```
   C:\olist_dw\data\01_olist\csv\customers.csv
   C:\olist_dw\data\07_finance\csv\refunds.csv
   ...
   ```
3. Crea tu archivo de configuración:
   ```powershell
   cd C:\olist_dw
   copy .env.example .env
   notepad .env
   ```
   Por ahora puedes dejar todo igual (las contraseñas de Snowflake las llenas en el Paso 4). **`.env` nunca se sube a GitHub.**

## 3. Paso 1 — Levantar PostgreSQL y MySQL

```powershell
cd C:\olist_dw
docker compose up -d postgres mysql adminer
docker compose ps
```
La primera vez descarga imágenes (2–5 min). Espera a que `postgres` y `mysql` digan **healthy**. Al arrancar por primera vez crean automáticamente los schemas/bases y las 58 tablas vacías (archivos de `sql/postgres` y `sql/mysql`).

**Ver las bases con interfaz:** abre <http://localhost:8081> (Adminer):

| Campo | PostgreSQL | MySQL |
|---|---|---|
| Sistema | PostgreSQL | MySQL |
| Servidor | `postgres` | `mysql` |
| Usuario | `olist` | `olist` |
| Contraseña | la de `.env` (`PG_PASSWORD`) | la de `.env` (`MYSQL_PASSWORD`) |
| Base de datos | `olist_pg` | (vacío; verás 5 bases: `marketing_funnel`, `customer_service`, …) |

En Postgres verás los schemas `olist`, `erp_inventory`, `logistics_tms`, `finance`. Las tablas están vacías.

## 4. Paso 2 — Construir la imagen y cargar los CSV a las bases

1. Construye la imagen de herramientas (trae Python, conectores y dbt; tarda **5–10 min** la primera vez):
   ```powershell
   docker compose build tools
   ```
2. Carga los CSV a PostgreSQL y MySQL (~1–3 min, 1.09 millones de filas):
   ```powershell
   docker compose run --rm tools python /opt/airflow/src/load_csv_to_dbs.py
   ```
   Verás una línea por tabla, por ejemplo `[postgres] OLIST.ORDERS: 33850 filas`. Termina con `OK`.
3. Revisa en Adminer que `olist.orders` tenga 33 850 filas.

Es **repetible**: cada ejecución hace TRUNCATE y recarga.

## 5. Paso 3 — Preparar Snowflake

1. Edita `.env` y completa:
   - `SNOWFLAKE_ACCOUNT`: en Snowsight, clic en tu nombre (abajo-izquierda) → **Account** → *Copy account identifier* (formato `ORGANIZACION-CUENTA`).
   - `SNOWFLAKE_USER`, `SNOWFLAKE_PASSWORD`, `SNOWFLAKE_ROLE` (`SYSADMIN`), `SNOWFLAKE_WAREHOUSE` (`COMPUTE_WH`).
2. Si ya existe una base `OLIST_SYNTHETIC_V2` con datos y quieres empezar limpio, en Snowsight ejecuta `DROP DATABASE IF EXISTS OLIST_SYNTHETIC_V2;`.
3. Crea la base, los 9 schemas, las 58 tablas y el file format:
   ```powershell
   docker compose run --rm tools python /opt/airflow/src/snowflake_setup.py
   ```
   Debe terminar con `Tablas creadas en Snowflake: 58`.

> Si tu cuenta pide **MFA** al usar contraseña y el script falla con un error de autenticación, usa llave RSA (usuario de tipo servicio): dímelo y te guío con ese paso.

## 6. Paso 4 — Subir de PostgreSQL/MySQL a Snowflake (Bronze)

```powershell
docker compose run --rm tools python /opt/airflow/src/extract_to_snowflake.py
```
Por cada tabla: lee de la base de origen → crea un CSV temporal → `PUT` al stage → `COPY INTO`. Tarda ~3–8 min según tu internet.

Valida que **todo coincida** (CSV = base de origen = Snowflake):
```powershell
docker compose run --rm tools python /opt/airflow/src/validate.py
```
Debe terminar en **TODO OK** (58 tablas, 3 columnas iguales).

## 7. Paso 5 — dbt: capas Silver y Gold

Usamos **dbt Core** dentro de Docker (gratis, sin límite de prueba). El proyecto es el mismo `olist_silver` que ya conoces (`dbt/`): staging → **Silver** (vistas), marts → **Gold** (dimensiones + 18 hechos).

```powershell
docker compose run --rm tools /home/airflow/dbt-venv/bin/dbt debug --project-dir /opt/airflow/dbt --profiles-dir /opt/airflow/dbt
docker compose run --rm tools /home/airflow/dbt-venv/bin/dbt build --project-dir /opt/airflow/dbt --profiles-dir /opt/airflow/dbt
```
- `debug` debe terminar en *All checks passed*.
- `build` ejecuta modelos + tests. En Snowflake aparecen los schemas `SILVER` y `GOLD` dentro de `OLIST_SYNTHETIC_V2`.

Si prefieres **dbt Cloud**, apunta el proyecto al repositorio GitHub con la carpeta `dbt/` como *project subdirectory* y las mismas credenciales de Snowflake; los modelos no cambian.

## 8. Paso 6 — Airflow: orquestar todo

1. Arranca Airflow (la primera vez crea su base de metadatos y tu usuario):
   ```powershell
   docker compose up -d airflow-init airflow-webserver airflow-scheduler
   ```
   Espera ~1–2 min.
2. Abre <http://localhost:8080> → usuario/contraseña = `AIRFLOW_ADMIN_USER` / `AIRFLOW_ADMIN_PASSWORD` de tu `.env` (por defecto `admin` / `admin`).
3. Busca el DAG **`olist_elt_pipeline`**, actívalo (interruptor) y pulsa ▶ **Trigger**.
4. Abre la pestaña **Graph**. El orden es:
   `csv_a_postgres` / `csv_a_mysql` → 9 tareas `snowflake_<fuente>` (en paralelo, máx. 4) → `validar_conteos` → `dbt_build`.
5. Haz clic en cualquier tarea → **Logs** para ver la salida. Todo verde = pipeline completo.

El DAG está programado a las **06:00 (hora La Paz)**. Para cambiarlo edita `schedule=` en `dags/olist_elt_pipeline.py` (Airflow lo detecta solo, sin reiniciar).

## 9. Paso 7 — GitHub (opcional pero recomendado)

```powershell
cd C:\olist_dw
git init
git add .
git commit -m "Proyecto Olist DW"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/olist_dw.git
git push -u origin main
```
El `.gitignore` excluye `.env`, `data/` y `secrets/`: **ninguna contraseña ni CSV se sube**.

## 10. Uso diario

| Acción | Comando |
|---|---|
| Apagar todo (conserva datos) | `docker compose stop` |
| Encender todo | `docker compose up -d postgres mysql adminer airflow-webserver airflow-scheduler` |
| Ver logs de Airflow | `docker compose logs -f airflow-scheduler` |
| Borrar todo y empezar de cero | `docker compose down -v` |

## 11. Problemas frecuentes

| Síntoma | Causa / solución |
|---|---|
| `docker: command not found` o "Engine stopped" | Abre Docker Desktop y espera al ícono verde. |
| `port is already allocated` (5432/3306/8080) | Otro programa usa ese puerto: ciérralo o cambia el número izquierdo en `docker-compose.yml` (ej. `"5433:5432"`). |
| `FileNotFoundError ... data/01_olist/csv/...` | Los CSV no están en `C:\olist_dw\data\<fuente>\csv\`. Revisa el Paso 2. |
| `KeyError: 'PG_PASSWORD'` | Falta `.env` (copia `.env.example`). |
| Cambié tablas pero Postgres/MySQL no las ven | Los scripts de `sql/` solo corren en el primer arranque: `docker compose down -v` y vuelve a levantar. |
| `250001 (08001): Failed to connect to DB` | `SNOWFLAKE_ACCOUNT` mal escrito (usa `ORG-CUENTA`, sin `https://` ni `.snowflakecomputing.com`). |
| `Incorrect username or password` / MFA | Revisa usuario y contraseña; con MFA usa llave RSA. |
| `Warehouse ... suspended` o sin warehouse | Verifica `SNOWFLAKE_WAREHOUSE` y que el rol tenga permiso `USAGE`. |
| Airflow no muestra el DAG | `docker compose logs airflow-scheduler` y busca el error de importación; confirma que `dags/` esté montada. |
| Docker se vuelve muy lento | Docker Desktop → Settings → Resources: asigna ≥ 6 GB de RAM. |

## 12. Estructura del proyecto

```
olist_dw/
├─ docker-compose.yml        # Postgres, MySQL, Adminer, Airflow, "tools"
├─ .env.example              # copiar a .env
├─ docker/airflow/           # Dockerfile (Python libs + dbt Core)
├─ sql/postgres, sql/mysql   # DDL que se ejecuta al primer arranque (generado por src/gen_ddl.py)
├─ snowflake/                # DDL de Snowflake (base, schemas, tablas, file format)
├─ src/                      # scripts: load_csv_to_dbs, snowflake_setup, extract_to_snowflake, validate
├─ dbt/                      # proyecto dbt (Silver + Gold)
├─ dags/olist_elt_pipeline.py# DAG de Airflow
└─ data/                     # AQUÍ van tus CSV (no se sube a GitHub)
```

---

# PARTE NUBE — GitHub + dbt Cloud + Astronomer

## Qué corre dónde

```
 TU PC (Docker)                                   NUBE
 CSV → PostgreSQL/MySQL → Snowflake (Bronze) ───► Astronomer (Airflow) ──► dbt Cloud (Silver + Gold)
 DAG local: olist_elt_pipeline                    DAG: olist_cloud_pipeline   job: olist_dbt_build
```
- PostgreSQL y MySQL viven en tu PC (simulan los sistemas de origen), así que **la carga de origen → Snowflake corre en el Airflow local**.
- **Astronomer** (nube) no puede ver tu PC: su DAG `olist_cloud_pipeline` verifica Bronze, dispara dbt Cloud y verifica Gold.
- Un solo repositorio de GitHub (`olist_dw`) alimenta a los dos: `dbt/` → dbt Cloud, `astro/` → Astronomer.

## A. GitHub (repositorio nuevo)
1. Instala Git para Windows: `winget install --id Git.Git -e` (o <https://git-scm.com/download/win>). Cierra y vuelve a abrir PowerShell; comprueba con `git --version`.
2. En <https://github.com/new> crea el repositorio **`olist_dw`** (Private, sin README ni .gitignore).
3. Antes de subir, edita estos 2 archivos con tus datos (los marcadores dicen `CAMBIAR`):
   - `astro\Dockerfile` → versión de Astro Runtime de tu Deployment.
   - `.github\workflows\deploy-astro.yml` → `deployment-id` de tu Deployment.
4. Sube el proyecto:
   ```powershell
   cd C:\olist_dw
   git init
   git add .
   git ls-files | findstr /i "\.env$ data/ secrets/"
   ```
   El último comando solo debe mostrar `.env.example`, `data/.gitkeep` y `secrets/.gitkeep`. **Si aparece `.env`, detente.**
   ```powershell
   git commit -m "Proyecto Olist DW"
   git branch -M main
   git remote add origin https://github.com/TU_USUARIO/olist_dw.git
   git push -u origin main
   ```
   La primera vez se abre el navegador para iniciar sesión en GitHub.

## B. dbt Cloud
1. **Proyecto:** Account settings → Projects → New project → nombre `olist_dw`.
2. **Conexión Snowflake:** Account `VRWCBNE-MG28869` (tu identificador), Database `OLIST_SYNTHETIC_V2`, Warehouse `COMPUTE_WH`, Role `ACCOUNTADMIN` o `SYSADMIN`. Credenciales de desarrollo: tu usuario/contraseña, schema `dbt_dev`. *Test connection*.
3. **Repositorio:** GitHub → instala la app de dbt en el repo `olist_dw`.
4. **Subdirectorio:** Project settings → Edit → **Project subdirectory = `dbt`** (importante).
5. **Entorno de producción:** Deploy → Environments → Create → tipo *Deployment*, dbt *Latest*, credenciales Snowflake (usuario/contraseña), schema `PUBLIC`.
6. **Job:** Deploy → Jobs → Create → nombre `olist_dbt_build`, entorno de producción, comando `dbt build`, **sin schedule** (lo dispara Airflow). Ejecútalo con *Run now* y confirma que termina en *Success*.
7. Anota de la URL del job: `…/accounts/<ACCOUNT_ID>/projects/…/jobs/<JOB_ID>/`.
8. **Token de servicio:** Account settings → Service tokens → New → permiso **Job Admin** → copia el token (solo se ve una vez).
9. **Prueba el token** antes de usarlo (PowerShell):
   ```powershell
   $env:T = Read-Host "Pega el token"
   (Invoke-RestMethod -Uri "https://cloud.getdbt.com/api/v2/accounts/ACCOUNT_ID/jobs/JOB_ID/" -Headers @{Authorization="Token $env:T"}).data | Select-Object id, name
   Remove-Item Env:T
   ```
   Debe mostrar el id y el nombre del job. Si da 401, el token está mal: crea otro.

> La prueba de 15 días de dbt Cloud termina; después revisa qué incluye tu plan. Si el job/API dejara de estar disponible, el DAG local `olist_elt_pipeline` ya construye Silver y Gold con dbt Core y no depende de dbt Cloud.

## C. Astronomer
1. **Variables de entorno** (Deployment → Environment → Add), marcando *Secret* en las sensibles:

   | Variable | Valor | Secreta |
   |---|---|---|
   | `DBT_CLOUD_JOB_ID` | ID del job nuevo | no |
   | `AIRFLOW_CONN_DBT_CLOUD_DEFAULT` | `dbt-cloud://ACCOUNT_ID:TOKEN_DE_SERVICIO@` | sí |
   | `SNOWFLAKE_ACCOUNT` | `VRWCBNE-MG28869` | no |
   | `SNOWFLAKE_USER` | tu usuario | no |
   | `SNOWFLAKE_PASSWORD` | tu contraseña | sí |
   | `SNOWFLAKE_ROLE` | `SYSADMIN` o `ACCOUNTADMIN` | no |
   | `SNOWFLAKE_WAREHOUSE` | `COMPUTE_WH` | no |

   Si ya existían `DBT_CLOUD_JOB_ID` y `AIRFLOW_CONN_DBT_CLOUD_DEFAULT`, **edítalas** con los valores nuevos.
2. **Token para GitHub Actions:** crea un API token del Deployment (Deployment → Access/API tokens, rol *Deployment Admin*). En GitHub: repo `olist_dw` → Settings → Secrets and variables → Actions → New repository secret → nombre **`ASTRO_API_TOKEN`**.
3. **Desplegar:** al hacer `git push` a `main` con cambios en `astro/`, la pestaña *Actions* de GitHub ejecuta el despliegue (también despierta el Deployment si estaba hibernando). Para forzarlo: Actions → Deploy to Astro → Run workflow, o un commit pequeño en `astro/`.
4. **Probar:** abre Airflow en Astronomer → DAG `olist_cloud_pipeline` → Trigger. Orden: `verificar_bronze` → `dbt_cloud_build` → `verificar_gold`. En dbt Cloud → Runs aparecerá una ejecución "Disparado por Airflow".
5. **Limpieza:** si el repositorio antiguo (`lyo12345/olist`) sigue desplegando al mismo Deployment, desactívalo o bórralo para que no pise el DAG nuevo.
