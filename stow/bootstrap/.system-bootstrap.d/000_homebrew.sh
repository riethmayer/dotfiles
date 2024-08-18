# if brew is not installed
if ! [ -x "$(command -v brew)" ]; then
  # Install Homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

ulimit -n 20000
if [[ $(ulimit -Sn) -lt 20000 ]]; then
  echo "Limit of open files is too low ($(ulimit -Sn)), please increase it to 20k or more"
  exit 1
fi

# concatenate all files from ../.brewfile.d/* and pass to xargs brew installed
cat "$(dirname "$0")"/../.brewfile.d/* | xargs brew install -q

cd "$HOME" && brew bundle --file="$HOME/Brewfile"
