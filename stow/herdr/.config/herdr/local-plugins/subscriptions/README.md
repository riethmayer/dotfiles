# Subscriptions

Herdr popup for account-wide Codex, Claude, and Droid limits. Every percentage is displayed as remaining allowance, with reset countdowns and local reset times.

## Data sources

- Codex: `~/.codex/auth.json` → ChatGPT's Codex usage endpoint
- Claude: the `Claude Code-credentials` macOS Keychain item → Anthropic's OAuth usage endpoint
- Droid: the read-only `~/.factory/auth.v2.loginkeychain` login with its `Factory CLI` Keychain key, falling back to `auth.v2.{file,key}` → Factory's billing limits endpoint

The plugin never stores, logs, refreshes, or writes credentials. These are private APIs used by the corresponding first-party CLIs and may change. If Droid reports HTTP 401, run `droid` once so its CLI refreshes its own login.

## Development

```bash
pnpm install --frozen-lockfile
pnpm check
pnpm test
pnpm build
herdr plugin link "$PWD"
```

Open it with `Ctrl-A Ctrl-L`. Inside the popup, press `r` to refresh, `q` or Escape to close, and the arrow keys to scroll.
