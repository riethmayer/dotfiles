---
name: dlt-schema-drift-fix
description: >-
  Fix dlt schema contract violations when frozen columns or data types block
  ingestion. Use when pipeline fails with DataValidationError +
  contract_mode=freeze, when _dlt_version schema is out of sync with Pydantic
  models, when BigQuery table is missing columns, or when a field type changed.
  Triggers on: "schema drift", "frozen columns", "contract violation",
  "DataValidationError", "_dlt_version patch", "schema freeze failure",
  "columns freeze", "data_type freeze", "type mismatch", "dlt schema fix".
---

# dlt Schema Drift Fix (Frozen Columns & Data Types)

Remediation guide for `columns: "freeze"` and `data_type: "freeze"` contract violations in dlt pipelines.

## When This Happens

External data sources add/drop/rename columns or change field types. Our `schema_contract={"columns": "freeze", "data_type": "freeze"}` makes the pipeline fail loudly instead of silently drifting.

## Detection

### Column violation (`columns: "freeze"`)

Pipeline fails at `step=extract` with:
```
Contract on `columns` with `contract_mode=freeze` is violated.
Extra inputs are not permitted: Column 'new_api_field'
```

The error names the **table** and **column** that dlt can't add.

### Type violation (`data_type: "freeze"`)

Pipeline fails at `step=extract` with:
```
Contract on `data_type` with `contract_mode=freeze` is violated.
Data type 'text' in column 'field_name' is not assignable to 'bigint'
```

The error names the **column** and the **type mismatch** (incoming vs cached).

## Root Cause

dlt checks its own **schema registry** (`_dlt_version` table) at extract time, before touching BigQuery. The frozen contract is enforced against this cached schema, not the destination. So even if the BigQuery table already has the column, dlt will reject it if `_dlt_version` doesn't know about it.

Common scenario: Pydantic model was updated with new columns, but dlt's cached schema (in `_dlt_version`) still has the old column set.

**Safe to patch**: The `_dlt_version` schema registry is metadata only — it does not affect actual data in BigQuery tables. Even if the state gets corrupted, it only blocks future syncs. Patching it (via `JSON_SET` / `JSON_REMOVE`) just unblocks ingestion; actual data integrity comes from the BigQuery tables themselves.

## Before You Start: Backup

**Always create a CTAS backup** of affected tables before patching:

```sql
CREATE TABLE `<project>.<dataset>.<table>__backup_YYYYMMDD` AS
SELECT * FROM `<project>.<dataset>.<table>`;

CREATE TABLE `<project>.<dataset>._dlt_version__backup_YYYYMMDD` AS
SELECT * FROM `<project>.<dataset>._dlt_version`;
```

**Last resort: BigQuery time travel** (7-day window). If a patch goes wrong and you don't have a CTAS backup, recover from a point-in-time snapshot:

```sql
SELECT * FROM `<project>.<dataset>.<table>`
  FOR SYSTEM_TIME AS OF TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR);
```

Time travel is available for **7 days only**. Beyond that, BigQuery **fail-safe** (enabled on our datasets) provides an additional 7-day recovery window — but only Google Support can access it, so don't rely on it as a primary backup strategy.

## Fix

Both steps are required. BigQuery ALTER alone is not enough — dlt will still reject the data.

### Step 1: Add missing columns to BigQuery table

```sql
ALTER TABLE `<project>.<dataset>.<table>`
ADD COLUMN IF NOT EXISTS <col_name> <BQ_TYPE>;
```

See [references/dlt-bq-type-map.md](references/dlt-bq-type-map.md) for dlt→BigQuery type mapping.

### Step 2: Patch dlt schema registry

Update the `_dlt_version` row to include the new column definition:

```sql
UPDATE `<project>.<dataset>._dlt_version`
SET schema = TO_JSON_STRING(
  JSON_SET(
    PARSE_JSON(schema),
    '$.tables.<table>.columns.<col>',
    JSON '{"name":"<col>","data_type":"<dlt_type>","nullable":true}'
  )
)
WHERE schema_name = '<schema_name>'
  AND version = (
    SELECT MAX(version)
    FROM `<project>.<dataset>._dlt_version`
    WHERE schema_name = '<schema_name>'
  );
```

**Placeholders:**
- `<table>` — dlt table name (usually matches BigQuery table name, e.g. `dealroom_companies`)
- `<col>` — column name exactly as it appears in the Pydantic model
- `<dlt_type>` — dlt data type (see [type map](references/dlt-bq-type-map.md)), e.g. `bigint`, `text`, `double`, `timestamp`, `json`
- `<schema_name>` — dlt source name (matches `@dlt.source(name="...")` and config section)

### Step 3: Restart ingestion

After both patches, re-run the pipeline:

```bash
uv run dlt-extension pipeline run -s <source_name> -r <resource_name> -y
```

### Dropping a Column

If the source **removed** a column and it's no longer in the Pydantic model:

1. Remove the column from the Pydantic model
2. Patch `_dlt_version` to remove the column from the schema using `JSON_REMOVE`:

```sql
UPDATE `<project>.<dataset>._dlt_version`
SET schema = TO_JSON_STRING(
  JSON_REMOVE(
    PARSE_JSON(schema),
    '$.tables.<table>.columns.<col>'
  )
)
WHERE schema_name = '<schema_name>'
  AND version = (
    SELECT MAX(version)
    FROM `<project>.<dataset>._dlt_version`
    WHERE schema_name = '<schema_name>'
  );
```

No BigQuery ALTER needed — the column stays in BQ (nullable, receives NULLs going forward).

### Changing a Column Type

If the source changed a field's data type (e.g. `bigint` → `text`):

1. Update the Pydantic model to reflect the new type
2. Alter the BigQuery column type (if supported — BQ allows widening, e.g. `INT64` → `STRING`, but not narrowing):

```sql
ALTER TABLE `<project>.<dataset>.<table>`
ALTER COLUMN <col_name> SET DATA TYPE <new_BQ_TYPE>;
```

If BQ doesn't support the type change (e.g. `STRING` → `INT64`), you must drop and recreate the column:

```sql
ALTER TABLE `<project>.<dataset>.<table>` DROP COLUMN <col_name>;
ALTER TABLE `<project>.<dataset>.<table>` ADD COLUMN <col_name> <new_BQ_TYPE>;
```

3. Patch `_dlt_version` to update the column's `data_type`:

```sql
UPDATE `<project>.<dataset>._dlt_version`
SET schema = TO_JSON_STRING(
  JSON_SET(
    PARSE_JSON(schema),
    '$.tables.<table>.columns.<col>.data_type',
    JSON '"<new_dlt_type>"'
  )
)
WHERE schema_name = '<schema_name>'
  AND version = (
    SELECT MAX(version)
    FROM `<project>.<dataset>._dlt_version`
    WHERE schema_name = '<schema_name>'
  );
```

4. Restart ingestion

## Multiple Columns

Chain `JSON_SET` calls for multiple new columns:

```sql
UPDATE `<project>.<dataset>._dlt_version`
SET schema = TO_JSON_STRING(
  JSON_SET(
    JSON_SET(
      PARSE_JSON(schema),
      '$.tables.<table>.columns.<col1>',
      JSON '{"name":"<col1>","data_type":"text","nullable":true}'
    ),
    '$.tables.<table>.columns.<col2>',
    JSON '{"name":"<col2>","data_type":"bigint","nullable":true}'
  )
)
WHERE schema_name = '<schema_name>'
  AND version = (
    SELECT MAX(version)
    FROM `<project>.<dataset>._dlt_version`
    WHERE schema_name = '<schema_name>'
  );
```

## Compressed Schema Caveat

Some dlt versions store schema as zlib+base64 compressed data in `_dlt_version.schema`. If `PARSE_JSON(schema)` fails, the schema is compressed. In that case, use the Python approach:

```python
# Read, decompress, patch, recompress, write back
# See data/packages/dlt_extension/dlt_extension/discovery/cleanup.py
# for _decompress_dlt_state / _compress_dlt_state helpers
```

In our codebase, the production dataset (`raw`) stores schema as plain JSON strings — the `PARSE_JSON` approach works.

## Prevention

Run the pipeline locally against a **sandbox dataset** after updating Pydantic models. This updates the dlt schema naturally before production sees the new columns:

```bash
uv run dlt-extension pipeline run -s <source_name> -r <resource_name> -y
# Runs against sandbox__<username> by default when local
```

## Verification

After patching, confirm the schema is correct:

```sql
SELECT
  JSON_EXTRACT(PARSE_JSON(schema), '$.tables.<table>.columns.<col>') AS col_def
FROM `<project>.<dataset>._dlt_version`
WHERE schema_name = '<schema_name>'
ORDER BY version DESC
LIMIT 1;
```

## Related

- Schema contract config: `data/ingestion/patterns.md` (Schema Contracts section)
- dlt system tables: `data/packages/dlt_extension/dlt_extension/discovery/cleanup.py`
- Existing troubleshooting: `data/ingestion/troubleshooting.md`
