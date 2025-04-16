# pnpm Configuration
# Fast, disk space efficient package manager for Node.js
# Requires: pnpm (installed via npm or mise)

# Check if pnpm is available or will be available through mise
if command -v pnpm >/dev/null 2>&1 || command -v mise >/dev/null 2>&1; then
    # Set pnpm home directory following XDG specification
    export PNPM_HOME="${XDG_DATA_HOME}/pnpm"

    # Add pnpm to PATH if not already present
    case ":$PATH:" in
        *":$PNPM_HOME:"*) ;;
        *) export PATH="$PNPM_HOME:$PATH" ;;
    esac
else
    echo "Warning: pnpm not found and mise not available. Node.js package management will be limited."
fi 