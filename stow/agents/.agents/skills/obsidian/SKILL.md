---
name: obsidian
description: Work with Obsidian vaults — create, search, organize, and write notes using Obsidian-flavored Markdown, wikilinks, embeds, callouts, frontmatter, Bases database views, and obsidian-cli. Use when working with .md files in Obsidian, .base files, daily notes, zettelkasten, meeting notes, or when the user mentions their vault, wikilinks, callouts, tags, embeds, MOCs, or note organization. Also use for Granola meeting transcript imports.
user_invocable: false
---

# Obsidian

## Vault

- **Path:** `/Users/jan/obsidian/riethmayer`
- **CLI:** `obsidian-cli` (v0.2.2) — see [references/cli.md](references/cli.md)
- **Links auto-update** on move/rename (`alwaysUpdateLinks: true`)

### Folder Structure (PARA)

```
1 - Projects/       # Active projects with deadlines
2 - Areas/          # Ongoing responsibilities (Journal, CTO, Coaching…)
3 - Resources/      # Reference material (Templates, Books, Checklists…)
zettelkasten/        # Permanent knowledge notes (30+ topic folders)
inbox/               # Quick capture, unsorted
Excalidraw/          # Visual diagrams
```

### Where Notes Go

| Note Type | Destination |
|-----------|-------------|
| Active project | `1 - Projects/{project-name}/` |
| Role/responsibility | `2 - Areas/{area}/` |
| Daily notes | `2 - Areas/Journal/YYYY/MM-MMMM/` |
| Reference material | `3 - Resources/{topic}/` |
| Knowledge notes | `zettelkasten/{topic-folder}/` |
| Quick capture | `inbox/` |
| Meeting notes | `3 - Resources/Granola/` |
| Book notes | `3 - Resources/Books/` |

## Quick Reference

### Search

```bash
obsidian-cli search "query" -v riethmayer          # filename
obsidian-cli search-content "query" -v riethmayer  # content
```

For scripting, prefer `rg` / `fd` in the vault path.

### Create & Edit

Write `.md` files directly with the Write tool — Obsidian picks up changes instantly. For simple notes without frontmatter, `obsidian-cli create` works too.

### Links

```markdown
[[Note Name]]              [[Note Name|Display Text]]
[[Note#Heading]]           [[Note#^block-id]]
![[Note]]                  ![[image.png|300]]
```

Read [references/markdown.md](references/markdown.md) for full Obsidian-flavored Markdown syntax.

### Frontmatter

Every note starts with YAML frontmatter. Common fields in this vault:

```yaml
---
date: 2026-03-15
tags: [topic-tag]
hubs:
  - "[[Hub Note]]"
urls: []
---
```

Read [references/properties.md](references/properties.md) for all property types and vault-specific fields.

## Daily Notes

**Path format:** `2 - Areas/Journal/YYYY/MM-MMMM/YYYY-MM-DD-dddd.md`

Read [references/daily-notes.md](references/daily-notes.md) for the template, brag-book integration, and how to create them programmatically.

## Zettelkasten

- **Index:** `zettelkasten/_Index.md`
- **7 MOCs:** Leadership, Engineering, DevOps, Security, Strategy, Team, Personal
- **Files:** `zettelkasten/_MOC-{Name}.md` — each has `type: moc`, dataview LIST query

Read [references/templates.md](references/templates.md) for zettelkasten note, MOC, and book templates.

## Bases (.base files)

Obsidian's built-in database view system. Files use `.base` extension with YAML content defining filters, formulas, and views (table/cards/list/map).

Read [references/bases.md](references/bases.md) for schema, filter syntax, and examples.
Read [references/bases-functions.md](references/bases-functions.md) for the complete functions reference.

## Granola Meetings

Pull meeting transcripts via Granola MCP tools and save to `3 - Resources/Granola/`.

Read [references/granola.md](references/granola.md) for the workflow and note template.

## Reference Index

| File | Read when… |
|------|-----------|
| [cli.md](references/cli.md) | Using obsidian-cli commands (search, create, move, delete, frontmatter) |
| [markdown.md](references/markdown.md) | Writing Obsidian-flavored Markdown (wikilinks, embeds, callouts, comments) |
| [properties.md](references/properties.md) | Working with frontmatter fields and property types |
| [callouts.md](references/callouts.md) | Need the full list of callout types and aliases |
| [embeds.md](references/embeds.md) | Embedding notes, images, PDFs, audio, or search results |
| [templates.md](references/templates.md) | Creating zettelkasten notes, MOCs, or book notes |
| [daily-notes.md](references/daily-notes.md) | Creating or appending to daily notes, brag-book integration |
| [bases.md](references/bases.md) | Creating .base database views with filters and formulas |
| [bases-functions.md](references/bases-functions.md) | Writing Bases formulas (date, string, number, list, file functions) |
| [granola.md](references/granola.md) | Importing meeting transcripts from Granola |
