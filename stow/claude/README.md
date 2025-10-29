# Claude Configuration

Claude Code configuration files for AI-powered development assistant.

## Structure

```
.claude/
├── settings.json       # Claude settings (alwaysThinkingEnabled, etc.)
└── plugins/
    └── config.json     # Plugin configuration
```

## Notes

- Only configuration files are version controlled
- Runtime data (history, todos, session-env, debug, etc.) is excluded
- The `~/.claude/` directory contains both config and runtime state
- Stow will create symlinks for config files only
