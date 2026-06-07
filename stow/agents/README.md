# Agents Configuration

Cross-tool AI agent config. `~/.agents/AGENTS.md` is the source of truth for instructions; Claude Code reads it via symlink. Personal skills are checked out separately at `~/src/my-skills`.

## Structure

```
.agents/
├── AGENTS.md              # Universal agent instructions (source of truth)
└── skills -> ~/src/my-skills/skills
.claude/
├── settings.json          # Claude Code settings, hooks, plugins
├── settings.local.json    # Machine-specific overrides
├── .mcp.json              # MCP server config
├── .claude/
│   └── settings.local.json  # Nested project-level defaults
└── plugins/
    └── config.json        # Plugin marketplace config
```

## Post-stow

`mise run install` also refreshes personal skills before stow. Stow can't create cross-directory symlinks, so after stow the task also runs:

```sh
ln -sf ~/.agents/AGENTS.md ~/.claude/CLAUDE.md
```

## Notes

- Only config files are version controlled
- Agent skill content lives in `~/src/my-skills`; dotfiles keeps only a symlink
- `mise run skills` clones/updates `~/src/my-skills`, registers the Git-backed Codex `jan-skills` marketplace, and installs the background updater
- Runtime data (history, sessions, cache, etc.) stays in `~/.claude/`
- `AGENTS.md` works with Claude Code, Gemini CLI, Codex, Cursor, Amp, etc.
- `CLAUDE.md` symlink ensures Claude Code picks it up at its expected path
