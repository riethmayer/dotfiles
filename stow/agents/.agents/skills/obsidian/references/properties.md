# Properties (Frontmatter) Reference

YAML frontmatter at the top of a note, delimited by `---`.

## Property Types

| Type | Example |
|------|---------|
| Text | `title: My Title` |
| Number | `rating: 4.5` |
| Checkbox | `completed: true` |
| Date | `date: 2024-01-15` |
| Date & Time | `due: 2024-01-15T14:30:00` |
| List | `tags: [one, two]` or YAML list |
| Links | `related: "[[Other Note]]"` |

## Vault-Specific Fields

| Field | Type | Usage |
|-------|------|-------|
| `date` | `YYYY-MM-DD` or `YYYY-MM-DD HH:mm` | Creation date |
| `tags` | list | Categorization tags |
| `hubs` | list of wikilinks | Parent hub/MOC links, e.g. `"[[Leadership]]"` |
| `urls` | list | External reference URLs |
| `id` | string | Optional unique identifier |
| `aliases` | list | Alternative names for the note |
| `type` | string | Note type: `moc`, `index` |
| `area` | string | Area classification (used in MOCs) |
| `created` | `YYYY-MM-DD` | Creation date (used in MOCs) |

## Default Obsidian Properties

- `tags` — searchable labels, shown in graph view
- `aliases` — alternative note names used in link suggestions
- `cssclasses` — CSS classes applied to the note

## Tags

```markdown
#tag
#nested/tag
#tag-with-dashes
#tag_with_underscores
```

Tags can contain: letters (any language), numbers (not first character), underscores, hyphens, forward slashes (for nesting).

In frontmatter:

```yaml
tags:
  - tag1
  - nested/tag2
```

## Excalidraw Fields

These are set by the Excalidraw plugin — do NOT add them to new notes unless the note is an Excalidraw drawing:

```yaml
excalidraw-plugin: parsed
excalidraw-open-md: true
excalidraw-export-padding: 0
excalidraw-export-dark: true
```
