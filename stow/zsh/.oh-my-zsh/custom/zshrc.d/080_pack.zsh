
if ! command -v pack &> /dev/null; then
  echo "Installing pack..."
  brew install buildpacks/tap/pack
fi

. $(pack completion --shell zsh)

