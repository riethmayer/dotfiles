# pnpm Configuration
# Package manager for Node.js with disk space efficiency and fast installation

# Set pnpm home directory following XDG specification
export PNPM_HOME="${XDG_DATA_HOME}/pnpm"

# Add pnpm to PATH if not already present
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac 