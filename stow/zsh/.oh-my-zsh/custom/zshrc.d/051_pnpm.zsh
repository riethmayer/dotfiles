# pnpm configuration
export PNPM_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"

# Add pnpm to path if not already there
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac 