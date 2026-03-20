# Agents Configuration

Cross-tool AI agent config. `~/.agents/AGENTS.md` is the source of truth for instructions; Claude Code reads it via symlink.

## Structure

```
.agents/
└── AGENTS.md              # Universal agent instructions (source of truth)
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

Stow can't create cross-directory symlinks, so after `mise run install`:

```sh
ln -sf ~/.agents/AGENTS.md ~/.claude/CLAUDE.md
```

## Notes

- Only config files are version controlled
- Runtime data (history, sessions, cache, etc.) stays in `~/.claude/`
- `AGENTS.md` works with Claude Code, Gemini CLI, Codex, Cursor, Amp, etc.
- `CLAUDE.md` symlink ensures Claude Code picks it up at its expected path
