# obsidian-cli Reference

CLI: `/opt/homebrew/bin/obsidian-cli` (v0.2.2). Default vault: `riethmayer`.

All commands accept `-v riethmayer` to specify the vault.

## Search

```bash
obsidian-cli search "query" -v riethmayer            # Fuzzy filename search
obsidian-cli search-content "query" -v riethmayer    # Full-text content search
```

For programmatic/scripted search, prefer `rg` or `fd` directly in `/Users/jan/obsidian/riethmayer` — faster and scriptable.

## Read

```bash
obsidian-cli print "Note Name" -v riethmayer
obsidian-cli print "Note Name" -v riethmayer --mentions   # Include backlinks
```

Or use the Read tool directly on the file path.

## Create

```bash
obsidian-cli create "path/to/Note Name" -v riethmayer -c "content here"
obsidian-cli create "path/to/Note Name" -v riethmayer -c "more content" --append
obsidian-cli create "path/to/Note Name" -v riethmayer -c "replace" --overwrite
```

Path is relative to vault root. For notes needing frontmatter, prefer Write tool directly.

## Move / Rename

```bash
obsidian-cli move "Old Name" "new/path/New Name" -v riethmayer
```

Updates wikilinks across the vault. Vault also has `alwaysUpdateLinks: true`, so Obsidian handles this on its own if you rename via the app.

## Delete

```bash
obsidian-cli delete "Note Name" -v riethmayer
```

## Frontmatter

```bash
obsidian-cli frontmatter "Note Name" --print -v riethmayer
obsidian-cli frontmatter "Note Name" --edit --key "status" --value "done" -v riethmayer
obsidian-cli frontmatter "Note Name" --delete --key "draft" -v riethmayer
```

## Daily Notes

```bash
obsidian-cli daily -v riethmayer   # Opens today's daily note in Obsidian
```

## Set Default Vault

```bash
obsidian-cli set-default riethmayer
obsidian-cli print-default              # Verify
```
