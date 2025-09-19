# Google Cloud SDK configuration
export GCLOUD_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/google-cloud-sdk"

# Add gcloud to PATH
case ":$PATH:" in
  *":$GCLOUD_HOME/bin:"*) ;;
  *) export PATH="$GCLOUD_HOME/bin:$PATH" ;;
esac

# Load gcloud path configuration
if [ -f "$GCLOUD_HOME/path.zsh.inc" ]; then
  source "$GCLOUD_HOME/path.zsh.inc"
fi

# Enable shell command completion for gcloud
if [ -f "$GCLOUD_HOME/completion.zsh.inc" ]; then
  source "$GCLOUD_HOME/completion.zsh.inc"
fi