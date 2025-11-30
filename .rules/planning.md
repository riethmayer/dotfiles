# Planning Rules

## Sprint Management

Sprints are tracked in `.planning/` directory.

### Sprint Completion

A sprint is **complete** when a `summary.md` file exists in `.planning/`:
- File naming: `sprint-{NN}-{name}-summary.md`
- Example: `sprint-01-zsh-consolidation-summary.md`

When starting work:
1. Check `.planning/README.md` for sprint status
2. Look for existing `*-summary.md` files to determine completed sprints
3. Work on next incomplete sprint sequentially

### Summary File Format

```markdown
# Sprint {N}: {Title} - Summary

## Completed: {date}

## Changes Made
- List of files changed/created/deleted

## Verification
- How completion was verified

## Notes
- Any follow-up items or observations
```

### Sprint Status Updates

After completing a sprint:
1. Create `sprint-{NN}-{name}-summary.md`
2. Update `.planning/README.md` checkbox to `[x]`
