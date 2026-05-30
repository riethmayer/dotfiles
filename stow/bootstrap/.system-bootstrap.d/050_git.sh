#!/bin/bash

# Exit on error
set -e

# Stow git configuration
cd "$(dirname "$0")/../../.."
stow -d stow -t ~ git

# Seed per-machine git identity. The tracked config pulls ~/.config/git/local
# via [include]; if that file is missing, user.email is unset and — because
# commit.gpgsign is on — the first commit dies with a cryptic "user.signingkey
# needs to be configured". Git never prompts for identity on its own, so seed
# the file here. Idempotent: an existing ~/.config/git/local is never touched.
git_local="$HOME/.config/git/local"
if [ ! -e "$git_local" ]; then
    if [ -t 0 ]; then
        echo "Setting up per-machine git identity (~/.config/git/local)..."
        read -r -p "  git user.name  [Jan Riethmayer]: " git_name || true
        read -r -p "  git user.email (e.g. work vs private): " git_email || true
        git_name="${git_name:-Jan Riethmayer}"
        : "${git_email:=CHANGE-ME@example.com}"
    else
        # Non-interactive bootstrap: seed a placeholder and warn loudly.
        echo "⚠️  ~/.config/git/local is missing and there is no TTY to prompt."
        echo "    Seeding a placeholder — EDIT IT before committing:"
        echo "        \$EDITOR ~/.config/git/local"
        git_name="Jan Riethmayer"
        git_email="CHANGE-ME@example.com"
    fi
    mkdir -p "$(dirname "$git_local")"
    cat > "$git_local" <<EOF
# Per-machine git identity & machine-specific settings. NOT tracked (gitignored).
# Seeded by 050_git.sh. See stow/git/.config/git/local.example.
[user]
	name = $git_name
	email = $git_email
	signingkey = ~/.ssh/id_ed25519.pub
[gpg "ssh"]
	allowedSignersFile = $HOME/.ssh/allowed_signers
EOF
    echo "Wrote $git_local (email: $git_email)"
fi

echo "Git setup complete!"
