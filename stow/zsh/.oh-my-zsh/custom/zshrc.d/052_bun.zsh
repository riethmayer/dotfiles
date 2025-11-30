# bun configuration
export BUN_INSTALL="${XDG_DATA_HOME:-$HOME/.local/share}/bun"

# Add bun global bin to path if not already there
case ":$PATH:" in
  *":$BUN_INSTALL/bin:"*) ;;
  *) export PATH="$BUN_INSTALL/bin:$PATH" ;;
esac
