# Sprint 9: Claude CLAUDE.md Enhancement

## Problem

Current `~/.claude/CLAUDE.md` is minimal:
- Basic preferences only
- No tool permissions
- No MCP servers
- No project templates

## Tasks

### 9.1 Add tool permissions
```markdown
## Allowed Tools

- Read, Write, Edit for all files
- Bash for system commands
- Git operations

## Denied Patterns

- No modifications to ~/.ssh/
- No credential file access
```

### 9.2 Add MCP server configs (if using)
```markdown
## MCP Servers

- filesystem: ~/projects access
- github: repo operations
```

### 9.3 Add project templates
Common patterns for your projects:
- TypeScript/Node conventions
- Testing preferences
- Documentation standards

### 9.4 Add workflow preferences
```markdown
## Workflow

- Use gh CLI for GitHub
- Prefix branches with riethmayer/
- Run tests before committing
```

### 9.5 Review settings.json
Current plugins:
- earlybird-shared
- earlybird-product-management
- document-skills
- example-skills

Evaluate if all needed.

## Files Affected

```
stow/claude/.claude/CLAUDE.md
stow/claude/.claude/settings.json (review)
```

## Example Enhanced CLAUDE.md

```markdown
- Concise commits, sacrifice grammar
- Use gh CLI for GitHub
- Branch prefix: riethmayer/
- End plans with unresolved questions

## Brag Book
[existing content]

## Tool Permissions
- Allow: file ops, git, bash
- Deny: ~/.ssh/, credentials

## Code Style
- TypeScript: strict mode
- Tests: vitest preferred
- Formatting: prettier defaults

## MCP Servers
[configure as needed]
```

## Acceptance Criteria

- [ ] Tool permissions documented
- [ ] MCP servers configured (if using)
- [ ] Code style preferences added
- [ ] Workflow preferences complete
