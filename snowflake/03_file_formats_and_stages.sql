USE DATABASE OLIST_SYNTHETIC_V2;
USE SCHEMA PUBLIC;

CREATE OR REPLACE FILE FORMAT CSV_STANDARD
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  NULL_IF = ('', 'NULL', 'None', 'NaT', 'nan')
  EMPTY_FIELD_AS_NULL = TRUE
  TIMESTAMP_FORMAT = 'AUTO'
  DATE_FORMAT = 'AUTO'
  ENCODING = 'UTF8';

-- Nota: se usan 'table stages' internos (@schema.%table), creados automaticamente
-- por Snowflake junto con cada tabla; no requieren CREATE STAGE explicito.
