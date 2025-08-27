# Wezterm configuration
export WEZTERM_BIN="/Applications/WezTerm.app/Contents/MacOS"

# Add Wezterm to PATH if not already present
case ":$PATH:" in
  *":$WEZTERM_BIN:"*) ;;
  *) export PATH="$WEZTERM_BIN:$PATH" ;;
esac
