# Sprint 3: OpenCode Configuration

## Problem

No OpenCode configuration exists:
- `~/.config/opencode/` only has plugin SDK dependencies
- Missing `opencode.json` config file
- No stow package for opencode

## Tasks

### 3.1 Create stow/opencode package
```
stow/opencode/.config/opencode/
```

### 3.2 Create opencode.json
Configure:
- Default model (claude-sonnet-4-20250514 or preferred)
- Keybindings if needed
- Theme preferences
- Any MCP servers

### 3.3 Create OPENCODE.md (optional)
Project-level instructions file if OpenCode supports it.

### 3.4 Add to bootstrap
Update mise tasks if opencode needs setup script.

### 3.5 Test
- Stow package
- Launch opencode
- Verify config loads

## Files to Create

```
stow/opencode/.config/opencode/opencode.json
```

## Example opencode.json

```json
{
  "$schema": "https://opencode.ai/config.schema.json",
  "model": {
    "default": "claude-sonnet-4-20250514"
  },
  "theme": "catppuccin"
}
```

## Acceptance Criteria

- [ ] stow/opencode package exists
- [ ] opencode.json with preferences
- [ ] Config symlinked to ~/.config/opencode/
- [ ] OpenCode uses config on launch
