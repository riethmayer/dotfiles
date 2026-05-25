# dlt → BigQuery Type Mapping

Use this when patching `_dlt_version` schema or adding columns to BigQuery.

| Python / Pydantic Type | dlt `data_type` | BigQuery Type |
|------------------------|-----------------|---------------|
| `str` | `text` | `STRING` |
| `int` | `bigint` | `INT64` |
| `float` | `double` | `FLOAT64` |
| `bool` | `bool` | `BOOL` |
| `datetime` | `timestamp` | `TIMESTAMP` |
| `date` | `date` | `DATE` |
| `time` | `time` | `TIME` |
| `Decimal` | `decimal` | `NUMERIC` |
| `bytes` | `binary` | `BYTES` |
| `dict` / `list[dict]` | `json` | `JSON` |

## Notes

- `nullable` should be `true` for new columns (existing rows won't have the value)
- Column names in the schema patch must match the Pydantic field name exactly
- For `json` columns, also ensure `max_table_nesting=0` on the resource to prevent dlt from unpacking nested JSON into child tables
