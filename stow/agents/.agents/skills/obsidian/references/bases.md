# Bases (.base files)

Obsidian's built-in database view system. Files use `.base` extension with YAML content.

## Schema

```yaml
# Global filters — apply to ALL views
filters:
  and: []
  or: []
  not: []

# Computed properties
formulas:
  formula_name: 'expression'

# Display config
properties:
  property_name:
    displayName: "Display Name"
  formula.formula_name:
    displayName: "Formula Display"

# Custom summary formulas
summaries:
  custom_name: 'values.mean().round(3)'

# One or more views
views:
  - type: table | cards | list | map
    name: "View Name"
    limit: 10
    groupBy:
      property: property_name
      direction: ASC | DESC
    filters:
      and: []
    order:
      - file.name
      - property_name
      - formula.formula_name
    summaries:
      property_name: Average
```

## Filter Syntax

```yaml
# Single filter
filters: 'status == "done"'

# AND — all true
filters:
  and:
    - 'status == "done"'
    - 'priority > 3'

# OR — any true
filters:
  or:
    - 'file.hasTag("book")'
    - 'file.hasTag("article")'

# NOT — exclude
filters:
  not:
    - 'file.hasTag("archived")'

# Nested
filters:
  or:
    - file.hasTag("tag")
    - and:
        - file.hasTag("book")
        - file.hasLink("Textbook")
```

### Operators

`==`, `!=`, `>`, `<`, `>=`, `<=`, `&&`, `||`, `!`

## Properties

Three types:
1. **Note properties** — from frontmatter: `author` or `note.author`
2. **File properties** — metadata: `file.name`, `file.mtime`, etc.
3. **Formula properties** — computed: `formula.my_formula`

### File Properties

| Property | Type | Description |
|----------|------|-------------|
| `file.name` | String | File name |
| `file.basename` | String | Name without extension |
| `file.path` | String | Full path |
| `file.folder` | String | Parent folder |
| `file.ext` | String | Extension |
| `file.size` | Number | Size in bytes |
| `file.ctime` | Date | Created time |
| `file.mtime` | Date | Modified time |
| `file.tags` | List | All tags |
| `file.links` | List | Internal links |
| `file.backlinks` | List | Files linking here |

### File Functions

| Function | Description |
|----------|-------------|
| `file.hasTag(...tags)` | Has any of these tags |
| `file.hasLink(file)` | Has link to file |
| `file.hasProperty(name)` | Has property |
| `file.inFolder(folder)` | In folder or subfolder |

## Views

### Table

```yaml
views:
  - type: table
    name: "My Table"
    order: [file.name, status, due_date]
    summaries:
      price: Sum
```

### Cards

```yaml
views:
  - type: cards
    name: "Gallery"
    order: [cover, file.name, description]
```

### List

```yaml
views:
  - type: list
    name: "Simple"
    order: [file.name, status]
```

### Map

Requires lat/lng properties and Maps plugin.

## Default Summaries

| Name | Input | Description |
|------|-------|-------------|
| `Average` | Number | Mean |
| `Sum` | Number | Total |
| `Min`/`Max` | Number | Extremes |
| `Median` | Number | Middle value |
| `Range` | Number | Max - Min |
| `Earliest`/`Latest` | Date | Date extremes |
| `Checked`/`Unchecked` | Boolean | Count |
| `Empty`/`Filled` | Any | Count |
| `Unique` | Any | Distinct count |

## Formula Basics

```yaml
formulas:
  total: "price * quantity"
  status_icon: 'if(done, "✅", "⏳")'
  days_old: '(now() - file.ctime).days'
  days_until: 'if(due_date, (date(due_date) - today()).days, "")'
```

**Duration gotcha:** date subtraction returns Duration, not number. Access `.days` first, then `.round()`:

```yaml
# WRONG
"(now() - file.ctime).round(0)"

# CORRECT
"(now() - file.ctime).days.round(0)"
```

See [bases-functions.md](bases-functions.md) for the complete function reference.

## YAML Quoting

- Single quotes for formulas with double quotes: `'if(done, "Yes", "No")'`
- Double quotes for simple strings: `"My View"`
- Strings with `:`, `#`, `{`, `}`, `[`, `]` must be quoted

## Embedding

```markdown
![[MyBase.base]]
![[MyBase.base#View Name]]
```

## Complete Example

```yaml
filters:
  and:
    - file.hasTag("task")
    - 'file.ext == "md"'

formulas:
  days_until_due: 'if(due, (date(due) - today()).days, "")'
  is_overdue: 'if(due, date(due) < today() && status != "done", false)'
  priority_label: 'if(priority == 1, "🔴 High", if(priority == 2, "🟡 Medium", "🟢 Low"))'

properties:
  formula.days_until_due:
    displayName: "Days Left"
  formula.priority_label:
    displayName: Priority

views:
  - type: table
    name: "Active Tasks"
    filters:
      and:
        - 'status != "done"'
    order:
      - file.name
      - status
      - formula.priority_label
      - due
      - formula.days_until_due
    groupBy:
      property: status
      direction: ASC

  - type: table
    name: "Completed"
    filters:
      and:
        - 'status == "done"'
    order:
      - file.name
      - completed_date
```
