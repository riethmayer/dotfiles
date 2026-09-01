# swamp Configuration
# AI-native automation CLI (self-updating daily builds via `swamp update`)
#
# Completions: `swamp completions zsh` emits a ~430 KB version-stamped script
# and takes ~1.4 s, so it is neither eval'd at startup nor tracked in the
# repo. Cache it under XDG_CACHE_HOME and regenerate only when the binary is
# newer than the cache (mtime check is free; `swamp --version` costs 0.5 s).
# .zshrc runs compinit after all fragments, so the fpath entry is picked up.
# The generated script shells out to `swamp completions complete` for values,
# so only the command tree is static.

if command -v swamp >/dev/null 2>&1; then
    _swamp_comp_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
    _swamp_comp="${_swamp_comp_dir}/_swamp"
    _swamp_bin="${commands[swamp]:A}"

    if [[ ! -s "$_swamp_comp" || "$_swamp_comp" -ot "$_swamp_bin" ]]; then
        mkdir -p "$_swamp_comp_dir"
        # Write via tmp + mv so an interrupted regen never leaves a truncated file
        if swamp completions zsh > "${_swamp_comp}.tmp" 2>/dev/null; then
            mv -f "${_swamp_comp}.tmp" "$_swamp_comp"
        else
            rm -f "${_swamp_comp}.tmp"
        fi
    fi

    fpath=("$_swamp_comp_dir" $fpath)
    unset _swamp_comp_dir _swamp_comp _swamp_bin
fi
