# Claude Preferences

## Git & GitHub

- Concise commits, sacrifice grammar for clarity
- Use `gh` CLI for GitHub operations (not `git` for PR/issue ops)
- Branch prefix: `riethmayer/`
- End plans with unresolved questions
- Commit early and often, atomic commits

## Tool Permissions

**Always Allowed:**
- Read/Write/Edit for project files
- Bash commands for development tasks
- Git operations (commit, push, pull, branch)
- Package manager commands (npm, pnpm, pip, gem, go)
- File system navigation and search

**Ask Before:**
- Modifying system configs outside dotfiles
- Installing new global packages
- Running destructive database operations
- Accessing production credentials

**Never Allowed:**
- Modifying `~/.ssh/` private keys
- Reading credential files (.env with secrets)
- Running `rm -rf` on important directories
- Changing system security settings

## Code Style

**TypeScript/JavaScript:**
- Prefer TypeScript with strict mode
- Use async/await over promises
- Prefer functional patterns where sensible
- Early returns for guard clauses
- Descriptive variable names over comments

**Testing:**
- Vitest for TypeScript/JavaScript
- Test behavior, not implementation
- Integration tests over unit tests when practical
- Use test.todo for planned tests

**General:**
- Prettier defaults for formatting
- ESLint with reasonable rules
- 2 spaces for indentation
- No semicolons in TypeScript/JavaScript
- Single quotes for strings

## Workflow Preferences

**Development:**
- Check existing tests before major changes
- Run formatter before committing
- Use direnv for project env vars
- Prefer mise over nvm/rbenv directly

**Documentation:**
- Update README for public-facing changes
- Document "why" not "what" in comments
- Keep technical debt in TODO comments
- Use Markdown for all docs

**Tools:**
- ripgrep (`rg`) over grep
- fd over find
- bat for file viewing
- delta for git diffs
- lazygit for complex git operations
- zoxide (`z`) for directory navigation

## Planning

When a repo has `.planning/` directory:
1. Check `.planning/README.md` for current sprint status
2. Look for incomplete sprints (unchecked `[ ]` items)
3. Read the sprint file before starting work
4. A sprint is complete when `sprint-{NN}-{name}-summary.md` exists

## Brag Book

- Track work in `$XDG_DATA_HOME/brag-book/` (`~/.local/share/brag-book/`)
- Daily JSONL files: `{date}.jsonl` (e.g., `2025-11-20.jsonl`)
- Entry format: `{"timestamp": "...", "summary": "...", "source": "hook|manual", ...}`
- Use `brag` command to add entries manually
- Stop hook auto-captures via `brag-capture-stop`
- Shared with OpenCode (same data format)

## Project Patterns

**TypeScript Projects:**
- src/ for source code
- Prefer named exports
- Index files only for public API
- Co-locate tests with source
- Type-only imports where possible

**API Development:**
- RESTful conventions
- Validate input early
- Return consistent error formats
- Use proper HTTP status codes
- Version APIs from the start

**Database:**
- Migrations for schema changes
- Seed data separate from migrations
- Use transactions for multi-step operations
- Soft deletes for user data

## Communication Style

- Be direct and concise
- Focus on solving the problem
- Suggest alternatives when disagreeing
- Ask clarifying questions early
- Provide examples with explanations
- End with next steps or questions