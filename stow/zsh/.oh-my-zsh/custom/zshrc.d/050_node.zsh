# Node.js Configuration
# JavaScript/TypeScript development tools

# Bun - JavaScript runtime
if [ -d "${HOME}/.bun" ]; then
    export BUN_INSTALL="${HOME}/.bun"
    export PATH="${BUN_INSTALL}/bin:$PATH"
fi

# Console Ninja - development tool
if [ -d "${HOME}/.console-ninja/.bin" ]; then
    export PATH="${HOME}/.console-ninja/.bin:$PATH"
fi

