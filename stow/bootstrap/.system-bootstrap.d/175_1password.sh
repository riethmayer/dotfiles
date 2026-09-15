#!/bin/bash

# 1Password service account for the `op` CLI (ADR-010): verify the machine
# has a token in the login Keychain and that it reaches the `machines` vault.
# Creating the vault and the service account needs an owner's interactive
# session (Touch ID, once), so this script only checks and prints the steps.
# Idempotent; exits 0 when the token is missing so a full bootstrap continues.

set -euo pipefail

KEYCHAIN_SERVICE="op-service-account-token"
VAULT="${DOTFILES_OP_VAULT:-machines}"

command -v op >/dev/null 2>&1 || { echo "1password: op not found (mise install)" >&2; exit 1; }

if tok="$(security find-generic-password -s "$KEYCHAIN_SERVICE" -w 2>/dev/null)"; then
    if OP_SERVICE_ACCOUNT_TOKEN="$tok" op vault get "$VAULT" >/dev/null 2>&1; then
        who="$(OP_SERVICE_ACCOUNT_TOKEN="$tok" op whoami --format json 2>/dev/null | /usr/bin/python3 -c 'import json,sys;d=json.load(sys.stdin);print(d.get("user_type","?"),d.get("url","?"))')"
        echo "1password: service account token in Keychain, vault '$VAULT' reachable ($who)"
        exit 0
    fi
    echo "1password: token found in Keychain but cannot read vault '$VAULT' (expired or wrong scope)" >&2
    exit 1
fi

cat <<STEPS
1password: no service account token in Keychain (service: $KEYCHAIN_SERVICE).
One-time setup, in an interactive shell (Touch ID once):

  1. Create the shared vault (service accounts cannot see Private):
       opme vault create $VAULT
  2. Move the machine secrets into it (dotfiles documents, CLI items):
       for id in \$(opme item list --vault Private --format json | jq -r '.[] | select(.title|startswith("dotfiles ")) | .id'); do
         opme item move "\$id" --current-vault Private --destination-vault $VAULT
       done
       opme item move ElevenLabs --current-vault Private --destination-vault $VAULT
  3. Create the service account (prints the token once, never again):
       opme service-account create "\$(hostname -s)" --vault $VAULT:read_items,write_items
  4. Store the token in the login Keychain:
       security add-generic-password -a "\$USER" -s $KEYCHAIN_SERVICE -w '<token>' -U
  5. exec zsh && op whoami      # user_type SERVICE_ACCOUNT
     dotfiles-local-sync list
STEPS
exit 0
