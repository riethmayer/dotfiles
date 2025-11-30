# Node.js and Bun Configuration
# JavaScript/TypeScript runtimes

# Bun - JavaScript runtime (XDG-compliant)
export BUN_INSTALL="${XDG_DATA_HOME}/bun"
case ":$PATH:" in
    *":$BUN_INSTALL/bin:"*) ;;
    *) export PATH="$BUN_INSTALL/bin:$PATH" ;;
esac
