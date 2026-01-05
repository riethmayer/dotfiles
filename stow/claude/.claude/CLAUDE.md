In all interactions and commit messages, be extremely concise and sacrifice grammar for the sake of concision.

## Git & GitHub

- Use `gh` CLI for GitHub operations (not `git` for PR/issue ops)
- Branch prefix: `riethmayer/`
- End plans with unresolved questions
- Commit early and often, atomic commits
- Do NOT add Claude Code footer or Co-Authored-By to commit messages

## Search

- Use fzf whenever searching for things

## YAML

- Create valid YAML - avoid `->` in lists as it breaks parsing

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
- fzf for fuzzy finding when interactive selection needed

**Agent Workflow Optimization:**
- Use `rg` instead of grep for faster codebase searches
- Use `fd` instead of find for faster file discovery
- Modern CLI tools = faster feedback loops for agentic coding
- Avoid slow tools that block agent progress

## Planning

When a repo has `.planning/` directory:
1. Check `.planning/README.md` for current sprint status
2. Look for incomplete sprints (unchecked `[ ]` items)
3. Read the sprint file before starting work
4. A sprint is complete when `sprint-{NN}-{name}-summary.md` exists

- At the end of each plan, give me a list of unresolved questions to answer, if any. Make the questions extremely concise and sacrifice grammer for the sake of concision.

## Brag Book

- Track work in `$XDG_DATA_HOME/brag-book/` (`~/.local/share/brag-book/`)
- Daily JSONL files: `{date}.jsonl` (e.g., `2025-11-20.jsonl`)
- Categories: strategy, culture, execution
- Entry format: `{"timestamp": "HH:MM:SS", "category": "...", "summary": "...", "source": "hook|manual", "session_id": "..."}`
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

## EagleEye Database Access

**Production DB** (adhoc.* tables):
- Port 5555 via Docker proxy
- Check `claude mcp list` for connection string
- Use psycopg2 scripts with these creds for exports

**State DB** (SQLMesh):
- Port from `data/transformation/.state_db_proxy_port`
- Creds in `data/transformation/.env` (SQLMESH_STATE_DB_*)
- Start with: `cd data/transformation && ./up.sh`

**Context warning**: Large MCP query results (1000+ rows) kill context. Use Python scripts with psycopg2 instead.
- When asking to create a presentation, refer to the pptx skill and brand guidelines
- When reading excalidraw files, don't try to load them fully but extract relevant nodes instead
- always assume cursor over code as client, until I adopted nvim
- When creating git worktrees, remember to copy over configuration files (e.g. CLAUDE mcp settings, .env files, etc) check the gitignore
- Looks like you've done the presentation without taking into consideration the brand guidelines in the earlybird plugin. Always, when you create a website, presentation or any other visual, take the brand-guidelines into account
- when creating presentations, add strictly confidential to the first slide on the top right.
