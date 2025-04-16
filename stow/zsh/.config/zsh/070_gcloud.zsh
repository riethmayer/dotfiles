# Google Cloud SDK Configuration
# Command-line interface for Google Cloud Platform
# Requires: gcloud (installed via brew)

# Set Google Cloud SDK paths following XDG specification
export CLOUDSDK_CONFIG="${XDG_CONFIG_HOME}/gcloud"
export CLOUDSDK_CACHE_DIR="${XDG_CACHE_HOME}/gcloud"

# Possible Google Cloud SDK locations
GCLOUD_BREW_PATH="/opt/homebrew/share/google-cloud-sdk"
GCLOUD_CASK_PATH="/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
GCLOUD_CUSTOM_PATH="${XDG_DATA_HOME}/google-cloud-sdk"

# Find Google Cloud SDK installation
if [ -f "${GCLOUD_BREW_PATH}/path.zsh.inc" ]; then
    GCLOUD_PATH="${GCLOUD_BREW_PATH}"
elif [ -f "${GCLOUD_CASK_PATH}/path.zsh.inc" ]; then
    GCLOUD_PATH="${GCLOUD_CASK_PATH}"
elif [ -f "${GCLOUD_CUSTOM_PATH}/path.zsh.inc" ]; then
    GCLOUD_PATH="${GCLOUD_CUSTOM_PATH}"
fi

# Source Google Cloud SDK if found
if [ -n "${GCLOUD_PATH}" ]; then
    source "${GCLOUD_PATH}/path.zsh.inc"
    source "${GCLOUD_PATH}/completion.zsh.inc"
else
    # Suppress warning as GCloud is optional
    : # No-op
fi 