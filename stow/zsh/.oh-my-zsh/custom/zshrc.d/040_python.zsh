# Python Configuration
# Conda and Python environment management

# Check for conda installations in common locations
CONDA_PATHS=(
    "${HOME}/miniforge3"
    "${HOME}/anaconda3"
    "${HOME}/miniconda3"
    "/opt/homebrew/anaconda3"
    "/opt/homebrew/miniforge3"
)

# Find and initialize conda
for conda_path in "${CONDA_PATHS[@]}"; do
    if [ -f "${conda_path}/bin/conda" ]; then
        __conda_setup="$('${conda_path}/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
        if [ $? -eq 0 ]; then
            eval "$__conda_setup"
            break
        elif [ -f "${conda_path}/etc/profile.d/conda.sh" ]; then
            . "${conda_path}/etc/profile.d/conda.sh"
            break
        fi
    fi
done
unset __conda_setup


