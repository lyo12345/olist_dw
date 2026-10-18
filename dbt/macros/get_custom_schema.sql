{% macro generate_schema_name(custom_schema_name, node) -%}
    {#
        Por defecto dbt concatena target.schema + custom_schema_name
        (ej. "PUBLIC_SILVER"). Sobreescribimos para que el schema
        declarado en dbt_project.yml (+schema: silver) sea el nombre
        final del schema en Snowflake, sin prefijo.
    #}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
