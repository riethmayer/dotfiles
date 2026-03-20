# Vault Templates

Templates live in `3 - Resources/Templates/`. The vault uses Templater plugin for dynamic content.

## Zettelkasten Note

Place in `zettelkasten/{topic-folder}/`. One idea per note, written in own words.

```markdown
---
id: Note-Title
date: YYYY-MM-DD
tags:
  - topic-tag
hubs:
  - "[[Hub Note]]"
urls:
  - https://source-url.com
aliases: []
---

# Note Title

(Content — one idea, own words)

## Related

- [[Related Note 1]]
- [[Related Note 2]]
```

**Conventions:**
- Tags match the topic folder name
- Link to hub notes via `hubs` frontmatter (wikilink syntax in quotes)
- `id` is optional but useful for unique identification
- Create a new topic folder if no existing one fits

## MOC (Map of Content)

7 existing MOCs: Leadership, Engineering, DevOps, Security, Strategy, Team, Personal.
Files: `zettelkasten/_MOC-{Name}.md`

```markdown
---
type: moc
area: career
created: YYYY-MM-DD
---

# MOC Name

## Overview

Brief description of this knowledge area.

## Key Concepts

```dataview
LIST
FROM "zettelkasten/topic-folder"
SORT file.name ASC
\```

## Related Areas

- [[_MOC-RelatedTopic]]
- [[Relevant Area Note]]

## References

- External references
```

## Book Note

Uses Book Search plugin with Templater. Template: `3 - Resources/Templates/Book template.md`

```yaml
tag: "\U0001F4DABook"
title: "Book Title"
subtitle: "Subtitle"
author: [Author Name]
category: [Category]
publisher: Publisher
publish: YYYY-MM-DD
total: 300
isbn: isbn10 isbn13
cover: https://cover-url
localCover: path/to/local/image
status: unread
created: YYYY-MM-DD HH:mm:ss
updated: YYYY-MM-DD HH:mm:ss
```

Place in `3 - Resources/Books/`.

## Dataview Queries

The vault uses Dataview plugin in MOCs and index files:

```dataview
LIST
FROM "zettelkasten/topic"
SORT file.name ASC
```

```dataview
TABLE date, tags
FROM "zettelkasten"
WHERE type != "moc" AND type != "index"
SORT date DESC
```
