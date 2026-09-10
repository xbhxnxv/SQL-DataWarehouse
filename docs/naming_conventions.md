# Naming Conventions

The rules below keep table, column, and object names consistent across the Bronze, Silver, and Gold layers.

## General

- Use `snake_case` — lowercase words separated by underscores.
- Use English for all names.
- Do not use SQL reserved words as object names.

## Table naming

### Bronze and Silver

Tables keep the source system's original names, prefixed by the source. No renaming:

`<sourcesystem>_<entity>`

- `<sourcesystem>` — the source system: `crm` or `erp`.
- `<entity>` — the exact table name from the source system.
- Example: `crm_cust_info` — customer information from the CRM system.

### Gold

Tables (views) use business-meaningful names, prefixed by their category:

`<category>_<entity>`

- `<category>` — the role of the table: `dim` (dimension), `fact` (fact table).
- `<entity>` — a descriptive business name.
- Examples: `dim_customers`, `dim_products`, `fact_sales`.

## Column naming

### Surrogate keys

Primary keys in dimension tables use the suffix `_key`:

`<entity>_key`

- Example: `customer_key` — surrogate key in `dim_customers`.

### Technical / metadata columns

System-generated columns use the prefix `dwh_`:

`dwh_<column>`

- Example: `dwh_create_date` — the date a record was loaded into the warehouse.

## Stored procedures

Load procedures follow the pattern:

`load_<layer>`

- Examples: `load_bronze`, `load_silver`.
