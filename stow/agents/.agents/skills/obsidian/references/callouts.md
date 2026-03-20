# Callouts Reference

## Syntax

```markdown
> [!type]
> Content.

> [!type] Custom Title
> Content with custom title.

> [!type]- Collapsed by default
> Foldable content (- collapsed, + expanded).
```

## Nested Callouts

```markdown
> [!question] Outer
> > [!note] Inner
> > Nested content
```

## All Types

| Type | Aliases | Color |
|------|---------|-------|
| `note` | — | Blue |
| `abstract` | `summary`, `tldr` | Teal |
| `info` | — | Blue |
| `todo` | — | Blue |
| `tip` | `hint`, `important` | Cyan |
| `success` | `check`, `done` | Green |
| `question` | `help`, `faq` | Yellow |
| `warning` | `caution`, `attention` | Orange |
| `failure` | `fail`, `missing` | Red |
| `danger` | `error` | Red |
| `bug` | — | Red |
| `example` | — | Purple |
| `quote` | `cite` | Gray |

## Custom Callouts (CSS)

```css
.callout[data-callout="custom-type"] {
  --callout-color: 255, 0, 0;
  --callout-icon: lucide-alert-circle;
}
```
