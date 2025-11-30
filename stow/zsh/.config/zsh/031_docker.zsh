# Docker Configuration
# Docker CLI and tools

# Add Docker CLI to PATH if it exists
if [ -d "${HOME}/.docker/bin" ]; then
    export PATH="${HOME}/.docker/bin:$PATH"
fi
