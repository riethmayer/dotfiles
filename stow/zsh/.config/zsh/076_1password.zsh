# 1Password CLI via a service account (ADR-010).
# https://www.1password.dev/service-accounts
#
# With OP_SERVICE_ACCOUNT_TOKEN set, every `op` call authenticates as the
# machine's service account: no biometric prompt, works in agent panes and
# non-interactive shells. The token itself lives in the login Keychain
# (never on disk in the repo); `mise run 1password` walks through creating it.
# Absent token = plain `op`, i.e. the interactive session with Touch ID.
#
# The service account only sees the `machines` vault (1Password refuses to
# grant service accounts access to Private). `opme` drops the token for the
# rare personal-vault lookup.
if command -v op >/dev/null 2>&1; then
    if [[ -z ${OP_SERVICE_ACCOUNT_TOKEN-} ]]; then
        _op_tok="$(security find-generic-password -s op-service-account-token -w 2>/dev/null)" \
            && export OP_SERVICE_ACCOUNT_TOKEN="$_op_tok"
        unset _op_tok
    fi
    alias opme='OP_SERVICE_ACCOUNT_TOKEN= op'
fi
