#!/bin/bash

# Install GPG and related tools
brew install gnupg pinentry-mac

# Create necessary directories
mkdir -p ~/.gnupg
chmod 700 ~/.gnupg

# Configure GPG to use pinentry-mac
echo "pinentry-program $(brew --prefix)/bin/pinentry-mac" > ~/.gnupg/gpg-agent.conf

# Restart GPG agent
gpgconf --kill gpg-agent

# Instructions for importing existing key or creating new one
cat << 'EOF'
GPG setup complete! 

To create a new GPG key:
1. Run: gpg --full-generate-key
2. Choose ECC (ECC and ECC sign) (9)
3. Choose Curve 25519 for best compatibility
4. Choose key validity time (recommended: 2y)
5. Enter your details (use your GitHub-verified email)

To backup your key to 1Password:
1. Export your public and private keys:
   gpg --export-secret-keys --armor YOUR_EMAIL > private.key
   gpg --export --armor YOUR_EMAIL > public.key

2. Save both files as secure notes in 1Password
   # Remember to delete the local key files after saving:
   rm private.key public.key

To import an existing key from 1Password:
1. Copy the private key content from 1Password to a file:
   pbpaste > private.key
2. Import it:
   gpg --import private.key
3. Clean up:
   rm private.key

Configure git to use your key:
1. List your key ID:
   gpg --list-secret-keys --keyid-format=long
2. Configure git:
   git config --global user.signingkey YOUR_KEY_ID
   git config --global commit.gpgsign true

Add to GitHub:
1. Export your public key:
   gpg --armor --export YOUR_KEY_ID
2. Copy the output and add it to GitHub's SSH/GPG keys settings

Test your setup:
git commit --allow-empty -m "test signed commit"
EOF 