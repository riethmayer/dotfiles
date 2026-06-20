# Re-assert mise PATH precedence (must run after all other PATH edits).
# `mise activate` (020) injects mise's tool bin dirs, but later fragments:
# docker (031), java/maven (053), llvm (060), gcloud (070), prepend their own
# dirs in front, pushing the mise tools behind system-installed versions.
# Re-running `mise activate` no-ops (its __MISE_DIFF guard skips re-injection),
# so re-prepend the active tool bin paths plus the shims dir here, after every
# other PATH edit. `typeset -U` drops the now-duplicate earlier entries so mise
# wins. Runs before 99_local, leaving per-machine overrides the final say.
if command -v mise >/dev/null 2>&1; then
    path=(
        ${(f)"$(mise bin-paths 2>/dev/null)"}
        "${MISE_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/mise}/shims"
        $path
    )
    typeset -U path PATH
fi
