# Javascript/Typescript/Node configuration

export VOLTA_HOME=$HOME/.volta
export PATH=$VOLTA_HOME/bin:$PATH

# if volta is not installed
if ! command -v volta &> /dev/null; then
  echo "Installing volta..."
  /bin/bash -c "$(curl https://get.volta.sh) -s -- skip-setup"
fi

if ! command -v node &> /dev/null; then
  echo "Installing node..."
  volta install node
fi

export VOLTA_FEATURE_PNPM=1

if ! command -v pnpm &> /dev/null; then
  echo "Installing pnpm..."
  volta install pnpm
fi

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Console Ninja
export PATH=$HOME/.console-ninja/.bin:$PATH

