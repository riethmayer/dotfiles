# Console Ninja Configuration
# VS Code extension for in-editor console output
# Requires: VS Code with Console Ninja extension

# Set Console Ninja paths following XDG specification
export CONSOLE_NINJA_HOME="${XDG_DATA_HOME}/console-ninja"

# Check if Console Ninja is installed (check both old and new locations)
if [ -d "${HOME}/.console-ninja/.bin" ]; then
    # Legacy path
    export PATH="${HOME}/.console-ninja/.bin:$PATH"
elif [ -d "${CONSOLE_NINJA_HOME}/.bin" ]; then
    # XDG-compliant path
    export PATH="${CONSOLE_NINJA_HOME}/.bin:$PATH"
else
    # Suppress warning as Console Ninja is optional
    : # No-op
fi 